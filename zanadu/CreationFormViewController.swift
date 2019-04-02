//
//  CreationFormViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/16/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Handle the Title + Description + Tags form
*/
class CreationFormViewController : BaseViewController, UITextFieldDelegate, UITextViewDelegate, UITagSelectionViewExpansionDelegate {
    
    //MARK: - Properties
    let descriptionPlaceholder = NSLocalizedString("Write something", comment: "写点什么...")
    var keyboardHeight: CGFloat?
    var displayAddTagView = false
    var navigationBarHeight: CGFloat = 0
    
    var placeholderLabel = UILabel()
    var categoriesArray : [Category]?
    var saveCreationTimer = Timer()

    //MARK: - Outlets
    
    @IBOutlet weak var titleField: FormTextField!
    @IBOutlet weak var descriptionTextView: FormTextView!
    weak var tagSelectionView: UITagSelectionView!

    @IBOutlet weak var selectCategoryView: UIView!
    
    
    @IBOutlet weak var checkTextfield: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var tagSelectionVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagSelectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    
    var backView = UIView()
    var categoryListBtn = UIButton()
    var confirmCategoryBtn = UIButton()
    //MARK: - Actions
    
    @IBAction func onNextStepButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        //TODO: add tags
        if let categorys = RecommendationFactory.sharedInstance.categorys {
            
            if categorys.count > 0 {
                let descText = descriptionTextView.text == descriptionPlaceholder ? "" : descriptionTextView.text
                RecommendationFactory.saveStepOne(titleField.text!, text: descText!, tags: tagSelectionView.getTags())
                self.performSegue(withIdentifier: "showCreationPreviewScreen", sender: self)

            }
            else{
                let tips = NSLocalizedString("Please select one to two categories", comment:"请选择一到两个类别")
                JLToast.makeText(tips, duration: JLToastDelay.ShortDelay).show()
            }
        }else{
            let tips = NSLocalizedString("Please select one to two categories", comment:"请选择一到两个类别")
            JLToast.makeText(tips, duration: JLToastDelay.ShortDelay).show()
        }
        
