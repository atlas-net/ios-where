//
//  SettingsAboutViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/4/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


//import DOAlertController

/**
SettingsMainViewController

Settings main panel, from there you can access all the other settings FormViewControllers
*/
class SettingsAboutViewController : FormViewController {
    
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
        instance.placeholder("小手50M")
        instance.onItemTapped = { Void in
            self.showClearCacheAlert()
        }
        return instance
        }()
    
    //MARK: - Outlets
    
    //MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = NSLocalizedString("About", comment:"关于")
    }
    
    //MARK: - Actions
    
    func onLogoutButtonTapped() {
        User.logOut()
        Router.redirectToWelcomeViewController(fromViewController: self)
    }
    
    //MARK: - Methods
    
    func showClearCacheAlert() {
        // Set title, message and alert style
        let alertController = DOAlertController(title: NSLocalizedString("Clear cache", comment:"清除缓存"), message: NSLocalizedString("Are you sure you want to clear the cache?", comment:"确定要清除缓存吗?"), preferredStyle: DOAlertControllerStyle.alert)
        
        // Create the action.
        let cancelAction = DOAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: .cancel, handler: nil)
        
        // You can add plural action.
        let okAction = DOAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: .default) { (action) -> Void in
            AVQuery.clearAllCachedResults()
        }
        
        // Style
        alertController.alertViewBgColor = Config.Colors.TagViewBackground
        alertController.titleTextColor = UIColor.white
        alertController.messageTextColor = Config.Colors.LightGreyTextColor
        
        // Add the action.
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // Show alert
        present(alertController, animated: true, completion: nil)
    }
    
    override internal func populate(_ builder: FormBuilder) {
        var version = ""
        if let nsObject: AnyObject = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject? {
            if let versionStr = nsObject as? String {
                version = versionStr
            }
        }
        
        builder += StaticTextFormItem().title("已经是最新\(version)版本")
        
        
//        //builder += ViewControllerFormItem().title("修改密码")
//        
//        builder += SectionHeaderTitleFormItem().title(NSLocalizedString("System settings", comment:"系统设置"))
//        builder += ViewControllerFormItem().title(NSLocalizedString("Message notification", comment:"消息提醒")).viewController(SettingNotificationViewController.self)
//        //builder += ViewControllerFormItem().title("隐私设置")
//        builder += clearCacheViewController
//        
//        builder += SectionHeaderTitleFormItem().title(NSLocalizedString("Support", comment:"支持"))
//        builder += ViewControllerFormItem().title(NSLocalizedString("About", comment:"关于"))
//        builder += ViewControllerFormItem().title(NSLocalizedString("Privacy Policy and Terms of Service", comment:"隐私政策与服务条款"))
//        
//        builder += SectionHeaderTitleFormItem()
//        builder += logoutButton
        
    }
    
    
    //MARK: - ViewController's Lifecycle
}
