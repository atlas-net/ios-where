//
//  SettingsUserViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/4/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
SettingsUserViewController

User related settings panel
*/
class SettingsUserViewController : FormViewController {
    
    //MARK: - Properties
    
    
    lazy var userName: TextFieldFormItem = {
        let user = User.current()
        let instance = TextFieldFormItem()
        instance.title(NSLocalizedString("Nickname", comment: "")).placeholder(NSLocalizedString("Required", comment: ""))
        instance.keyboardType = UIKeyboardType.default
        instance.autocorrectionType = .no
        if let nickname = (user as? User)?.nickname {
            instance.value = nickname
        }
        instance.submitValidate(CountSpecification.min(Config.FormValidation.UsernameMinCharacters), message: "最少\(Config.FormValidation.UsernameMinCharacters)个字符")
        
        
        instance.submitValidate(CountSpecification.max(Config.FormValidation.UsernameMaxCharacters), message: "不超过\(Config.FormValidation.UsernameMaxCharacters)个字符")
        return instance
        }()
    
    lazy var userMessage: TextFieldFormItem = {
        let user = User.current()
        let instance = TextFieldFormItem()
        instance.title(NSLocalizedString("Introduction", comment: "")).placeholder(NSLocalizedString("Option", comment: ""))
        instance.keyboardType = UIKeyboardType.default
        instance.autocorrectionType = .default
        if let message = (user as? User)? .message {
            instance.value = message
        }
        instance.submitValidate(CountSpecification.min(Config.FormValidation.UserMessageMinCharacters), message: "最少\(Config.FormValidation.UserMessageMinCharacters)个字符")
        instance.submitValidate(CountSpecification.max(Config.FormValidation.UserMessageMaxCharacters), message: "不超过\(Config.FormValidation.UserMessageMaxCharacters)个字符")
        return instance
        }()
    
    lazy var validateButton: ButtonFormItem = {
        let instance = ButtonFormItem()
        instance.title(NSLocalizedString("Save", comment: "保存"))
        instance.colors = Config.Colors.ButtonGradient
        instance.action = { [weak self] in
            self?.onValidateButtonTapped()
        }
        return instance
        }()
    
    lazy var changeAvatarButton: ButtonFormItem = {
        let instance = ButtonFormItem()
        instance.title(NSLocalizedString("Change your avatar", comment: "更改头像"))
//        instance.colors = Config.Colors.ButtonGradient
        instance.action = { [weak self] in
            self?.onChangeAvatarButtonPressed()
        }
        return instance
        }()
    
    lazy var changeCoverButton: ButtonFormItem = {
        let instance = ButtonFormItem()
        instance.title(NSLocalizedString("Change background", comment: "更改背景"))
//        instance.colors = Config.Colors.ButtonGradient
        instance.action = { [weak self] in
            self?.onChangeCoverButtonPressed()
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
        self.navigationItem.title = NSLocalizedString("Personal information", comment:"个人信息")
    }
    
    //MARK: - Actions
    
    func onChangeAvatarButtonPressed() {
        Router.redirectToPhotoLibraryController(.userAvatar, fromViewController: self)
    }

    func onChangeCoverButtonPressed() {
        Router.redirectToPhotoLibraryController(.userCover, fromViewController: self)
    }

    func onValidateButtonTapped() {
        formBuilder.validateAndUpdateUI()
        let result = formBuilder.validate()
        
        var shouldSave = false
        guard let user = User.current() as? User else{
            return
        }

        if userName.value != user.nickname {
            shouldSave = true
        }
        if userMessage.value != user.message {
            shouldSave = true
        }
        switch result {
        case .valid:
            if shouldSave {
                user.nickname = userName.value
                user.message = userMessage.value
                user.saveInBackground({ (success, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        self.showChangeAlert()
                    }
                })
            }
        default:
            return
        }
    }
    
    
    //MARK: - Methods
    
    func showChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "保存成功", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
                        self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override internal func populate(_ builder: FormBuilder) {
        builder += SectionHeaderTitleFormItem().title("")
        builder += userName
        builder += userMessage
        builder += validateButton
        builder += SectionHeaderTitleFormItem().title("")
        builder += changeAvatarButton
        builder += changeCoverButton
        builder.alignLeft([userName, userMessage])
//        builder += ViewControllerFormItem().title(NSLocalizedString("Change your avatar", comment: "更改头像")).viewController(PhotoLibraryController.self)
//        builder += ViewControllerFormItem().title(NSLocalizedString("Change background", comment: "更改背景")).viewController(PhotoLibraryController.self)
    }
    
    
    //MARK: - ViewController's Lifecycle
}