        sender.isEnabled = true
}
    
    //MARK: - Methods
    

    //MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()

        if let _ = RecommendationFactory.sharedInstance.venue {
            
        }else{
            
            let backButton = UIButton(type: .custom)
            backButton.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
            backButton.backgroundColor = UIColor.clear
            backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
            backButton.setTitle(NSLocalizedString("Give up", comment:"放弃"), for: UIControlState())
            backButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
            backButton.addTarget(self, action: #selector(CreationFormViewController.giveUpButtonClick), for: .touchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
            DraftManager.buildFactoryAndDraftArray()
            DraftManager.reSetRecommendationFactory()
        }
        self.perform(#selector(CreationFormViewController.loadSaveTimer), with: nil, afterDelay: 1)

        
        Foundation.UserDefaults.standard.set("threeStep", forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
        
        view.backgroundColor = UIColor.white
        navigationController?.view.backgroundColor = UIColor.white
        
        titleField.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        titleField.tintColor = Config.Colors.ZanaduCerisePink

        titleField.attributedPlaceholder = NSAttributedString(string: titleField.placeholder!, attributes: [NSForegroundColorAttributeName: Config.Colors.LightGreyTextColor])
        descriptionTextView.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
//        descriptionTextView.text = descriptionPlaceholder

        titleField.layer.cornerRadius = Config.AppConf.SmallCornerRadiusFactor
        nextButton.backgroundColor = Config.Colors.ZanaduCerisePink
        tagSelectionView.expansionDelegate = self
        tagSelectionView.setup()
        

        
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: descriptionTextView, action: #selector(UIResponder.resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        barButton.tintColor = Config.Colors.ZanaduCerisePink
        toolbar.items = [barButton]
        
        descriptionTextView.inputAccessoryView = toolbar
        descriptionTextView.tintColor = Config.Colors.ZanaduCerisePink
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8)

        placeholderLabel.text = descriptionPlaceholder
        placeholderLabel.font = UIFont.systemFont(ofSize: descriptionTextView.font!.pointSize)
        placeholderLabel.sizeToFit()
        descriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 12, y: 12)
        placeholderLabel.textColor = Config.Colors.LightGreyTextColor
        placeholderLabel.isHidden = descriptionTextView.text.characters.count != 0
        
        
        selectCategoryView.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        categoryListBtn.backgroundColor = UIColor.clear
        categoryListBtn.frame = CGRect(x: 0, y: 7, width: 30, height: 30)
        categoryListBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        categoryListBtn.setBackgroundImage(UIImage(named: "down_white"), for: UIControlState())
        categoryListBtn.addTarget(self, action: #selector(CreationFormViewController.showCategory(_:)), for: .touchUpInside)
        
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 12, height: 20)
        leftView.backgroundColor = UIColor.clear
        checkTextfield.leftView = leftView
        checkTextfield.leftViewMode = .always
        checkTextfield.rightView = categoryListBtn
        checkTextfield.rightViewMode = .always
        checkTextfield.delegate = self
        
        checkTextfield.text = NSLocalizedString("Choose category", comment:"选择分类")


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("Edit", comment: "编辑")
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        if let title = RecommendationFactory.sharedInstance.recommendation?.title {
            titleField.text = title
        }
        
        if let description = RecommendationFactory.sharedInstance.recommendation?.text {
            descriptionTextView.text = description
            placeholderLabel.isHidden = descriptionTextView.text.characters.count != 0

        }
        
        // register to keyboard notifications
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(CreationFormViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object:nil)
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(CreationFormViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object:nil)
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(CreationFormViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    func setNav() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        backButton.backgroundColor = UIColor.clear
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setImage(UIImage(named: "backIcon"), for: UIControlState())
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setTitle(NSLocalizedString("Back", comment:"返回"), for: UIControlState())
        backButton.addTarget(self, action: #selector(CreationFormViewController.backButtonClick), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
    }
    func backButtonClick(){
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextButton.addGradientWithColors(Config.Colors.ButtonGradient)
        if let tags = RecommendationFactory.sharedInstance.tags {
            tagSelectionView.setTags(tags)
        }
        let listView = CategoryListsView()
        listView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 130, height: 410)
        listView.center = self.view.center
        listView.currType = .hasTitleView
        listView.categoryArray = self.categoriesArray!
        listView.initWithType()
        listView.delegate = self
        
        backView.frame = CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //backView.center = self.view.center
        backView.addSubview(listView)
        backView.backgroundColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.6)
        self.view.addSubview(backView)
        self.view.bringSubview(toFront: backView)
        backView.isHidden = true
        var checkText = NSLocalizedString("Choose category", comment:"选择分类")
        
        if let categorys = RecommendationFactory.sharedInstance.categorys{
            
            for (index,category) in categorys.enumerated() {
                if index == 0 {
                    checkText = "" + category.name}
                else {
                    checkText += " ，" + category.name
                }
            }
            
        }
        checkTextfield.text = checkText
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTimerInvalidate()
        Foundation.NotificationCenter.default.removeObserver(self)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreationPreviewScreen" {
            let destinationVC = segue.destination as? CreationPreviewViewController
            setTimerInvalidate()
        }
    }
    
    func  giveUpButtonClick() {
        RecommendationFactory.createEmpty()
        setTimerInvalidate()
        self.navigationController?.popViewController(animated: true)
        DraftManager.removeDraftFromSandBox()
        Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        RecommendationFactory.sharedInstance.recommendation?.title=titleField.text
        
        descriptionTextView.becomeFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == checkTextfield {
            showCategory(categoryListBtn)
            return false
        }
        return true
    }
    //MARK: - UITextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.characters.count != 0

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        RecommendationFactory.sharedInstance.recommendation?.text = descriptionTextView.text

    }
    
    //MARK: - UIKeyboard Notification Handlers

    func keyboardWillShow(_ notification: Foundation.Notification) {

        bottomView.isHidden = true
    }
    
    func keyboardWasShown(_ notification: Foundation.Notification) {

        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            
            self.keyboardHeight = keyboardSize.height
            
            if !titleField.isFirstResponder && !descriptionTextView.isFirstResponder {
                self.expandTagSelectionView()
            }
        }
    }
    
    func keyboardWillHide(_ notification: Foundation.Notification) {
        if self.displayAddTagView {
            reduceTagSelectionView()
        }
        
        bottomView.isHidden = false
    }
    

    //MARK: - UITagSelectionViewExpansion Delegate

    func expandTagSelectionView() {
        selectCategoryView.isHidden = true
        if keyboardHeight == nil {
            return
        }

//        self.navigationController?.navigationBarHidden = true
        self.displayAddTagView = true
        if self.navigationBarHeight == 0 {
            self.navigationBarHeight = self.navigationController!.navigationBar.frame.origin.y

        }
        
        let statuesbarMargin:CGFloat = 20
        //self.setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.navigationController?.navigationBar.frame.origin.y = -self.navigationController!.navigationBar.frame.height
            self.tagSelectionVerticalSpacingConstraint.constant = -self.descriptionTextView.bounds.height - self.descriptionTextView.frame.origin.y + Config.AppConf.StatusBarHeight + statuesbarMargin
            self.tagSelectionHeightConstraint.constant = self.view.frame.height
            self.tagSelectionView.recentTagView.alpha = 1
            self.tagSelectionView.popularTagView.alpha = 1
        })
    }
    
    func reduceTagSelectionView() {
        selectCategoryView.isHidden = false


        self.displayAddTagView = false

        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.tagSelectionView.recentTagView.alpha = 0
            self.tagSelectionView.popularTagView.alpha = 0
            self.tagSelectionHeightConstraint.constant = 60
            self.navigationController?.navigationBar.frame.origin.y = self.navigationBarHeight
            self.tagSelectionVerticalSpacingConstraint.constant = 8
        })
    }
    
    
    func showCategory(_ sender : UIButton) {
        
        nextButton.isHidden = true
        
        backView.isHidden = false
        
        confirmCategoryBtn.frame = CGRect(x: 15, y: UIScreen.main.bounds.height - 130, width: UIScreen.main.bounds.width - 30, height: 50)
        confirmCategoryBtn.setTitle(NSLocalizedString("Sure", comment: "确定"), for: UIControlState())
        self.view.addSubview(confirmCategoryBtn)
        confirmCategoryBtn.layer.cornerRadius = 5
        confirmCategoryBtn.layer.borderWidth = 1
        confirmCategoryBtn.backgroundColor = UIColor.clear
        confirmCategoryBtn.addTarget(self, action: #selector(CreationFormViewController.saveCategory(_:)), for: .touchUpInside)
        confirmCategoryBtn.setTitleColor(UIColor(bd_hexColor : "5f5d5b"), for:.normal)
        confirmCategoryBtn.isHidden = false
        var  styleFlage = false
        if let historyCategorys = RecommendationFactory.sharedInstance.categorys {
            styleFlage = historyCategorys.count > 0 ? true : false
        }
        setConfirmButtonStyle(styleFlage)
        
    }
}
extension CreationFormViewController : CategoryListsViewDelegate{
    func didSelectCategoryListsRowCallBack(_ categorys : [Category]){
        RecommendationFactory.sharedInstance.categorys = categorys
        let styleFlage = categorys.count > 0 ? true : false
        
        setConfirmButtonStyle(styleFlage)
        var checkText = NSLocalizedString("Choose category", comment:"选择分类")
        
        for (index,category) in categorys.enumerated() {
            if index == 0 {
                checkText = "" + category.name}
            else {
                checkText += " ，" + category.name
            }
        }
        checkTextfield.text = checkText
        draftTimer()
    }
    func saveCategory(_ sender: UIButton) {
        sender.isHidden = true
        nextButton.isHidden = false
        backView.isHidden = true
    }
    
