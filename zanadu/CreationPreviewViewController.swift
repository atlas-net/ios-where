//
//  CreationPreviewViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import MBProgressHUD

class CreationPreviewViewController: BaseViewController {

    let defaultImage = UIImage(named: "itemDefaultImage")
    
    //MARK: - Properties
    lazy var currentRecommendationState: RecommendationState = RecommendationState(title: RecommendationStateTitle.Initial.rawValue, recommendationData: RecommendationData())
    var careTaker: CareTaker!
    let descriptionPlaceholder = Config.Strings.descriptionFieldPlaceholder
    var keyboardHeight: CGFloat?
    var shouldHideStatusBar = false
    var navigationBarHeight: CGFloat = 0
    var loadingV = LoadingView()
    var recommendation: Recommendation?
    var listItems = [ListItem]()
    var cropRects = [CGRect?]()
    var coverImage = UIImage()
    var layoutView: GenericLayoutView<UIView>!
    var photoTableView = PhotoTableView()
    var  coverRect = CGRect.zero
    var  coverPhoto = Photo()
    var isNowEditing = false
    var descriptionUnfoldBtn = UIButton()
    var shareView:ShareView?
    var deleteComment:Comment?
    var nextButtonFinished = true
    var isLocationButtonInitialized = false
    var categoriesArray = [Category]()
    var replyAuthor:User?
    var isKeyBoardShown = false
    var photosLoadNum = 0
    var selectedCommentDistance:CGFloat = 0
    var saveTimer = Timer()
    
    var tmpCaptionArray = [String]()
    var tmpTags  = [Tag]()
    //MARK: - Outlets
    @IBOutlet weak var sendContainsView: SendView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var coverImageScrollView: ImageCropView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var descriptionField: UITextView!
    weak var tagSelectionView: UITagSelectionView!
    weak var bottomBar: UIView!
    fileprivate var isBottomBarShow = false
    @IBOutlet weak var bottomBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var addImageBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeCoverBtn: UIButton!
    
    //genericLayoutContainer
    @IBOutlet weak var genericLayoutContainer: UIView!
    @IBOutlet weak var genericLayoutContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainScrollViewTopDistanceConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoLayoutHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrolledViewHeightConstraint: NSLayoutConstraint!
    
   @IBOutlet weak var commentsView: CommentStreamView!
    
    @IBOutlet weak var coverPhotoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var authorImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var authorNameTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var authorNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionFieldHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionFieldBottomConstraint: NSLayoutConstraint!
    
    //tag
    @IBOutlet weak var tagSelectionVerticalSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagSelectionHeightConstraint: NSLayoutConstraint!
    
    //commentView
    @IBOutlet weak var commentsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsViewHeightConstraint: NSLayoutConstraint!
    //likeView
    
    @IBOutlet weak var likeView: LikeView!
    @IBOutlet weak var likeViewTopConstraint: NSLayoutConstraint!
    
    //other
    @IBOutlet weak var authorImage: UIImageView!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var moreAndSaveButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var toCommentButton: UIButton!
    @IBOutlet weak var toCommentButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var titleFiledTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextFiled: UITextField!
    @IBOutlet weak var commentTextView: UIView!
    
    
    
    //MARK: - Actions
    @IBAction func toCommentButtonClick() {
        if let _ = AVUser.current(){
            self.commentTextView.isHidden = false
            commentTextFiled.placeholder = NSLocalizedString("Comment", comment: "评论")
            self.commentTextFiled.becomeFirstResponder()
        }else{
            Router.redirectToLoginViewController(fromViewController: self)
        }
    }
    
