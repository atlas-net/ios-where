//
//  SettingsMainViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/4/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import Alamofire
/**
SettingsMainViewController

Settings main panel, from there you can access all the other settings FormViewControllers
*/
class SettingsMainViewController :FormViewController {

    //MARK: - Properties
    
    lazy var logoutButton: ButtonFormItem = {
        let instance = ButtonFormItem()
        instance.title(NSLocalizedString("Logout", comment:"退出"))
        instance.colors = Config.Colors.ButtonGradient
        instance.action = { [weak self] in
            self?.onLogoutButtonTapped()
        }
        return instance
        }()
    
    lazy var clearCacheViewController: ViewControllerFormItem = {
        let instance = ViewControllerFormItem()
        instance.title(NSLocalizedString("Clear cache", comment:"清除缓存"))
        
        let size = ImageCacheManager.totalSize()
        instance.placeholder("\(size / 1024 / 1024)M")
        instance.onItemTapped = { Void in
            self.showClearCacheAlert()
        }
        return instance
    }()
    
    //MARK: - Outlets
    
    //MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        Router.Storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.setupNav()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //MARK: - Actions
    
    func onLogoutButtonTapped() {
        
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "确定要退出吗？", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            User.logOut()
            self.navigationController?.dismiss(animated: true, completion: { 
                
            })
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //MARK: - Methods
    func setupNav(){
        self.navigationItem.title = NSLocalizedString("Setting", comment: "设置")
    }
    func showClearCacheAlert() {
        
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message:NSLocalizedString("Are you sure you want to clear the cache?", comment:"确定要清除缓存吗?"), preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            AVQuery.clearAllCachedResults()
            Alamofire.URLCache.shared.removeAllCachedResponses()
            ImageCacheManager.clearCache()
            self.clearCacheViewController.placeholder("0M")
            self.clearCacheViewController.syncCellWithValue("0M")
            delay(1) {
                ImageCacheManager.clearCache()
            }
            delay(3) {
                ImageCacheManager.clearCache()
            }

        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override internal func populate(_ builder: FormBuilder) {
        
        builder += oneSectionTitle
        builder += ViewControllerFormItem().title(NSLocalizedString("Personal information", comment:"个人信息")).viewController(SettingsUserViewController)
        //builder += ViewControllerFormItem().title("修改密码")
        
        builder += SectionHeaderTitleFormItem().title(NSLocalizedString("System settings", comment:"系统设置"))
        builder += ViewControllerFormItem().title(NSLocalizedString("Message notification", comment:"消息提醒")).viewController(SettingNotificationViewController.self)
        //builder += ViewControllerFormItem().title("隐私设置")
        builder += clearCacheViewController
        
        builder += SectionHeaderTitleFormItem().title(NSLocalizedString("Support", comment:"支持"))
        builder += ViewControllerFormItem().title(NSLocalizedString("About", comment:"关于")).viewController(SettingsAboutViewController)
        builder += ViewControllerFormItem().title(NSLocalizedString("Privacy Policy and Terms of Service", comment:"隐私政策与服务条款")).viewController(PolicyAndServiceViewController)
        
        let contractUs = ViewControllerFormItem().title(NSLocalizedString("Contact us", comment:"联系我们"))
        contractUs.onItemTapped = { Void in
            let alertCtrl = UIAlertController(title:NSLocalizedString("Contact Zanadu", comment:"联系赞那度"), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Outbound tourism", comment: "出境旅游")+":021-6330-0350", style: .default, handler: { (_) in
                UIApplication.shared.openURL(URL(string: "tel:021-6330-0350")!)
            }))
            alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Domestic short holiday / hotel", comment: "国内短假/酒店")+":400-6790-089", style: .default, handler: { (_) in
                UIApplication.shared.openURL(URL(string: "tel:400-6790-089")!)
            }))
            alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("AD Cooperation", comment: "广告合作")+"：ad@zanadu.cn", style: .default, handler: { (_) in
                UIApplication.shared.openURL(URL(string: "mailto:ad@zanadu.cn")!)
            }))
            alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: .cancel, handler: nil))
            self.present(alertCtrl, animated: true, completion: nil)
        }
        builder += contractUs
        
        builder += SectionHeaderTitleFormItem()
        builder += logoutButton

    }
    lazy var oneSectionTitle: SectionHeaderTitleFormItem = {
      let instance = SectionHeaderTitleFormItem()
         instance.title = NSLocalizedString("Personal settings", comment:"个人设置")
        return instance
    }()
    
    //MARK: - ViewController's Lifecycle
}