    func setConfirmButtonStyle(_ highlied : Bool) {
        if highlied{
            confirmCategoryBtn.isEnabled = true
            confirmCategoryBtn.backgroundColor = Config.Colors.ZanaduCerisePink
            confirmCategoryBtn.layer.borderColor = UIColor.clear.cgColor
            confirmCategoryBtn.setTitleColor(UIColor.white, for: UIControlState())

        }else{
            confirmCategoryBtn.isEnabled = false
            confirmCategoryBtn.layer.borderColor = UIColor(bd_hexColor : "5f5d5b").cgColor
            confirmCategoryBtn.setTitleColor(UIColor(bd_hexColor : "5f5d5b"), for:.normal)
            confirmCategoryBtn.backgroundColor = UIColor.clear
            
        }
    }
   
}

extension CreationFormViewController{//draft

    func draftTimer(){
        let state = nextButton.isEnabled
        if !state{
            return
        }
        let descText = descriptionTextView.text == descriptionPlaceholder ? "" : descriptionTextView.text
        let title = titleField.text!.characters.count > 0 ? titleField.text! : ""

        RecommendationFactory.saveStepOne(title, text: descText!, tags: tagSelectionView.getTags())
        DraftManager.refreshSandboxData()
        DraftManager.saveDraftToSandBox(RecommendationFactory.sharedInstance.draftArray)

    }
    func setTimerInvalidate(){
        self.saveCreationTimer.invalidate()
    }
    func loadSaveTimer(){
               
        saveCreationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(CreationFormViewController.draftTimer), userInfo: nil, repeats: true)
        saveCreationTimer.fire()
    }

    
}