    func changeNavMode() {
        let moreImage = UIImage(named: "more")
        if isNowEditing{
            self.shareButton.isHidden = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancle", comment: "取消"), style: .plain, target:self, action:  #selector(CreationPreviewViewController.cancelButtonClick))
            self.moreAndSaveButton.setImage(nil, for: UIControlState())
            self.moreAndSaveButton.setTitle(NSLocalizedString("Save", comment: "保存"), for: UIControlState())
            self.moreAndSaveButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
        }else{
            self.shareButton.isHidden = false
            self.navigationItem.leftBarButtonItem = nil
            self.moreAndSaveButton.setImage(moreImage, for: UIControlState())
            self.moreAndSaveButton.setTitle("", for: UIControlState())
            self.moreAndSaveButton.titleLabel?.text = ""
            self.moreAndSaveButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
        }
    }
    @IBAction func moreAndSaveButtonClick() {
        if self.moreAndSaveButton.titleLabel?.text != NSLocalizedString("Save", comment: "保存"){
      let  moreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("Cancle", comment: "取消"), destructiveButtonTitle: nil, otherButtonTitles: NSLocalizedString("Edit", comment: "编辑"),NSLocalizedString("Delete", comment: "删除") )
        moreSheet.show(in: self.view)
        }else{
            saveButtonClick()
        }
  }
    @IBAction func shareButtonClick() {
        self.shareView?.isHidden = false
    }
    
     func cancelButtonClick() {
        self.isNowEditing = false
        self.changeNavMode()
        currentRecommendationState = careTaker.restore(0)!
        self.titleField.text = currentRecommendationState.getData().title
        setDescAttributeText(currentRecommendationState.getData().text)
        self.titleField.resignFirstResponder()
        self.descriptionField.resignFirstResponder()
        self.tagSelectionView.inputTagView._tagField.resignFirstResponder()
        self.tagSelectionView.isShowDeleteBtn = false
        self.tagSelectionView.setup(self)
        self.tagSelectionView.inputTagView.editable = false
        self.tagSelectionView.backgroundColor = UIColor.clear
        self.tagSelectionView.inputTagView.backgroundColor = UIColor.clear
        delay(0.5) {
            self.tagSelectionView.setTagsWithNoDelegateAdd(self.currentRecommendationState.getData().tags)
            self.tagSelectionView.inputTagView._tagField._scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        if self.currentRecommendationState.getData().tags.count <= 0 {
            self.tagSelectionHeightConstraint.constant = 0
        }
        
        coverImageScrollView!.setup(coverImage, tapDelegate: self)
        if self.coverRect.origin.x < 20 && self.coverRect.origin.x > 0.2 && coverRect.origin.y > 250{
             self.coverImageScrollView.setCrop(self.coverRect)
        }else{
            self.coverImageScrollView.display()
        }
        self.coverImageScrollView.editable = false
        self.overlayView.isHidden = false
        self.changeCoverBtn.isHidden = true
        self.addImageBtn.isHidden = true
        self.authorName.isHidden = false
        self.authorImage.isHidden = false
        self.commentsView.isHidden = false
        self.titleField.isEnabled = false
        self.likeView.isHidden = false
        self.descriptionField.backgroundColor = UIColor.clear
        self.descriptionField.isEditable = false
        self.toCommentButton.isHidden = false
        self.photoTableView.photos.removeAll()
        self.photoTableView.photoImages.removeAll()
        self.photoTableView.reloadData()
        self.photoTableView.sortPhotoImages.removeAll()
        self.photoTableView.photos = self.currentRecommendationState.getData().photos
        self.photoTableView.isCellEditable = false
        self.photoTableView.isShowCellDelete = false
        self.photoTableView.dataQuery()
        
        let str = self.currentRecommendationState.getData().venue.customName!
        self.locationButton.setTitle("  \(str) ", for: UIControlState())
        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
    }
    
     func saveButtonClick() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.show(animated: true)
         self.navigationItem.leftBarButtonItem?.isEnabled = false
        guard let originalState = careTaker.restore(0) else {
            return
        }
        
        currentRecommendationState.getData().tags = self.tagSelectionView.getTags()
        
        guard let recommendation = self.recommendation else {
            hud.hide(animated: true)
            showBasicAlertWithTitle("保存失败,请重试")
            return
        }
        
        var expectedSaves = 3 + currentRecommendationState.getData().tags.count // 3 == venue + cover + photos
        var currentSaves = 0
        

        // Save tags
        
        if currentRecommendationState.getData().tags != originalState.getData().tags {
            recommendation.tags = nil
            
            for tag in currentRecommendationState.getData().tags {
                tag.saveInBackground({ (success, error) -> Void in
                    if success {
                        recommendation.addTag(tag)

                        currentSaves += 1
                        if currentSaves == expectedSaves {
                            RecommendationFactory.saveRecommendation(recommendation) { (success) -> () in
                                if success {
                                    hud.hide(animated: true)
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    hud.hide(animated: true)
                                    self.showBasicAlertWithTitle("保存失败,请重试")
                                }
                            }
                        }
                    } else if error?.code == 137 { // already exist
                        DataQueryProvider.tagQueryForName(tag.name).executeInBackground { (object: Any?, error) -> () in
                            if error != nil {
                                hud.hide(animated: true)
                                self.showBasicAlertWithTitle("保存失败,请重试")
                            } else if let fetchedTag = object as? Tag {
                                recommendation.addTag(fetchedTag)

                                currentSaves += 1
                                if currentSaves == expectedSaves {
                                    RecommendationFactory.saveRecommendation(recommendation) { (success) -> () in
                                        if success {
                                            hud.hide(animated: true)
                                            self.navigationController?.popViewController(animated: true)
                                        } else {
                                            hud.hide(animated: true)
                                            self.showBasicAlertWithTitle("保存失败,请重试")
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        } else {
            expectedSaves -= currentRecommendationState.getData().tags.count
        }
        
        // Save venue
        if recommendation.venue != currentRecommendationState.getData().venue {
            recommendation.venue = currentRecommendationState.getData().venue
            recommendation.venue!.saveInBackground { (success, error) -> Void in
                if error != nil {
                    hud.hide(animated: true)
                    self.showBasicAlertWithTitle("保存失败,请重试")
                } else {

                    currentSaves += 1
                    if currentSaves == expectedSaves {
                        RecommendationFactory.saveRecommendation(recommendation) { (success) -> () in
                            if success {
                                hud.hide(animated: true)
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                hud.hide(animated: true)
                                self.showBasicAlertWithTitle("保存失败,请重试")
                            }
                        }
                    }
                }
            }
        } else {
            currentSaves += 1
        }
        
        
        recommendation.title = self.titleField.text
        recommendation.text = self.descriptionField.text
        
        //save every Photo's description
        self.photoTableView.saveDescription()
        //getAndSavePhotosCaptions
        let captions = photoTableView.getCaptions()
        for (index, photo) in currentRecommendationState.getData().photos.enumerated() {
            photo.rsort = index as NSNumber?
            photo.caption = captions[index]
        }
        // Save photos
            recommendation.photos = nil
            self.currentRecommendationState.getData().savePhotos { (success) in
                if success{
                recommendation.addPhotos(self.currentRecommendationState.getData().photos)
                    currentSaves += 1
                    if currentSaves == expectedSaves {
                        RecommendationFactory.saveRecommendation(recommendation) { (success) -> () in
                            if success {
                                hud.hide(animated: true)
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                hud.hide(animated: true)
                                self.showBasicAlertWithTitle("保存失败,请重试")
                            }
                        }
                    }
                    
                }else{
                    hud.hide(animated: true)
                    self.showBasicAlertWithTitle("保存失败,请重试")
                    
                }
        }

        self.coverPhoto.setCropRect(self.coverImageScrollView.cropRect())
        recommendation.cover = self.coverPhoto
        
        // Save cover
        self.coverPhoto.saveInBackground({ (bool, error) -> Void in
            if error != nil {
                hud.hide(animated: true)
                self.showBasicAlertWithTitle("保存失败,请重试")
            } else {

                currentSaves += 1
                if currentSaves == expectedSaves {
                    RecommendationFactory.saveRecommendation(recommendation) { (success) -> () in
                        if success {
                            hud.hide(animated: true)
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            hud.hide(animated: true)
                            self.showBasicAlertWithTitle("保存失败,请重试")
                        }
                    }
                }
            }
        })

    }
    
    
     func editButtonClick() {
        self.isNowEditing = true
        self.changeNavMode()
        self.toCommentButton.isHidden = true
        self.tagSelectionView.inputTagView.editable = true
        self.tagSelectionView.isShowDeleteBtn = true
        self.tagSelectionView.setup(self)
        self.tagSelectionView.inputTagView.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        self.tagSelectionView.backgroundColor = UIColor.clear
        delay(0.5) {
            self.tagSelectionView.setTagsWithNoDelegateAdd(self.currentRecommendationState.getData().tags)
            self.tagSelectionView.inputTagView._tagField._scrollView.setContentOffset(CGPoint.zero, animated: true)
        }

        self.coverImageScrollView.editable = true
        self.overlayView.isHidden = true
        self.changeCoverBtn.isHidden = false
        self.addImageBtn.isHidden = false
        self.authorName.isHidden = true
        self.authorImage.isHidden = true
        self.commentsView.isHidden = true
        self.descriptionField.isEditable = true
        self.descriptionField.isScrollEnabled = true
        self.descriptionField.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        titleField.isEnabled = true
        self.likeView.isHidden = true
        self.shareView?.isHidden = true
        self.photoTableView.isCellEditable = true
        self.photoTableView.isShowCellDelete = true
        self.photoTableView.reloadData()
        self.photoTableView.calculateTotalHeight(IndexPath.init(item: 0, section: 1))
        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
    }
    
    @IBAction func changeCoverBtnClick(_ sender: UIButton) {
        let photoLibraryVc = storyboard!.instantiateViewController(withIdentifier: "PhotoLibraryController") as! PhotoLibraryController
        photoLibraryVc.target = PhotoLibraryTarget.recommendationCover
        photoLibraryVc.delegate = self
        self.navigationController?.pushViewController(photoLibraryVc, animated: true)
        
    }
    
    @IBAction func addImageBtnClick(_ sender: UIButton) {
        let photoLibraryVc = storyboard!.instantiateViewController(withIdentifier: "PhotoLibraryController") as! PhotoLibraryController
        photoLibraryVc.target = PhotoLibraryTarget.recommendationAddPhoto
        photoLibraryVc.delegate = self
        photoLibraryVc.isFromRecommendation = true
        photoLibraryVc.limitPhotoCount = Config.AppConf.MaxPhotoPerRecommendation
        photoLibraryVc.limitPhotoCount -= self.currentRecommendationState.getData().photos.count
        self.navigationController?.pushViewController(photoLibraryVc, animated: true)
    }

    @IBAction func onNextStepButtonPressed(_ sender: UIButton) {
        showHUD()
        guard nextButtonFinished else { return}
        nextButtonFinished = false
        let loadingOverlay = UIView(frame: self.view.frame)
        self.view.addSubview(loadingOverlay)
        mainScrollViewTopDistanceConstraint.constant += self.sendContainsView.frame.size.height
        RecommendationFactory.sharedInstance.recommendationSaveStatus = .saving
        self.view.bringSubview(toFront: sendContainsView)
        sendContainsView.coverImgV.image = self.coverImage
        sendContainsView.startProgeess()
        let captions = photoTableView.getCaptions()

        tagSelectionView.inputTagView.tags()

        RecommendationFactory.saveStepOne(titleField.text!,
            text: descriptionField.text,
            tags: tagSelectionView.getTags())
        RecommendationFactory.saveStepTwo(coverImageScrollView.cropRect(), 
            captions: captions)
        
        RecommendationFactory.saveStepThree({ (progress) -> () in
            self.sendContainsView.updateProgress(progress)
            }) { (success) -> () in
                self.hideHUD()
                if success {

                    self.sendContainsView.endProgress()
                    if let tags = RecommendationFactory.sharedInstance.tags{
                     LocalRecentTagsHandler().addTagIdsWithTags(tags)
                    }
                    // leancloud AVAnalytics
                    AVAnalytics.event("动态创建完成")
                    Router.redirectToSharingMethod(RecommendationFactory.sharedInstance.recommendation!, fromCreationProcess: true, fromViewController: self,WithSharingImage: self.coverImage)
                    self.nextButtonFinished = true
                    
                    RecommendationFactory.createEmpty()
                    self.setTimerInvalidate()
                    DraftManager.removeDraftFromSandBox()
                    Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
                    Foundation.UserDefaults.standard.synchronize()
                } else {
                    self.loadSaveTimer()
                    self.view.sendSubview(toBack: self.sendContainsView)
                    loadingOverlay.removeFromSuperview()
                    self.mainScrollViewTopDistanceConstraint.constant = 0
                    self.showBasicAlertWithTitle(NSLocalizedString("Loading timed out, please try again", comment:"加载超时，请重试"))
                   self.nextButtonFinished = true
                }
        }
    }
    
    func showHUD() {
        let hud =  MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.labelText = "发布中……"
    }
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    @IBAction func onLocationButtonTapped(_ sender: UIButton) {
        if self.isNowEditing{
            let vc = storyboard?.instantiateViewController(withIdentifier: "locationSearch") as! LocationSearchViewController
            vc.isFromRecommendationDetail = true
            vc.didSelectVenueDelegete = self
            navigationController?.pushViewController(vc, animated: true)
            
        }else{
        if let recommendation = recommendation {
            let vc = storyboard?.instantiateViewController(withIdentifier: "VenueHomeListingViewController") as! VenueHomeListingViewController
            vc.venue = recommendation.venue
            
            navigationController?.pushViewController(vc, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
        }
        }
    }
    
    func onOverlayTapped(_ sender: AnyObject?) {
        onImageCropViewTapped(coverImageScrollView)
    }
    
    @IBAction func backBtnClick(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func onStepOneDataChanged() {

        RecommendationFactory.saveStepOne(titleField.text!, text: descriptionField.text, tags: tagSelectionView.getTags())
    }
    func descriptionUnfoldBtnClick(){
        descriptionUnfoldBtn.isSelected = !descriptionUnfoldBtn.isSelected
        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
    }
    
    @IBAction func reportBtnClick(_ sender: UIButton) {
       self.showReportPostAlert()
        
    }
    func reportContent(){
        if let recommendation = recommendation {
            (DataQueryProvider.reportsForUser(User.current() as! User, andRecommendation: recommendation, validOnly: true) as! SimpleQuery).countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    if count == 0 {
                        let report = Report(sender: ((User.current() as? User))!, recommendation: recommendation, reason: "inapropriate content")
                        report.saveInBackground({ (success, error) -> Void in
                        })
                    } else {
                        self.showBasicAlertWithTitle("您已经举报过该条动态")
                    }
                }
            })
        }

        
    }
    func commentTextViewTap(){
         hiddenCommentView()
    }
 

    func pushSlideshowWithInitialPhotos(_ photos:[Photo], atIndex index: Int, isListItems:Bool) {
        var photoArray = [NYTCompatiblePhoto]()
        guard let recommendation = recommendation else { return }
        if !isListItems{
        if let coverPhoto = recommendation.cover{
            coverPhoto.caption = nil
            photoArray.insert(NYTCompatiblePhoto(photo: coverPhoto), at: 0)
        }
            photoArray += NYTCompatiblePhoto.arrayFromPhotoArray(photos)
        }else{
            photoArray += NYTCompatiblePhoto.arrayFromPhotoArray(photos)
        }
        let photosViewController = NYTPhotosViewController(photos: photoArray, initialPhoto: photoArray[index])
        photosViewController!.setRightBarButtonItemButton(UIButton())
        photosViewController!.setNavigationBarBackgroundColor()
        present(photosViewController!, animated: true, completion: nil)
    }
    
    
    func setupNavigationController() {
        if let _ =  self.navigationController{
            if self.navigationBarHeight == 0 {
                self.navigationBarHeight = self.navigationController!.navigationBar.frame.size.height
            }
            self.navigationController!.interactivePopGestureRecognizer!.delegate = self
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    //MARK: - ViewController's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backIcon")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backIcon")
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.moreAndSaveButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
        if self.navigationBarHeight == 0 {
            if let nav = self.navigationController{
            self.navigationBarHeight = nav.navigationBar.frame.size.height
            }
        }
        
        let authorTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreationPreviewViewController.onAuthorTapped(_:)))
        self.authorImage.addGestureRecognizer(authorTap)
        self.locationButton.setImage(UIImage(named: "coordinate_white")!.withRenderingMode(.alwaysTemplate), for:.normal)
        self.toCommentButton.setBackgroundImage(UIImage(named:"recommendationMessage")!.withRenderingMode(.alwaysTemplate), for:.normal)
        self.toCommentButton.tintColor = Config.Colors.GrayBackGroundWithAlpha
        self.locationButton.tintColor = Config.Colors.SecondTitleColor
        self.reportBtn.layer.cornerRadius = 2
        if let recommendation = recommendation {
            self.navigationItem.title = recommendation.title
            
            if let cover = recommendation.cover {
                self.coverPhoto = cover
            }
            self.setupCover()
            self.setupShareView()
            
            sendContainsView.isHidden = true
            self.bottomBar.isHidden = true
            
            if let title = recommendation.title {
                self.currentRecommendationState.data.title = title
            }
            if let text = recommendation.text {
                self.currentRecommendationState.data.text = text
            }
            
            if let venue = recommendation.venue {
                self.currentRecommendationState.data.venue = venue
            }
            
            recommendation.getTagsWithBlock({ (tags) in
                if let tags = tags {
                    self.currentRecommendationState.data.tags = tags
                    self.tagSelectionView.setup(self)
                    self.tagSelectionView.inputTagView.editable = false
                    self.tagSelectionView.inputTagView.style = .none
                    self.tagSelectionView.inputTagView.placeholder = ""
                    self.setupTags()
                }
            })
            
            recommendation.getCategorysWithBlock { (categorys) in
                if let categorys = categorys{
                    self.currentRecommendationState.data.categorys = categorys
                }
            }
            self.addLoadingView()
            recommendation.getPhotosWithBlock {
                (photos) -> () in
                if let photos = photos {
                    if photos.count <= 0{
                        self.loadingV.removeFromSuperview()
                    }
                    self.currentRecommendationState.data.photos = photos
                    self.careTaker = CareTaker(state: self.currentRecommendationState)
                    self.careTaker.snapshot(self.currentRecommendationState)
                    
                    self.commentsView.dataQuery = DataQueryProvider.commentQueryForRecommendation(recommendation)
                    self.commentsView.streamViewDelegate = self
                    self.commentsView.commentDelegate = self
                    self.commentsViewHeightConstraint.constant = 0
                    self.scrolledViewHeightConstraint.constant = UIScreen.main.bounds.height
                    
                    
                    self.setupCommentView()
                    
                    self.setupLayout()
                    self.setupLikeView()
                    self.setupCommentButton()
                    
                }
            }

        } else {
            if let _ = RecommendationFactory.sharedInstance.categorys{
                let backButton = UIButton(type: .custom)
                backButton.frame = CGRect(x: 0, y: 40, width: 70, height: 44)
                backButton.backgroundColor = UIColor.clear
                //backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
                backButton.setImage(UIImage(named: "backIcon"), for:.normal)
                //backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
                backButton.setTitle(NSLocalizedString("Back", comment:"返回"), for:.normal)
                backButton.addTarget(self, action: #selector(CreationPreviewViewController.backButtonClick), for: .touchUpInside)
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
                
            }else{
                let backButton = UIButton(type: .custom)
                backButton.frame = CGRect(x: 0, y: 40, width: 70, height: 44)
                backButton.backgroundColor = UIColor.clear
//                backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
                backButton.setTitle(NSLocalizedString("Give up", comment:"放弃"), for:.normal)
                backButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
                backButton.addTarget(self, action: #selector(CreationPreviewViewController.giveUpButtonClick), for: .touchUpInside)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
                DraftManager.buildFactoryAndDraftArray()
                DraftManager.reSetRecommendationFactory()
                self.photoTableView.isFromDraft = true
                for (_, photo) in RecommendationFactory.sharedInstance.photos.enumerated() {
                    tmpCaptionArray.append(photo.caption!)
                }
                if let tags =  RecommendationFactory.sharedInstance.tags{
                    for (_, tag) in tags.enumerated() {
                        tmpTags.append(tag)
                    }
                }
                if let user = User.current() {
                    RecommendationFactory.sharedInstance.recommendation?.author = user as! User
                }
            }
            Foundation.UserDefaults.standard.set("forthStep", forKey: "draftLastStep")
            Foundation.UserDefaults.standard.synchronize()

            self.navigationItem.title = NSLocalizedString("Create", comment: "创建")
            self.toCommentButton.isHidden = true
            mainScrollViewTopDistanceConstraint.constant = 0            //TODO: test if correctly init
            self.currentRecommendationState = RecommendationState(title: RecommendationStateTitle.Initial.rawValue, recommendationData: RecommendationData())
            self.careTaker = CareTaker(state: self.currentRecommendationState)
            self.careTaker.snapshot(self.currentRecommendationState)
            
            
            
            likeView.isHidden = true
            navigationController?.view.backgroundColor = Config.Colors.MainContentBackgroundWhite
            self.moreAndSaveButton.isHidden = true
            self.shareButton.isHidden = true
            print("preview load...", terminator: "")
            nextButton.backgroundColor = Config.Colors.ZanaduCerisePink
            
            commentsViewHeightConstraint.constant = 0
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreationPreviewViewController.dismissTextFields))
            view.addGestureRecognizer(tap)
            tagSelectionView.expansionDelegate = self
            tagSelectionView.setup()
            self.tagSelectionView.inputTagView.editable = true
            self.tagSelectionView.inputTagView.style = .none
            self.tagSelectionView.inputTagView.placeholder = ""
            
            setupLayout()
            setupTags()
            setupCover()
            self.perform(#selector(CreationPreviewViewController.loadSaveTimer), with: nil, afterDelay: 1)
            
        }
    }
    
    func  backButtonClick() {
        if nextButtonFinished == false {
            return
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    func dismissTextFields() {
        titleField.resignFirstResponder()
        descriptionField.resignFirstResponder()
    }
    
    func onAuthorTapped(_ sender:AnyObject?) {

        guard let _ = recommendation?.author else{
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = recommendation?.author
        navigationController?.pushViewController(vc, animated: true)
    }
    func addLoadingView(){
        let screenWidth = UIScreen.main.bounds.size.width
        self.loadingV.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
        self.loadingV.isBackImageViewHidden = true
        self.loadingV.isWhereImageViewHidden = true
        self.loadingV.isUserLittleBgImage = true
        self.genericLayoutContainer.addSubview(self.loadingV)
        self.setPhotoLayoutConstraint(screenWidth)
        moreAndSaveButton.isEnabled = false
        shareButton.isEnabled = false
    }
    
    func setupLikeView() {
        guard  let recommendation = self.recommendation else{return}
        likeView.delegate = self
        likeView.recommendation = recommendation
        likeView.commentInit()
        likeView.dataQuery = DataQueryProvider.likesForRecommendation(recommendation)
    }

    func setupCommentButton() {
        let superWidth = toCommentButton.frame.size.width
        let superHeight = toCommentButton.frame.size.height

        let leftView = UILabel()
        leftView.frame = CGRect(x: 15, y: 0, width: 150, height: superHeight)
        leftView.text = "说点什么"
        leftView.font = UIFont.systemFont(ofSize: 16)
        leftView.textColor = Config.Colors.SecondTitleColor
        leftView.textAlignment = .left
        toCommentButton.addSubview(leftView)
        
        let verticalLineView = UIImageView()
        verticalLineView.frame = CGRect(x: superWidth - 73, y: 3, width: 3, height: superHeight-6)
        verticalLineView.image = UIImage(named: "verticalLine")
        toCommentButton.addSubview(verticalLineView)
        
        let rightView = UILabel()
        rightView.frame = CGRect(x: superWidth - 72, y: 0, width: 72, height: superHeight)
        rightView.text = "提交"
        leftView.font = UIFont.systemFont(ofSize: 16)
        rightView.textColor = Config.Colors.SecondTitleColor
        rightView.textAlignment = .center
        toCommentButton.addSubview(rightView)

    }
    fileprivate func setupCover() {
        setupRecommendationAuthorInfo()
        if recommendation == nil {
            authorImageHeightConstraint.constant = 0
            authorNameHeightConstraint.constant = 0
            timeLabelHeightConstraint.constant = 0

            if let recommendation = RecommendationFactory.sharedInstance.recommendation {
                if (recommendation.title!).characters.count > 0 {
                    setupTitle(recommendation.title!)
                } else {
                    setupTitle("分享在\(RecommendationFactory.sharedInstance.venue!.customName!)")
                }

                setupDescription(recommendation.text!)

                tagSelectionView.inputViewReducedBackgroundColor = UIColor.clear

                locationButton.setTitle("  \(RecommendationFactory.sharedInstance.venue!.customName!) ", for: UIControlState())
            }
        }

        if let recommendation = recommendation {

            let overlayTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreationPreviewViewController.onOverlayTapped(_:)))
            overlayView.addGestureRecognizer(overlayTap)

            if let cover = recommendation.cover {
                
                let imageHookBlock : ImageSetterBlock = {setImage in


                    cover.fetchIfNeededInBackground({ (object, error) -> Void in
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else if let file = cover.file {
                            file.getImageWithBlock(withBlock: { (image, error) in
                                if error != nil {
                                    log.error(error?.localizedDescription)
                                } else {
                                    self.coverImage = image!
                                    setImage(image!)
                                    if let cropRect = cover.getCropRect() , cropRect.origin.x < 20 && cropRect.origin.x > 0.2 && cropRect.origin.y > 250 {
                                        self.coverRect = cropRect
                                        self.coverImageScrollView.setCrop(cropRect)

                                    }else{
                                        self.coverImageScrollView.display()
                                    }
                                }


                                if let _ = cover.getCropRect(){
                                    ImageCacheManager.recommendationImageWithURL(file.url!, completed: { (image, error, cacheType, finished, requestUrl) in
                                        if error != nil {
                                            log.error(error?.localizedDescription)
                                        }else{
                                            self.coverImage = image!
                                            print("image setting: \(image?.size)")
                                            setImage(image!)
                                            //                                        self.coverImageScrollView.display()
                                            if let cropRect = cover.getCropRect() , cropRect.origin.x < 20 && cropRect.origin.x > 0.2 && cropRect.origin.y > 250{
                                                self.coverRect = cropRect
                                                self.coverImageScrollView.setCrop(cropRect)

                                            }else{
                                                self.coverImageScrollView.display()
                                            }
                                        }
                                    })
                                }

                            })
                        }
                    })
                }
                coverImageScrollView.setup(imageHookBlock, placeholder: UIImage(), tapDelegate: self)
            }
        } else {
            if let file = RecommendationFactory.sharedInstance.photos[0].file {
                let path = DraftManager.createImageFilePath() + "/image1"
                var imageData = Data()
                let fileManager = FileManager.default

                    if  let object = fileManager.contents(atPath: path){
                        imageData = object
                        
                    }
                var  tmpImage : UIImage!
                if let  tmpImg = UIImage(data: (file.getData())!){
                    tmpImage = tmpImg
                }else{
                    tmpImage = UIImage(data: imageData)
                }
                self.coverImage = tmpImage!
                coverImageScrollView!.setup(tmpImage!, tapDelegate: self)
                self.coverImageScrollView.display()
                self.coverImageScrollView.editable = true
                self.overlayView.isHidden = true
                self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
            }
        }

        if let recommendation = recommendation {
            if recommendation.isDataAvailable() {
                setupTitle(recommendation.title!)
                setupDescription(recommendation.text!)
                
                locationButton.isHidden = true
                
                if recommendation.venue != nil {
                    if recommendation.venue!.isDataAvailable() && recommendation.venue?.customName != nil {
                        locationButton.setTitle("  \(recommendation.venue!.customName!) ", for: UIControlState())
                        locationButton.isHidden = false
                        isLocationButtonInitialized = true
                    } else {
                        recommendation.venue!.fetchInBackground({ (object, error) -> Void in
                            if error != nil {
                                log.error(error?.localizedDescription)
                            } else if object == nil {
                            } else if let venueObject = object as? Venue {
                                if let customName = venueObject.customName {
                                    self.locationButton.setTitle("  \(customName) ", for:.normal)
                                    self.locationButton.isHidden = false
                                    self.isLocationButtonInitialized = true
                                }
                            }
                        })
                    }
                }
            } else {
                recommendation.fetchIfNeededInBackground({ (object, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        self.setupTitle(recommendation.title!)
                        self.setupDescription(recommendation.text!)
                        if recommendation.venue != nil {
                            if recommendation.venue!.isDataAvailable() && recommendation.venue?.customName != nil {
                                self.locationButton.setTitle("  \(recommendation.venue!.customName!) ", for: UIControlState())
                            } else {
                                recommendation.venue!.fetchInBackground({ (object, error) -> Void in
                                    if error != nil {
                                        log.error(error?.localizedDescription)
                                    } else {
                                        self.locationButton.setTitle("  \(recommendation.venue!.customName!) ", for: UIControlState())
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    func setupRecommendationAuthorInfo()
    {
        authorImage.isHidden = true
        authorName.isHidden = true
        timeLabel.isHidden = true
        
        if let recommendation = recommendation {
            let author = recommendation.author
            if let author = author {
                if author.isDataAvailable(){
                    self.authorImage.isHidden = false
                    self.authorName.isHidden = false
                    self.authorImage.setupForAvatarWithUser(author)
                    self.authorName.text = author.nickname
                }else{
                    author.fetchInBackground(withKeys: ["avatar"], block: { (object, error) in
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else {
                            self.authorImage.isHidden = false
                            self.authorName.isHidden = false
                            let user  = object as! User
                            self.authorImage.setupForAvatarWithUser(user)
                            self.authorName.text = user.nickname
                        }
                    })
                }
            }
            
            //change elapsedTime to wenXin elapsedTime
            let elapsedTime = self.recommendation?.createdAt!.formatedElapsedTime()
            timeLabel.text = elapsedTime
            timeLabel.isHidden = false
        }
    }

    
    func setupTitle(_ string: String) {
        titleField.text = string
        titleField.textAlignment = NSTextAlignment.center
        titleField.textColor = Config.Colors.FirstTitleColor
        titleField.font = UIFont.boldSystemFont(ofSize: 18)
        titleField.tintColor = Config.Colors.ZanaduCerisePink
        titleField.backgroundColor = UIColor.clear
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: titleField, action: #selector(UIResponder.resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        barButton.tintColor = Config.Colors.ZanaduCerisePink
        toolbar.items = [barButton]
        
        titleField.inputAccessoryView = toolbar

        if recommendation != nil {
            titleField.isEnabled = false
        }
    }
    
    func getDescriptionTextAttribute() -> [String : AnyObject]? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributes = [NSFontAttributeName:descriptionField.font!.withSize(15),NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Config.Colors.MainContentColorBlack]
        return attributes
    }
    
    func setDescAttributeText(_ string: String)  {
        let attributes = getDescriptionTextAttribute()
        descriptionField.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        descriptionField.textAlignment = NSTextAlignment.justified
        descriptionField.isScrollEnabled = false
    }
    
    func setupDescription(_ string: String) {
        
        setDescAttributeText(string)
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: descriptionField, action: #selector(UIResponder.resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        barButton.tintColor = Config.Colors.ZanaduCerisePink
        toolbar.items = [barButton]
        
        descriptionField.inputAccessoryView = toolbar
        //加入一个button
        
        descriptionUnfoldBtn.addTarget(self, action: #selector(CreationPreviewViewController.descriptionUnfoldBtnClick), for: UIControlEvents.touchUpInside)
        descriptionUnfoldBtn.setTitle(NSLocalizedString("More", comment: "更多"), for: UIControlState())
        descriptionUnfoldBtn.setTitle(NSLocalizedString("Close", comment: "收起"), for: UIControlState.selected)
        descriptionUnfoldBtn.setTitleColor(Config.Colors.SecondTitleColor, for:.normal)
        descriptionUnfoldBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        descriptionUnfoldBtn.layer.cornerRadius = 6
        descriptionUnfoldBtn.backgroundColor = Config.Colors.GrayIconAndTextColor.withAlphaComponent(0.4)
        descriptionUnfoldBtn.contentMode = UIViewContentMode.center
        descriptionField.addSubview(descriptionUnfoldBtn)
        descriptionUnfoldBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(descriptionField)
            make.top.equalTo(descriptionField).inset(165)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        descriptionUnfoldBtn.isHidden = true
        
        if recommendation != nil {
            descriptionField.isEditable = false
            descriptionField.isSelectable = false
            if string.characters.count <= 0 {
                descriptionFieldHeightConstraint.constant = 0
            }
            setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
            descriptionField.isScrollEnabled = false
        } else {
            descriptionField.isScrollEnabled = true
            descriptionField.delegate = self
            descriptionField.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
            
        }
    }
    func setupCommentView() {
        commentTextFiled.delegate = self
        commentTextFiled.enablesReturnKeyAutomatically = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreationPreviewViewController.commentTextViewTap))
        commentTextView.addGestureRecognizer(tap)
    }
    
    fileprivate func setupTags() {
        if let recommendation = recommendation {
            tagSelectionView.inputTagView.backgroundColor = UIColor.clear
            tagSelectionView.backgroundColor = UIColor.clear
            
            let query = recommendation.tags?.query()
            
            query?.findObjectsInBackground({ (objects, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                    self.tagSelectionHeightConstraint.constant = 0
                    self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
                } else {
                    if let tags = objects as? [Tag] {
                        log.error("RECOMMENDATION'S TAGS: add tags")
                        if tags.count <= 0 {
                            self.tagSelectionHeightConstraint.constant = 0
                            self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
                        }else{
                            self.tagSelectionView.setTagsWithNoDelegateAdd(tags)
                            self.tagSelectionView.inputTagView._tagField._scrollView.setContentOffset(CGPoint.zero, animated: true)
                            self.currentRecommendationState.getData().tags = tags
                            self.tagSelectionHeightConstraint.constant = 44
                            self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
                        }
                    } else {
                        self.tagSelectionHeightConstraint.constant = 0
                        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
                    }
                }
            })
            
        } else {
            tagSelectionView.inputTagView.backgroundColor = Config.Colors.GrayBackGroundWithAlpha;          tagSelectionView.backgroundColor = UIColor.clear
            
            if let tags = RecommendationFactory.sharedInstance.tags {
                if tags.count > 0 {

                    delay(0.3, closure: { () -> () in
                        self.tagSelectionView.setTags(RecommendationFactory.sharedInstance.tags!)
                        self.tagSelectionView.inputTagView._tagField._scrollView.setContentOffset(CGPoint.zero, animated: true)
                    })
                    

                    self.tagSelectionHeightConstraint.constant = 44
                    self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)

                }else{
                    self.tagSelectionHeightConstraint.constant = 0
                    self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)

                }
            }else{
                self.tagSelectionHeightConstraint.constant = 0
                self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)

            }
        }
    }
    func setupShareView(){
        self.shareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?[0] as? ShareView
        if let shareV = self.shareView {
        shareV.frame = CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: self.view.frame.size.height)
        self.view.addSubview(shareV)
        shareV.tapDelegate = self
        shareV.commentSetting()
        self.view.bringSubview(toFront: shareV)
        shareV.isHidden = true
        }
    }
    
    fileprivate func handlePhotos() {
        let objects = self.currentRecommendationState.getData().photos
        if objects.count >= 0 {
                    self.photoTableView.frame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: 0)
                    self.photoTableView.bounces = false
                    self.photoTableView.isScrollEnabled = false
                    self.genericLayoutContainer.addSubview(self.photoTableView)
                    self.photoTableView.photoTableViewDelegate = self
                    self.photoTableView.photos = self.currentRecommendationState.getData().photos
                    self.photoTableView.dataQuery()
                    self.photoTableView.isCellEditable = true
                    self.photoTableView.isShowCellDelete = false
                    self.photoTableView.calculateTotalHeight(IndexPath.init(item: 0, section: 1))
                    self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
        }

    }
    
    fileprivate func setupCoverCropViewWithImage(_ image: UIImage, andCropRect cropRect: CGRect?) {
        coverImageScrollView.setup(image, tapDelegate: self)
        coverImageScrollView.editable = false
        
        if #available(iOS 9.0, *) {
            SpotlightSearch.setupSearchableItemWithImage(image, uniqueId: recommendation!.objectId!, domainId: recommendation!.shortId!, title: recommendation!.title!, description: recommendation!.text!)
        } else {
            // don't index
        }
        
        if let cropRect = cropRect {
            self.coverImageScrollView.setCrop(cropRect)
        }
        
        coverImageScrollView.display()
    }
    
    
    
    fileprivate func handleListItems() {
        
        initListItemsLayout()
        
        var listItemViews = [ListItemView]()
        var receivedListItemsCount = 0
        
        for (index,listItem) in listItems.enumerated() {
            receivedListItemsCount += 1
            let listItemView = Bundle.main.loadNibNamed("ListItemView", owner: self, options: nil)?[0] as! ListItemView
            listItemView.container = layoutView
            listItemView.setupWithListItem(listItem, andIndex: index, selectionDelegate: self)
            listItemViews.append(listItemView)
            
            if receivedListItemsCount == self.listItems.count {
                self.layoutView.setup(listItemViews, template: GenericLayoutName.fullWidthTwoRows, delegate: self)
            }
        }
        
    }
    
    fileprivate func initPhotosLayout() {
        layoutView = GenericLayoutView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        
        layoutView.padding = 16
        layoutView.cellPadding = 4
        layoutView.cellBorderColor = UIColor.clear
        layoutView.cellBorderWidth = 0
        layoutView.backgroundColor = UIColor.clear
        
        genericLayoutContainer.addSubview(layoutView)
    }
    
    fileprivate func initListItemsLayout() {
        layoutView = GenericLayoutView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        layoutView.padding = 0
        layoutView.cellPadding = 0
        layoutView.cellBorderColor = UIColor.clear
        layoutView.cellBorderWidth = 0
        layoutView.backgroundColor = UIColor.clear
        
        genericLayoutContainer.addSubview(layoutView)
    }

    fileprivate func setupLayout() {

        if let recommendation = recommendation {

            if let recommendationContentType = RecommendationContentType(rawValue:1) {
                switch recommendationContentType {
                case .recommendation:
                    if photosLoadNum == 0{
                        self.photoTableView.frame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: 0)
                        self.photoTableView.bounces = false
                        self.photoTableView.isScrollEnabled = false
                        self.genericLayoutContainer.addSubview(self.photoTableView)
                        self.photoTableView.photoTableViewDelegate = self
                    }
                    let query = recommendation.photos!.query()
                    query.cachePolicy = .cacheThenNetwork
                    query.order(byAscending: "rsort")
                    query.findObjectsInBackground({ (objects, error) -> Void in
                        self.photosLoadNum += 1
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else {
                            if (objects?.count)! >= 0 {
                                if let objects = objects as? [Photo] {
                                    self.currentRecommendationState.getData().photos = objects
                                        self.photoTableView.photos.removeAll()
                                        self.photoTableView.photoImages.removeAll()
                                        self.photoTableView.reloadData()
                                        self.photoTableView.sortPhotoImages.removeAll()
                                        self.photoTableView.photos = self.currentRecommendationState.getData().photos
                                        self.photoTableView.dataQuery()
                                }
                            }
                        }
                    })
                case .list:
                    let query = DataQueryProvider.listItemsForRecommendation(recommendation)
                    query.executeInBackground({ (objects:[Any]?, error) -> () in
                        self.shareButton.isEnabled = true
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else if (objects?.count)! > 0 {
                            if let items = objects as? [ListItem] {
                                if self.listItems.count != 0{
                                    return
                                }
                                self.listItems = items
                                self.handleListItems()
                            }
                        }
                    })
                }
            }
        } else {
            
            let count = RecommendationFactory.sharedInstance.photos.count
            
            if count > 1 {
                self.currentRecommendationState.getData().photos = Array(RecommendationFactory.sharedInstance.photos[1..<count])
                handlePhotos()
            }
        }
        nextButton.layer.cornerRadius = 3
        nextButton.layer.masksToBounds = true
    }
    
    
    func setPhotoLayoutConstraint(_ value: CGFloat) {
        self.photoLayoutHeightConstraint.constant = value
        self.genericLayoutContainer.frame.size.height = value
        
        var scrolledViewHeight: CGFloat = 0
        scrolledViewHeight += coverImageScrollView.frame.height

        
        //authorImage
        scrolledViewHeight += authorImageHeightConstraint.constant / 2

        
        // authorName
        if authorNameHeightConstraint.constant != 0{
            authorNameTopConstraint.constant = 14
            scrolledViewHeight += authorNameTopConstraint.constant
            scrolledViewHeight += authorNameHeightConstraint.constant
        }else{
            authorNameTopConstraint.constant = 0
        }

        
        
        // time
        if timeLabelHeightConstraint.constant != 0{
            timeLabelTopConstraint.constant = 14
            scrolledViewHeight += timeLabelTopConstraint.constant
            scrolledViewHeight += timeLabelHeightConstraint.constant
        }else{
           timeLabelTopConstraint.constant = 0
            scrolledViewHeight += 30
        }
        
        //title(certainly have)
        scrolledViewHeight += titleFiledTopConstraint.constant
        scrolledViewHeight += titleField.frame.size.height
        
        //location
        if !locationButton.isHidden {
            locationButtonTopConstraint.constant = 0
        scrolledViewHeight += locationButtonTopConstraint.constant
        scrolledViewHeight += locationButton.frame.size.height
        } else if isLocationButtonInitialized || recommendation?.venue == nil {
            locationButtonTopConstraint.constant = 0
            locationButtonHeightConstraint.constant = 0
            
        }
        
        // description
        var descriptionHeight = CGFloat(0.0)
        let descText = descriptionField.attributedText.string
        if descText.characters.count > 0{
            //descriptionHeight = descriptionField.attributedText.boundingRectWithSize(CGSizeMake(descriptionField.frame.width, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin , NSStringDrawingOptions.UsesFontLeading], context: nil).size.height
            descriptionHeight = (descText as NSString).boundingRect(with: CGSize(width: descriptionField.frame.width-50, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: getDescriptionTextAttribute(), context: nil).size.height
        }
        else{
            descriptionHeight = descriptionField.sizeThatFits(CGSize(width: descriptionField.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        }
        
        var lineHeight = descriptionField.font!.lineHeight
        if descriptionHeight > 1000{
            lineHeight += 6
        }
        let lineCount = Int(ceil(descriptionHeight / lineHeight))
        descriptionHeight += CGFloat(lineCount+1) * 6 + lineHeight
        
        if descriptionHeight > 187{
            descriptionUnfoldBtn.isHidden = false
        }else{
            descriptionUnfoldBtn.isHidden = true
        }
        
        if recommendation != nil {
            if isNowEditing{
                descriptionUnfoldBtn.isHidden = true
                descriptionFieldHeightConstraint.constant = 100
            }else{
                if !descriptionUnfoldBtn.isHidden && !descriptionUnfoldBtn.isSelected{
                    descriptionFieldHeightConstraint.constant = descriptionHeight > 187 ? 187 : descriptionHeight
                    descriptionUnfoldBtn.snp_updateConstraints({ (make) in
                        
                        make.top.equalTo(187 - descriptionUnfoldBtn.frame.size.height)
                    })
                }else if !descriptionUnfoldBtn.isHidden && descriptionUnfoldBtn.isSelected{
                    descriptionFieldHeightConstraint.constant = descriptionHeight + descriptionUnfoldBtn.frame.size.height + 15
                    descriptionUnfoldBtn.snp_updateConstraints({ (make) in
                        make.top.equalTo(descriptionHeight)
                    })
                }else{
                    descriptionFieldHeightConstraint.constant = descriptionHeight
                }
                if descriptionField.text.characters.count <= 0 {
                    descriptionFieldHeightConstraint.constant = 0
                }
            }
            if descriptionFieldHeightConstraint.constant != 0{
                descriptionFieldTopConstraint.constant = 15
                scrolledViewHeight += descriptionFieldTopConstraint.constant  // 8 328
                scrolledViewHeight += descriptionFieldHeightConstraint.constant // 217 (555)
            }else{
                descriptionFieldTopConstraint.constant = 0
            }
        }else{
            descriptionUnfoldBtn.isHidden = true
            descriptionFieldHeightConstraint.constant = 80
            scrolledViewHeight += descriptionFieldTopConstraint.constant  // 8 328
            scrolledViewHeight += descriptionFieldHeightConstraint.constant // 217 (555)

        }
        
        // tags
        if (isNowEditing){
            tagSelectionHeightConstraint.constant = 44
            scrolledViewHeight += tagSelectionHeightConstraint.constant
        }else{
        if tagSelectionHeightConstraint.constant != 0{
            tagSelectionVerticalSpacingConstraint.constant = 0
            scrolledViewHeight += tagSelectionVerticalSpacingConstraint.constant // 8 (571)
            // TODO: remove if no tags
            scrolledViewHeight += tagSelectionHeightConstraint.constant // 44 (615)
        }else{
            tagSelectionVerticalSpacingConstraint.constant = 0
        }
        }
        // photoLayout
        if photoLayoutHeightConstraint.constant != 0 {
            genericLayoutContainerTopConstraint.constant = 8
            scrolledViewHeight += photoLayoutHeightConstraint.constant // 0 (615)
            scrolledViewHeight += genericLayoutContainerTopConstraint.constant

        } else {
            genericLayoutContainerTopConstraint.constant = 0
        }
        
        
        // likeView
        if !likeView.isHidden {
            likeViewTopConstraint.constant = 8
            scrolledViewHeight += 50
            scrolledViewHeight += likeViewTopConstraint.constant
        } else {
            likeViewTopConstraint.constant = 0
        }
        
        // comments
        if !commentsView.isHidden {
            commentsViewTopConstraint.constant = 8
            scrolledViewHeight += commentsViewHeightConstraint.constant // 0 (615)
            scrolledViewHeight += commentsViewTopConstraint.constant
        } else {
            commentsViewTopConstraint.constant = 0
        }
        //toCommentButton
        if !toCommentButton.isHidden{
             scrolledViewHeight += toCommentButtonHeightConstraint.constant + 10
        }
        
        //addBImageBtn
        if !addImageBtn.isHidden {
            addImageBtnTopConstraint.constant = 15
            scrolledViewHeight += addImageBtnTopConstraint.constant
            scrolledViewHeight += addImageBtn.frame.size.height 
        }else{
            addImageBtnTopConstraint.constant = 0
        }
        
        // bottomBar
        if !self.bottomBar.isHidden {
            scrolledViewHeight += bottomBar.frame.height // 72 (687)
        }
        
        scrolledViewHeight += 30
        scrolledViewHeightConstraint.constant = scrolledViewHeight
        
        mainScrollView.contentSize.height = scrolledViewHeight
        
        if layoutView != nil {
            layoutView.frame = CGRect(x: 0, y: 0, width: genericLayoutContainer.frame.width, height: genericLayoutContainer.frame.height)
        }
        
        mainScrollView.layoutIfNeeded()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        setupNavigationController()
        self.navigationItem.hidesBackButton = true
        
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        if recommendation?.author != AVUser.current(){
            if self.navigationItem.rightBarButtonItems?.count == 2 {
                self.navigationItem.rightBarButtonItems?.removeFirst()
            }
        }
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(CreationPreviewViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object:nil)
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(CreationPreviewViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backIcon")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backIcon")
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTimerInvalidate()
        Foundation.NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Method Overrides
    
    override var prefersStatusBarHidden : Bool {

        return shouldHideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func sendComment(_ commentText:String) {
        let comment = Comment(text: commentText, author: User.current() as! User, recommendation: recommendation!)
        if let replyAuthor = self.replyAuthor{
            comment.responseAuthor = replyAuthor
        }
        comment.saveInBackground { (saved, error) -> Void in
            if error != nil {
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            } else {
                if saved {
                    self.hiddenCommentView()
                    self.commentsView.refresh()
                    self.showBasicHudWithTitle(NSLocalizedString("Successful comment", comment:"评论成功"))
                    } else {
                    self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
                }
            }
        }
    }
    func hiddenCommentView() {
        self.commentTextView.isHidden = true
        self.commentTextFiled.resignFirstResponder()
        self.commentTextFiled.text = ""
        self.commentTextFiled.placeholder = nil
        self.replyAuthor = nil
    }


}
//MARK: - about keyboard
extension CreationPreviewViewController{
    //about keyboard
    func keyboardWillShow(_ notification: Foundation.Notification) {
        if (!self.bottomBar.isHidden)
        {
            isBottomBarShow = true
            bottomBar.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Foundation.Notification) {
        if isBottomBarShow {
            bottomBar.isHidden = false
        }

    }


    
}

//MARK: - PhotoSelectionProtocol
extension CreationPreviewViewController:PhotoSelectionProtocol{
    func onPhotoSelected(_ photo: Photo) {
        guard let index = self.currentRecommendationState.getData().photos.index(of: photo) else { return }
        pushSlideshowWithInitialPhotos(self.currentRecommendationState.getData().photos, atIndex: index + 1,isListItems: false)
    }
}
//MARK: - StreamViewDelegate
extension CreationPreviewViewController:StreamViewDelegate{
    func onHeightChanged(_ height: CGFloat) {
        self.commentsViewHeightConstraint.constant = height
        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
        
    }
}
//MARK: - UITagSelectionViewExpansionDelegate,TagViewDelegate
extension CreationPreviewViewController:UITagSelectionViewExpansionDelegate,TagViewDelegate{
    func expandTagSelectionView() {
        if isNowEditing{
            return
        }
        

        
        self.shouldHideStatusBar = true
        toggleStatusBar()
        
        self.mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.mainScrollView.isScrollEnabled = false
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.navigationController?.navigationBar.frame.origin.y = -self.navigationController!.navigationBar.frame.height
            self.tagSelectionVerticalSpacingConstraint.constant = -self.descriptionField.frame.size.height - self.descriptionField.frame.origin.y - Config.AppConf.navigationBarAndStatuesBarHeight
            self.tagSelectionHeightConstraint.constant = self.view.frame.height
            self.tagSelectionView.recentTagView.alpha = 1
            self.tagSelectionView.popularTagView.alpha = 1
            
        })
    }
    
    func reduceTagSelectionView() {
        if isNowEditing{
            return
        }

        self.shouldHideStatusBar = false
        toggleStatusBar()
        self.mainScrollView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.tagSelectionView.recentTagView.alpha = 0
            self.tagSelectionView.popularTagView.alpha = 0
            
            self.tagSelectionView.backgroundColor = UIColor.clear
            self.navigationController?.navigationBar.frame.origin.y = 20
            
            self.tagSelectionVerticalSpacingConstraint.constant = 0
            self.tagSelectionHeightConstraint.constant = 44
        })
        
        onStepOneDataChanged()
    }
    
    func toggleStatusBar() {

        
        UIView.animate(withDuration: 0.5,
                                   animations: {
                                    self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    func tagView(_ tag: TagView, performSearchWithString string: String, completion: ((_ results: Array<Tag>) -> Void)?) {
        
    }
    
    func tagView(_ tag: TagView, displayTitleForObject object: AnyObject) -> String {
        return "."
    }
    
    func tagView(_ tagView: TagView, didSelectTag tag: TagControl) {
        if isNowEditing{
            return
        }

        if recommendation != nil {
            for tagObject in self.currentRecommendationState.getData().tags {
                if tag.title == tagObject.name {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "TagHomeListingViewController") as! TagHomeListingViewController
                    vc.tag = tagObject
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            //tagSelectionView.tagvi
        }
    }
    
    func tagView(_ tagView: TagView, didAddTag tag: TagControl) {
        let addTag = Tag()
        addTag.name = tag.title
        self.currentRecommendationState.getData().tags.append(addTag)
    }
    func tagView(_ tagView: TagView, didDeleteTag tag: TagControl) {
        
        if  self.currentRecommendationState.getData().tags.count > 0{
            self.currentRecommendationState.getData().tags.removeLast()
        }
    }
}
//MARK: - PhotoTableViewDelegate
extension CreationPreviewViewController:PhotoTableViewDelegate{
    func onLayoutHeightCalculated(_ height: CGFloat, index: IndexPath) {
        if self.photosLoadNum == 2 {
        if recommendation?.author == AVUser.current(){
            self.moreAndSaveButton.isEnabled = true
            self.shareButton.isEnabled = true
        }else{
        self.shareButton.isEnabled = true
        }
        }
        
        setPhotoLayoutConstraint(height)
        loadingV.removeFromSuperview()
        self.photoTableView.frame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: height)
        if (index as NSIndexPath).section == 1{
            return
        }
        self.currentRecommendationState.getData().photos.remove(at: (index as NSIndexPath).row)
    }
    
    func onCellTouched(_ photo: Photo) {
        if !isNowEditing {
            onPhotoSelected(photo)
        }
    }
    
    
}
//MARK: - PhotoLibraryControllerDelegate
extension CreationPreviewViewController:PhotoLibraryControllerDelegate{
    func photoLibraryControllerDelegateDidChangeCover(_ photo: Photo) {
        guard let coverImageScrollView = self.coverImageScrollView else {return}
        coverImageScrollView.setup(UIImage(data: photo.file!.getData()!)!, tapDelegate: self)
        coverImageScrollView.display()
        self.coverPhoto = photo
    }
    
    func photoLibraryControllerDelegateDidAddPhoto(_ photos: [Photo]) {
        for photo in photos {
            self.currentRecommendationState.getData().photos.append(photo)
            let image = UIImage(data: photo.file!.getData()!)
            self.photoTableView.photoImages.append(image!)
            self.photoTableView.photos.append(photo)
            self.photoTableView.reloadData()
            }
        let defaultIndex = IndexPath.init(item: 0, section: 1)
        self.photoTableView.calculateTotalHeight(defaultIndex)
        self.photoTableView.saveDescription()
        self.photoTableView.reloadData()
        }
    }

//MARK: - GenericLayoutDelegate
extension CreationPreviewViewController: GenericLayoutDelegate {
    func onLayoutHeightCalculated(_ height: CGFloat) {
        setPhotoLayoutConstraint(height)
    }
}
//MARK: - ImageCropViewTapProtocol
extension CreationPreviewViewController: ImageCropViewTapProtocol {
    func onImageCropViewTapped(_ imageCropView: ImageCropView) {
        if self.isNowEditing{
            return
        }
        if let recommendation = recommendation {
            if let recommendationContentType = RecommendationContentType(rawValue: recommendation.type!.intValue) {
                if recommendationContentType == RecommendationContentType.recommendation && layoutView != nil {
                    for i in 0 ..< layoutView.getItems().count {
                        if imageCropView == (layoutView.getItems() as! [ImageCaptionCropView])[i] {
                            onPhotoSelected(self.currentRecommendationState.getData().photos[i])
                            return
                        }
                    }
                }
                if let _ = recommendation.cover {
                    pushSlideshowWithInitialPhotos(self.currentRecommendationState.getData().photos, atIndex: 0, isListItems: false)
                }
            }
        }
    }
}
//MARK: - ListItemViewSelectionDelegate
extension CreationPreviewViewController: ListItemViewSelectionDelegate {
    func onListItemTitleTapped(_ listItem: ListItem) {
        if let venue = listItem.venue , venue.customName != nil {
            Router.redirectToVenue(venue, fromViewController: self)
        }
    }
    func onListItemPhotoTappedWithPhotos(_ photos: [Photo], selectedIndex index: Int) {
        pushSlideshowWithInitialPhotos(photos, atIndex: index, isListItems: true)
    }
}
//MARK: - ShareViewTapDelegete
extension CreationPreviewViewController: ShareViewTapDelegete {
    func shareViewTapDelegeteWillCancel() {
        self.shareView?.isHidden = true
    }
    
    func shareViewTapDelegeteWillShareToWechatSession() {
        shareToWechat(WXScene.wxSceneSession)
    }
    
    func shareViewTapDelegeteWillShareToWechatTimeLine() {
        shareToWechat(WXScene.wxSceneTimeline)
    }
    
    func shareToWechat(_ sharingMethod:WXScene) {
        guard let recommendation = recommendation else { return }
        self.shareView?.isHidden = true
        WeixinApi.instance.shareRecommendation(recommendation, withImage: self.coverImage, andSharingMethod: sharingMethod)
    }
    func shareViewTapDelegateCoverTapped() {
        self.shareView?.isHidden = true
    }
}
//MARK: - LocationSearchViewControllerDelegate
extension CreationPreviewViewController : LocationSearchViewControllerDelegate {
    func locationSearchViewControllerDelegateDidSelectVenue(_ venue: Venue) {
        self.currentRecommendationState.getData().venue = venue
        self.locationButton.setTitle("  \(venue.customName!) ", for: UIControlState())
    }
}
//MARK: - CommentsStreamViewDelegate
extension CreationPreviewViewController : CommentsStreamViewDelegate{
    func commentsStreamViewAuthorTapDelegateWithComment(_ comment: Comment) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = comment.author
        navigationController?.pushViewController(vc, animated: true)
        
    }
    func commentsStreamViewDelegateDidSelectWithComment(_ comment: Comment,distance:CGFloat) {
        if let _ = AVUser.current(){
            self.selectedCommentDistance = distance
            if comment.author == AVUser.current(){
                self.deleteComment = comment
                self.showDeleteCommentAlert()
            }else{
                self.commentTextView.isHidden = false
                self.commentTextFiled.becomeFirstResponder()
                if let str = comment.author?.nickname{
                    self.commentTextFiled.placeholder = "回复\(str)"
                }
                self.replyAuthor = comment.author
            }
        }else{
            Router.redirectToLoginViewController(fromViewController: self)
        }

    }
}
//MARK: - LikeViewDelegate
extension CreationPreviewViewController:LikeViewDelegate{
    func likeViewDidTapUser(_ user: User) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
        
    }
    func likeViewHeartImageBtnClick(_ liked: Bool) {
        self.likeView.fetchData()
    }
    func likeViewHeartImageBtnClickWithoutLogin() {
        Router.redirectToLoginViewController(fromViewController: self)
    }
}
//MARK: - alertView
extension CreationPreviewViewController{
    func showSaveSuccessAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "保存成功", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    func showDeletePostAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "真的要删除这条动态么？", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            
            guard let recommendation = self.recommendation else { return }
            recommendation.disableTheRecommendationWithBlock({ (success) -> () in
                if success{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showBasicAlertWithTitle("删除失败")
                }
            })

        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showReportPostAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "如审核通过会删除该内容", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            self.reportContent()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showDeleteCommentAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "真的要删除这条评论么?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            if let comment = self.deleteComment{
                comment.deleteInBackground({ (success, error) -> Void in
                    if success {
                        self.commentsView.refresh()
                        self.setPhotoLayoutConstraint(self.photoLayoutHeightConstraint.constant)
                    } else {
                        
                    }
                })
            }

        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func draftTimer(){
        if !nextButtonFinished {
            return
        }
        
        let captions = photoTableView.getCaptions()
        let equal = tmpCaptionArray.elementsEqual(captions)

//        if  !equal {
            tmpCaptionArray = captions
            var draftPhotosArray = [DraftPhotos]()
            
            for (index, photo) in RecommendationFactory.sharedInstance.photos.enumerated() {
                if index == 0 {
                    photo.setCropRect(coverImageScrollView.cropRect())
                } else {
                    if captions.count > 0 && index - 1 < captions.count{
                        photo.caption = captions[index - 1]
                    }
                }
                if photo.file?.name == nil || photo.file?.name == "" {
                    let key = "image" + String(index + 1)
                    
                    let path = DraftManager.createImageFilePath() + "/image1"
                    var imageData = Data()
                    let fileManager = FileManager.default
                    
                    if  let object = fileManager.contents(atPath: path){
                        imageData = object
                    }
                    var  tmpImage  = UIImage(data: imageData)
                    
                    if let imageName = Foundation.UserDefaults.standard.object(forKey: key) {
                        photo.file? = AVFile.init(name: imageName as! String, data: imageData)
                    }
                }
                let draftPhoto = DraftPhotos()
                draftPhoto.createPhotoInfoFrom(photo)
                draftPhotosArray.append(draftPhoto)
//            }
            
            RecommendationFactory.sharedInstance.draftArray.remove(at: 0)
            RecommendationFactory.sharedInstance.draftArray.insert(draftPhotosArray as AnyObject, at: 0)

        }
        
        if tmpTags != tagSelectionView.getTags() {
            RecommendationFactory.sharedInstance.tags = tagSelectionView.getTags()


        }
        if let title = RecommendationFactory.sharedInstance.recommendation?.title {
            if title != titleField.text! {
                RecommendationFactory.sharedInstance.recommendation?.title = titleField.text!
            }
        }
        if let text = RecommendationFactory.sharedInstance.recommendation?.text {
            if text != descriptionField.attributedText.string {
                RecommendationFactory.sharedInstance.recommendation?.title = descriptionField.text
            }
        }

        DraftManager.refreshSandboxData()

        DraftManager.saveDraftToSandBox(RecommendationFactory.sharedInstance.draftArray)

    }
    func setTimerInvalidate(){
        self.saveTimer.invalidate()
    }
    func loadSaveTimer(){
        
        saveTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(CreationPreviewViewController.draftTimer), userInfo: nil, repeats: true)
        saveTimer.fire()
    }
    func  giveUpButtonClick() {
        if nextButtonFinished == false {
            return
        }
        RecommendationFactory.createEmpty()
        setTimerInvalidate()
        self.navigationController?.popViewController(animated: true)
        DraftManager.removeDraftFromSandBox()
        Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
        
    }

}
//MARK: - UITextViewDelegate
extension CreationPreviewViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionField {
            descriptionField.textAlignment = NSTextAlignment.justified
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionField {
            descriptionField.textAlignment = NSTextAlignment.justified
            if !self.isNowEditing{
                onStepOneDataChanged()
            }
        }
    }

    
}
//MARK: - UITextFieldDelegate
extension CreationPreviewViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleField {
            textField.textAlignment = NSTextAlignment.left
            textField.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            textField.textColor = Config.Colors.LightGreyTextColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleField {
            textField.textAlignment = NSTextAlignment.center
            textField.backgroundColor = UIColor.clear
            textField.textColor = UIColor(red:246.0/255, green: 246.0/255, blue: 246.0/255, alpha: 1.0)
            if !self.isNowEditing{
                onStepOneDataChanged()
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == commentTextFiled{
            guard let commentText = commentTextFiled.text else {return false}
            let str = commentText.trimmingCharacters(in: CharacterSet.whitespaces)
            if str == "" {
                return false
            }else{
                sendComment(str)
                return true
            }
        }
        return true
    }
}
//MARK: - LoginDelegate
extension CreationPreviewViewController: LoginDelegate {
    func needLogin() {
        Router.redirectToLoginViewController(fromViewController: self)
    }
}
//MARK: - UIActionSheetDelegate
extension CreationPreviewViewController:UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            self.editButtonClick()
        }else if buttonIndex == 2{
            self.showDeletePostAlert()
        }
    }
}
