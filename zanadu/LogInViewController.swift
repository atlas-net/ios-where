//
//  LogInViewController.swift
//  Atlas
//
//  Created by yingyang on 16/3/21.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation

import DeviceKit
import MBProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    
    let device = Device()
    let counterValue = 120
    var counter = 120
    var timer: Timer?
    
    var backBtn = UIButton()
    var lastValidPhoneNumber: String?
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var weixinButton: UIImageView!
    @IBOutlet weak var weiboButton: UIImageView!

    @IBOutlet weak var weixinTitleLeftBar: UIView!
    @IBOutlet weak var weixinTitle: UILabel!
    @IBOutlet weak var weixinTitleRightBar: UIView!
    
    @IBOutlet weak var weiboButtonCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var weixinButtonCenterXConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var weiXinBtn: UIButton!
    @IBOutlet weak var weiBoBtn: UIButton!

    
    //MARK: - Initializers
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissTextFields))
        view.addGestureRecognizer(tap)
        setupForm()
        checkUser()
        setupBackBtn()
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(LoginViewController.appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
    }
    
    func appDidBecomeActive() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    //MARK: - UIViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupValidationButton()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        MBProgressHUD.hide(for: self.view, animated: true)
        firstLoginAddDefaultFriends()
        
    }
    
    
    //MARK: - Actions
    
    @IBAction func backBtnClick(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    func backController() {
        if  let tabBarVC = self.tabBarController {
            tabBarVC.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func onCodeButtonTapped(_ sender: AnyObject) {
        
        guard let text = phoneField.text else {
            self.showBasicAlertWithTitle(Config.Strings.IncorrectPhoneNumberErrorMessage)
            return
        }
        
        switch text.characters.count {
        case 11:
            if (Int64(text) != nil) {
                requestCodeForNumber(text)
            }
        case 0:
            self.showBasicAlertWithTitle(Config.Strings.NoPhoneNumberErrorAlertMessage)
            return
            
        default:
            self.showBasicAlertWithTitle(Config.Strings.PhoneNumberLengthErrorAlertMessage)
            return
        }
    }
    
    @IBAction func onLoginButtonTapped(_ sender: AnyObject) {
        showHUD()
        checkSMSCode()
    }
    
    @IBAction func onThirdPartyLoginButtonTapped(_ sender: UIButton) {
        let method: AVOSCloudSNSType
        
        if sender == weiXinBtn {
            method = AVOSCloudSNSType.snsWeiXin
        } else { // weibo
            method = AVOSCloudSNSType.snsSinaWeibo
        }
        thirdLoginRequest(method)

    }
    
    func thirdLoginRequest(_ method: AVOSCloudSNSType) {
        showHUD()
        AuthManager.loginWithMethod(method) { success, error in
            self.hideHUD()
            if !success {
                if method == AVOSCloudSNSType.snsWeiXin{
                    log.error("Wechat login failed")
                }else{
                    log.error("WeiBo login failed")
                }
                if error != nil {

                }
            } else {

                let cureentUser = User.current() as? User
                cureentUser?.lastLoginTime = Date()
                
                self.setupNotifications()
                
                let technicalData = TechnicalData()
                technicalData.iosVersion = UIDevice.current.systemVersion
                let infoDictionary = Bundle.main.infoDictionary
                let  appVersion:String  = infoDictionary!["CFBundleShortVersionString"] as! String
                technicalData.appVersion = appVersion
                technicalData.deviceUUID =  UIDevice.current.identifierForVendor!.uuidString
                technicalData.iphoneModel =  self.device.description
                cureentUser?.technicalData = technicalData
                technicalData.saveInBackground({ (success, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        cureentUser?.saveEventually()
                    }
                })
                self.backController()
            }
        }

    }
    func showHUD() {
        let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.labelText = "登录中"
    }
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    //MARK: - Methods
    
    fileprivate func setupBackBtn(){
        backBtn.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        backBtn.setBackgroundImage(UIImage(named: "btn_back_default"), for: UIControlState())
        backBtn.setBackgroundImage(UIImage(named: "btn_back_highlight"), for: UIControlState.highlighted)
        backBtn.addTarget(self, action: #selector(LoginViewController.backBtnClick(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(backBtn)
    }
    
    func setupForm() {
        self.view.backgroundColor = Config.Colors.TagViewBackground
        
        setupPhoneForm()
        weiXinBtn.adjustsImageWhenHighlighted = false
        weiBoBtn.adjustsImageWhenHighlighted = false

        if AVOSCloudSNS.isAppInstalled(for: AVOSCloudSNSType.snsWeiXin) {
            weiXinBtn.isEnabled = true
            weiXinBtn.addTarget(self, action: #selector(LoginViewController.onThirdPartyLoginButtonTapped(_:)), for: .touchUpInside)

        } else {
            weiXinBtn.isHidden = true
        }
        
        if AVOSCloudSNS.isAppInstalled(for: AVOSCloudSNSType.snsSinaWeibo) {
            if weiXinBtn.isEnabled == false {
                weiboButtonCenterXConstraint.constant = 0
            }
            weiBoBtn.isEnabled = true
            weiBoBtn.addTarget(self, action:  #selector(LoginViewController.onThirdPartyLoginButtonTapped(_:)), for: .touchUpInside)

        } else {
            if weiXinBtn.isEnabled == true {
                weixinButtonCenterXConstraint.constant = 0
            }
            weiBoBtn.isHidden = true
        }

    }
    
    func setupPhoneForm() {
        phoneField!.textColor = UIColor.white
        phoneField!.attributedPlaceholder = NSAttributedString(string: Config.Strings.PhoneFieldPlaceholder, attributes: [NSForegroundColorAttributeName:UIColor.white])
        // phoneField!.backgroundColor = Config.Colors.TagFieldBackground
        
        let phoneLeftFrame = CGRect(x: 0,y: 0,width: 0 ,height: 40)
        let phoneLeftView = UIView(frame: phoneLeftFrame)
        phoneField.leftView = phoneLeftView
        phoneField.leftViewMode = .always
        
        let codePaddingFrame = CGRect(x: 0,y: 0,width: 0,height: 40)
        let codePaddingView = UIView(frame: codePaddingFrame)
        codeField!.textColor = UIColor.white
        codeField!.attributedPlaceholder = NSAttributedString(string: Config.Strings.SMSCodeFieldPlaceholder, attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        codeField.leftView = codePaddingView
        codeField.leftViewMode = .always
        
        codeButton!.isEnabled = true
        codeButton!.setTitle(Config.Strings.GetSMSButtonLabel, for: UIControlState())
        codeButton!.layer.borderWidth = 1.0
        codeButton!.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupValidationButton() {
        self.validationButton.isEnabled = false
    }
    
    func updateCounter() {
        if counter < 0 {
            timer?.invalidate()
            self.codeButton!.isEnabled = true
            let title =  NSAttributedString(string: Config.Strings.GetSMSButtonLabel, attributes: [NSForegroundColorAttributeName:UIColor.white])
            self.codeButton!.setAttributedTitle(title, for: UIControlState())
            return
        }
        counter -= 1
        let title =  NSAttributedString(string: "\(counter)", attributes: [NSForegroundColorAttributeName:UIColor.white])
        self.codeButton!.setAttributedTitle(title, for: UIControlState())
    }
    
    func requestCodeForNumber(_ number: String) {
        self.codeButton?.isEnabled = false
        self.counter = counterValue
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(LoginViewController.updateCounter), userInfo: nil, repeats: true)
        
        AVOSCloud.requestSmsCode(withPhoneNumber: number, appName: Config.App.Name, operation: Config.Strings.RegistrationLabel, timeToLive: 10) { (success, error) -> Void in


            
            if success {
                self.lastValidPhoneNumber = number
                self.validationButton.isEnabled = true
            } else {
                self.showBasicAlertWithTitle(Config.Strings.IncorrectPhoneNumberErrorMessage)
                self.counter = 0
                self.timer?.invalidate()
                self.codeButton!.isEnabled = true
                let title =  NSAttributedString(string: Config.Strings.GetSMSButtonLabel, attributes: [NSForegroundColorAttributeName:UIColor.white])
                self.codeButton!.setAttributedTitle(title, for: UIControlState())
            }
        }
    }
    
    func checkSMSCode() {
        guard let code = codeField.text , code.characters.count > 0 else {
            self.showBasicAlertWithTitle(Config.Strings.NoSMSCodeErrorMessage)
            return
        }
        lastValidPhoneNumber = "18510957405"
        self.signUser(lastValidPhoneNumber!, code: code)
    }
    
    func signUser(_ phone: String, code: String) {
        if phone == Config.Demo.number && code == Config.Demo.code {
            User.logInWithMobilePhoneNumber(inBackground: phone, password: code) { (user, error) -> Void in
                self.hideHUD()
                if error != nil {
                    log.error("password login error: \(error)")
                } else if let user = user as? User {
                    self.initUser(user)
                }
            }
        } else {
            User.signUpOrLoginWithMobilePhoneNumber(inBackground: phone, smsCode: code) { (user, error) -> Void in
                self.hideHUD()


                if let user = user as? User {
                    self.initUser(user)
                } else if error != nil {
                    // popup : error invalid code || error network
                    if error?.code == 603 { // AVOSCloud error code for wrong code (无效的短信验证码)
                        self.showBasicAlertWithTitle(Config.Strings.WrongSMSCodeErrorMessage)
                    } else {
                        self.showBasicAlertWithTitle(Config.Strings.NetworkErrorAlertMessage)
                    }
                }
            }
        }
    }

    
    
    fileprivate func setupNotifications() {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        notificationCenter.registerUser()
        notificationCenter.subscribeToChannel(.likeOnMyRecommendation)
        notificationCenter.subscribeToChannel(.commentOnMyRecommendation)
        notificationCenter.subscribeToChannel(.recommendationInVenueIRecommended)
        notificationCenter.subscribeToChannel(.promotedRecommendation)
        notificationCenter.subscribeToChannel(.newFollower)
        notificationCenter.subscribeToChannel(.appGeneral)
        notificationCenter.subscribeToChannel(.appEvent)
        notificationCenter.subscribeToChannel(.appStatusChange)
        notificationCenter.subscribeToChannel(.replyToComment)
        notificationCenter.subscribeToChannel(.pushRecommendationToUser)
    }
    
    
    fileprivate func initUser(_ user:User) {
        setupNotifications()
        //save udid appVersion iosVersion iphoneModel
        let currentUser = user
        currentUser.lastLoginTime = Date()
        let technicalData = TechnicalData()
        technicalData.iosVersion = UIDevice.current.systemVersion
        let infoDictionary = Bundle.main.infoDictionary
        let  appVersion:String  = infoDictionary!["CFBundleShortVersionString"] as! String
        technicalData.appVersion = appVersion
        technicalData.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        technicalData.iphoneModel =  self.device.description
        currentUser.technicalData = technicalData
        if user.username == nil || user.username == "" || user.nickname == nil || user.nickname == "" {
            currentUser.username = Config.AppConf.DefaultUsernamePrefix + user.objectId!
            currentUser.nickname = Config.AppConf.DefaultUsernamePrefix + String(Int.random(8))
            technicalData.saveInBackground({ (success, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    currentUser.saveEventually()
                }
            })
            backController()
        } else {
            technicalData.saveInBackground({ (success, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    currentUser.saveEventually()
                }
            })
           backController()
        }
    }
    
    fileprivate func checkUser() {
        if let _ = User.current() {
            delay(0.1) {
                self.backController()
            }
        }
    }
    
    func dismissTextFields() {
        self.view.endEditing(true)
    }
    func showBasicAlertWithTitle(_ title:String){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: title, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func firstLoginAddDefaultFriends(){
        guard let user = User.current() else {return}
        if (user.createdAt?.timeIntervalSinceNow)! * -1 < 5.0{//first login
            // add three default friends
            user.follow(Config.Strings.ZanaduTravelLife, andCallback: { (success, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {

                }
            })
            user.follow(Config.Strings.Zanadu, andCallback: { (success, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {

                }
            })
            user.follow(Config.Strings.Where, andCallback: { (success, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {

                }
            })
            
            
        }
        
    }
    

}
