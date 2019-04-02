//
//  UserProfileViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/12/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



class UserProfileViewController : BaseViewController {
    
    //MARK: - Properties
    
    let tribeCellIdentifier = "TribeFlagViewCell"
    
    fileprivate var initialized = false
    fileprivate var following = false
    fileprivate var isCurrentUser = true
    
    fileprivate var shouldReloadTribes = false
    fileprivate var lastScrollOffset: CGFloat = 0
    
    var currentPage = 10
    
    var loadingV = LoadingView()
    
    var user:User? {
        didSet {
            let tmpIsCurrentUser = isCurrentUser
            if user == User.current() {
                isCurrentUser = true
            } else {
                isCurrentUser = false
            }
            if !tmpIsCurrentUser || !isCurrentUser {
                reload()
            }
        }
    }
    
    fileprivate lazy var followButtonIndicator = UIActivityIndicatorView()
    
    var avataSheet: UIActionSheet?
    var coverSheet: UIActionSheet?
    var isAvatarImageViewChanged = false
    
    //MARK: - Outlets
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverOverlay: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var settingBtn: UIButton!

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageCountLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var iconLikeAndCountCornerView: UIView!
    
    @IBOutlet weak var iconLikeAndCountView: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var tabButtonsContainer: UIView!
    
    @IBOutlet weak var likeParentViewMarginTop: NSLayoutConstraint!
    @IBOutlet weak var postedTabButtonView: UIView!
    @IBOutlet weak var followersTabButtonView: UIView!
    @IBOutlet weak var followeesTabButtonView: UIView!
    @IBOutlet weak var likedTabButtonView: UIView!
    
    @IBOutlet weak var postedTabButtonLabel: UILabel!
    @IBOutlet weak var followersTabButtonLabel: UILabel!
    @IBOutlet weak var followeesTabButtonLabel: UILabel!
    @IBOutlet weak var likedTabButtonLabel: UILabel!
    
    @IBOutlet weak var postedTabButtonStaticLabel: UILabel!
    @IBOutlet weak var followersTabButtonStaticLabel: UILabel!
    @IBOutlet weak var followeesTabButtonStaticLabel: UILabel!
    @IBOutlet weak var likedTabButtonStaticLabel: UILabel!
    
    @IBOutlet weak var postLineButton: UIButton!
    @IBOutlet weak var followeesLineButton: UIButton!
    @IBOutlet weak var followersLineButton: UIButton!
    @IBOutlet weak var likeLineButton: UIButton!
    
    @IBOutlet weak var postedRecommendationView: RecommendationStreamView!
    @IBOutlet weak var followersUserView: UserStreamView!
    @IBOutlet weak var followeesUserView: UserStreamView!
    @IBOutlet weak var likedRecommendationView: RecommendationStreamView!
    
    @IBOutlet weak var lateralScrollView: NoAutoScrollUIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var noRecommendationNotice: UIImageView!
    
    
    @IBOutlet weak var iconLikeAndCountCornerViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lateralContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followAndLikeContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lateralScrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconLikeAndCountConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeLabelToLikeImageMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var PostedRecommendationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followeesUserViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followerUserViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var likedRecommendationViewHeigheConstraint: NSLayoutConstraint!
    
    
    //MARK: - Actions
    
    @IBAction func messageButtonClick() {
        if user != nil {
            Router.redirectToNotification(fromViewcontroller: self)
        } else {
            Router.redirectToLoginViewController(fromViewController: self)
            noRecommendationNotice.isHidden = true
        }
    }
    @IBAction func settingBtnTapped() {
        let  settingSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("Cancle", comment: "取消"), destructiveButtonTitle: nil, otherButtonTitles: NSLocalizedString("Setting", comment: "设置"),NSLocalizedString("Personal information", comment:"个人信息") )
            settingSheet.tag = 1
            settingSheet.show(in: self.view)
}
    
    @IBAction func onFollowButtonPressed(_ sender: UIButton) {

        
        followButton.isEnabled = false
        //        followButton.backgroundColor = Config.Colors.ZanaduGrey
        followButtonIndicator.startAnimating()
        if following {
            unfollow()
        } else {
            follow()
        }
    }
    
    func follow() {
        User.current()?.follow((user?.objectId)!, andCallback: { (success, error) -> Void in
            if error != nil {
                log.error(error!.localizedDescription)
                self.followButtonIndicator.stopAnimating()
                self.followButton.isEnabled = true
            } else {

                self.followButtonIndicator.stopAnimating()
                self.followButton.setTitle(NSLocalizedString("unsubscribe", comment: "取消关注"), for:.normal)
                self.followButton.setImage(UIImage(named: "add"), for:UIControlState())
                self.followButton.isEnabled = true
                self.following = true
            }
        })
    }
    
    func unfollow() {
        User.current()?.unfollow((user?.objectId)!, andCallback: { (success, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
                self.followButtonIndicator.stopAnimating()
                self.followButton.isEnabled = true
            } else {

                self.followButtonIndicator.stopAnimating()
                self.followButton.setTitle(NSLocalizedString("Attention", comment: "关注"), for:.normal)
                self.followButton.setImage(nil, for:UIControlState())
                self.followButton.isEnabled = true
                self.following = false
            }
        })
    }
    
    func switchToPage(_ index:Int) {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 4, height: lateralScrollView.bounds.height)
        
        let rect = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.view.frame.width, height: lateralScrollView.frame.height)
        lateralScrollView.manuallyScrollRectToVisible(rect, animated: true)
        
        postedTabButtonLabel.textColor = index == 0 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        followersTabButtonLabel.textColor = index == 2 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        followeesTabButtonLabel.textColor = index == 1 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        likedTabButtonLabel.textColor = index == 3 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        
        postedTabButtonStaticLabel.textColor = index == 0 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        followersTabButtonStaticLabel.textColor = index == 2 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        followeesTabButtonStaticLabel.textColor = index == 1 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        likedTabButtonStaticLabel.textColor = index == 3 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        
        postLineButton.isHidden = index == 0 ? false : true
        followeesLineButton.isHidden = index == 1 ? false : true
        followersLineButton.isHidden = index == 2 ? false : true
        likeLineButton.isHidden = index == 3 ? false : true
        
        self.currentPage = index
        
        if index == 0{
            mainContentViewHeightConstraint.constant = coverImageView.bounds.height  + PostedRecommendationViewHeightConstraint.constant
            lateralScrollViewHeightConstraint.constant = PostedRecommendationViewHeightConstraint.constant
        }else if index == 1{
            mainContentViewHeightConstraint.constant = coverImageView.bounds.height  + followeesUserViewHeightConstraint.constant
            lateralScrollViewHeightConstraint.constant = followeesUserViewHeightConstraint.constant
        }else if index == 2{
            mainContentViewHeightConstraint.constant = coverImageView.bounds.height +  followerUserViewConstraint.constant
            lateralScrollViewHeightConstraint.constant = followerUserViewConstraint.constant
        }else{
            mainContentViewHeightConstraint.constant = coverImageView.bounds.height  + likedRecommendationViewHeigheConstraint.constant
            lateralScrollViewHeightConstraint.constant = likedRecommendationViewHeigheConstraint.constant
        }
    }
    
    func onPostedTabButtonTapped() {

        switchToPage(0)
        if self.tabBarController?.tabBar != nil && (User.current() == nil || self.postedTabButtonLabel.text == "0") {
            noRecommendationNotice.isHidden = false
            postedRecommendationView.emptyStreamMessage = ""
        }
    }
    
    func onFollowersTabButtonTapped() {

        noRecommendationNotice.isHidden = true
        switchToPage(2)
    }
    
    func onFolloweesTabButtonTapped() {

        noRecommendationNotice.isHidden = true
        switchToPage(1)
    }
    
    func onLikedTabButtonTapped() {

        noRecommendationNotice.isHidden = true
        switchToPage(3)
    }
    
    func onavatarImageViewTapped() {
        if user == nil {
            Router.redirectToLoginViewController(fromViewController: self)
            noRecommendationNotice.isHidden = true
        } else if user == AVUser.current() {
            self.isAvatarImageViewChanged = true
            avataSheet = UIActionSheet(title: "更新头像图片", delegate: self, cancelButtonTitle: NSLocalizedString("Cancle", comment: "取消"), destructiveButtonTitle: nil, otherButtonTitles: "拍照","从相册中选择" )
            avataSheet!.show(in: self.view)
        }
    }
    
    func onCoverImageViewTapped() {
        if user == nil {
            Router.redirectToLoginViewController(fromViewController: self)
            noRecommendationNotice.isHidden = true
        }else if user == AVUser.current() {
            self.isAvatarImageViewChanged = false
            coverSheet = UIActionSheet(title: NSLocalizedString("Update background image", comment: "更新背景图像"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancle", comment: "取消"), destructiveButtonTitle: nil, otherButtonTitles: "拍照","从相册中选择" )
            coverSheet!.show(in: self.view)
        }
    }
    
    //MARK: - Methods
    
    func reload() {
        if !initialized {
            return
        }
        
        guard let user = user else {
            self.loadingV.removeFromSuperview()
            fetchData()
            switchToPage(0)
            noRecommendationNotice.isHidden = false
            return
        }
        
        if user != User.current() {
            if User.current() == nil {
                followButton.isHidden = true
                iconLikeAndCountConstraint.priority = 500
            } else {
                followButton.isHidden = false
            }
        } else {
            followButton.isHidden = true
        }
        
        initBasicData()
        
        fetchData()
        setupFollowButton()
        setupiconLikeAndCountView()
        fetchPostCountData()
    }
    func setupiconLikeAndCountView(){
        iconLikeAndCountView.layer.cornerRadius = 15//iconLikeAndCountView.frame.height / 2
        iconLikeAndCountView.layer.borderWidth = 1.0
        iconLikeAndCountView.layer.borderColor = UIColor(red: 195/255.0, green: 195/255.0, blue: 195/255.0, alpha: 1.0).cgColor
        followButtonIndicator.startAnimating()
        
    }
    
    func reloadImagesAndTexts() {
        if let user = user {
            if let cover = user.cover {
                if cover.isDataAvailable() {
                    if let coverFile = cover.file {
                        coverFile.getImageWithBlock( withBlock: { (image, error) -> Void in
                            if error != nil {
                                log.error(error!.localizedDescription)
                            } else {
                                
                                self.coverImageView.image = image?.exchangeImageToBlurImage(3.0)
                            }
                        })
                    }
                } else {
                    cover.fetchIfNeededInBackground({ (object, error) -> Void in
                        if error != nil {
                            log.error("recommendation fetching : \(error!.localizedDescription)")
                        } else {
                            if let coverFile = (object as! Photo).file {
                                
                                coverFile.getImageWithBlock( withBlock: { (image, error) -> Void in
                                    if error != nil {
                                        log.error(error!.localizedDescription)
                                    } else {
                                        self.coverImageView.image = image?.exchangeImageToBlurImage(3.0)
                                    }
                                })
                                
                            }
                        }
                    })
                }
            } else {
                let defaultUserCoverImg = UIImage(named: Config.AppConf.defaultUserCover)
                self.coverImageView.image = defaultUserCoverImg?.exchangeImageToBlurImage(3.0)
            }
            
            avatarImageView.setupForAvatarWithUser(user)
            if let nikename = user.nickname{
                if let tabBar = self.tabBarController{
                    tabBar.navigationItem.title = nikename
                }else{
                    self.navigationItem.title = nikename
                }
            }
            if let msg = user.message {
                self.titleLabel.text = msg
            } else {
                self.titleLabel.isHidden = true
            }
        }
    }
    
    func initBasicData() {
        guard let user = user else { return }
        user.fetchInBackground { (user, error) -> Void in
            if let user = user as? User {
                log.warning("Queries and subqueries limited to 1000 results")
                let likeQuery = Like.query()
                let recommendationQuery = Recommendation.query()
                recommendationQuery.whereKey("author", equalTo: user)
                likeQuery.whereKey("like", matchesQuery: recommendationQuery)
                likeQuery.countObjectsInBackground({ (count, error) -> Void in
                    if error != nil {
                        log.error(error!.localizedDescription)
                    } else {
                        self.loadingV.removeFromSuperview()

                        self.likeLabel.text = "\(count)"
                        self
                        self.calculateLikeIconAndCountWidth(self.likeLabel.text!)
                    }
                })
            }
        }
    }
    
    
    func calculateLikeIconAndCountWidth(_ text:String){
        let label = UILabel()
        label.text = text
        let likeLabelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: likeLabel.bounds.height))
        self.iconLikeAndCountCornerViewWidthConstraint.constant = likeLabelSize.width + self.likeImage.bounds.size.width + likeLabelToLikeImageMarginConstraint.constant
        self.likeLabel.isHidden = false
        self.likeImage.isHidden = false
    }
    
    func initFollowButton() {
        followButtonIndicator.tintColor = Config.Colors.ZanaduCerisePink
        followButtonIndicator.frame.origin.x = followButton.frame.width / 2
        followButtonIndicator.frame.origin.y = followButton.frame.height / 2
        followButton.addSubview(followButtonIndicator)
        followButton.setTitle("", for: UIControlState.disabled)
    }
    
    func setupFollowButton() {
        followButton.isEnabled = false
        
        guard let currentUser = User.current() else {return }
        
        
        //        followButton.backgroundColor = Config.Colors.ZanaduGrey
        followButton.layer.cornerRadius = 15//followButton.frame.height / 2
        followButton.layer.borderWidth = 1.0
        followButton.layer.borderColor = UIColor(red:195.0/255, green: 195.0/255, blue: 195.0/255, alpha: 1.0).cgColor
        followButtonIndicator.startAnimating()
        
        let query = currentUser.followeeQuery()
        query.whereKey("followee", equalTo: user!)
        query.countObjectsInBackground { (count, error) -> Void in
            if error != nil {
                log.error(error!.localizedDescription)
            } else if count > 0 {

                self.followButtonIndicator.stopAnimating()
                self.followButton.setTitle(NSLocalizedString("unsubscribe", comment: "取消关注"), for:.normal)
                self.followButton.setImage(UIImage(named: "add"), for:UIControlState())
                //                self.followButton.backgroundColor = Config.Colors.LightBlueTextColor
                self.followButton.isEnabled = true
                self.following = true
            } else {

                self.followButtonIndicator.stopAnimating()
                self.followButton.setTitle(NSLocalizedString("Attention", comment: "关注"), for:.normal)
                //                self.followButton.backgroundColor = Config.Colors.ZanaduCerisePink
                self.followButton.isEnabled = true
                self.following = false
            }
        }
    }
    
    
    func fetchData() {
        followeesUserView.streamViewDelegate = self
        followeesUserView.selectionDelegate = self
        followeesUserView.pullToRefresh = false
        followeesUserView.loginDelegate = self
        followeesUserView.tapDelegate = self
        
        if let user = user {
            postedRecommendationView.isAuthorInfoHidden = true
            postedRecommendationView.paging = true
            postedRecommendationView.isResetting = true
            postedRecommendationView.streamViewDelegate = self
            followersUserView.streamViewDelegate = self
            likedRecommendationView.streamViewDelegate = self
            
            postedRecommendationView.selectionDelegate = self
            followersUserView.selectionDelegate = self
            likedRecommendationView.selectionDelegate = self
            
            postedRecommendationView.isBiggerCellSize = true
            likedRecommendationView.isBiggerCellSize = true
            
            postedRecommendationView.pullToRefresh = false
            followersUserView.pullToRefresh = false
            likedRecommendationView.pullToRefresh = false
            
            followersUserView.tapDelegate = self
            followersUserView.loginDelegate = self
            
            if postedRecommendationView.fetchStatus != 0 {
                postedRecommendationView.dataQuery = DataQueryProvider.queryForUserRecommendations(user)
                postedRecommendationView.fetchStatus = 0
            }
            followersUserView.dataQuery = DataQueryProvider.userFollowers(user)
            followeesUserView.dataQuery = DataQueryProvider.userFollowees(user)
            likedRecommendationView.dataQuery = DataQueryProvider.recommendationsLikedByUser(user)
        } else {
            followeesUserView.dataQuery = DataQueryProvider.usersFeatured()
        }
    }
    
    func initTabButtons() {
        let postedTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onPostedTabButtonTapped))
        postedTabButtonView.addGestureRecognizer(postedTap)
        let followersTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onFollowersTabButtonTapped))
        followersTabButtonView.addGestureRecognizer(followersTap)
        let followeesTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onFolloweesTabButtonTapped))
        followeesTabButtonView.addGestureRecognizer(followeesTap)
        let likedTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onLikedTabButtonTapped))
        likedTabButtonView.addGestureRecognizer(likedTap)
        followersLineButton.isHidden = true
        followeesLineButton.isHidden = true
        likeLineButton.isHidden = true
    }
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Router.Storyboard = storyboard
        if UIDevice.current.modelName.startsWith("iPhone 5") ||
        Int(UIScreen.main.bounds.width) <= 321 {
            likeParentViewMarginTop.constant = 10
        }
        self.mainScrollView.delegate = self
        self.likeLabel.isHidden = true
        self.likeImage.isHidden = true
        lateralScrollView.autoScrollEnabled = false
        lateralScrollView.delegate = self
        lateralScrollView.isScrollEnabled = false
        initialized = true
        let defaultUserCoverImg = UIImage(named: Config.AppConf.defaultUserCover)
        self.coverImageView.image = defaultUserCoverImg?.exchangeImageToBlurImage(3.0)
        if user == nil {
            user = User.current() as! User?
        }
        if let user = user {
            if let currentUser = User.current() , user == currentUser {
                followButton.isHidden = true
                self.iconLikeAndCountConstraint.priority = 500
            } else {
                followButton.isHidden = false
                self.iconLikeAndCountConstraint.priority = 999
            }
        }
        initFollowButton()
        initTabButtons()
        self.addLoadingView()
        postedRecommendationView.delegate = self
        postedRecommendationView.isScrollEnabled = false
        followersUserView.delegate = self
        followersUserView.isScrollEnabled = false
        followeesUserView.delegate = self
        followeesUserView.isScrollEnabled = false
        likedRecommendationView.delegate = self
        likedRecommendationView.isScrollEnabled = false
        
        avatarImageView.isUserInteractionEnabled = true
        let viewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onavatarImageViewTapped))
        avatarImageView.addGestureRecognizer(viewTap)
        
        coverOverlay.isUserInteractionEnabled = true
        let coverViewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.onCoverImageViewTapped))
        coverOverlay.addGestureRecognizer(coverViewTap)
        switchToPage(0)
        if self.tabBarController?.tabBar != nil && (User.current() == nil || self.postedTabButtonLabel.text == "0") {
            noRecommendationNotice.isHidden = false
            postedRecommendationView.emptyStreamMessage = ""
        }
    }
      func addLoadingView(){
        self.view.addSubview(self.loadingV)
        self.loadingV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    
    @available(iOS 9.0, *)
    lazy var postPreviewDelegate : RecommendationTableViewPreviewDelegate = {
        let previewDelegate = RecommendationTableViewPreviewDelegate(viewController: self, tableview: self.postedRecommendationView, recommendationGetBlock: { (indexPath) -> Recommendation? in
            if (indexPath as NSIndexPath).row < 0 || (indexPath as NSIndexPath).row >= self.postedRecommendationView.recommendations.count{
                return nil
            }
            return self.postedRecommendationView.recommendations[(indexPath as NSIndexPath).row]
        })
        return previewDelegate
    }()
    
    
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: postPreviewDelegate, sourceView: view)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBar = self.tabBarController{
            tabBar.navigationController?.isNavigationBarHidden = false
            tabBar.navigationItem.titleView = nil
            tabBar.navigationItem.leftBarButtonItem = UIBarButtonItem()
            tabBar.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView:settingBtn),UIBarButtonItem(customView:messageView)]
            


            if self.tabBarItem.badgeValue != nil{
                self.messageCountLabel.isHidden = false
                self.messageCountLabel.text = self.tabBarItem.badgeValue
            }else{
                self.messageCountLabel.isHidden = true
            }
        }else{
             self.navigationController?.isNavigationBarHidden = false
             self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItems = nil
            
        }
        //recommendationStream.refresh()
        for  subViews in self.loadingV.subviews{
            if let lodingV = subViews as? SARMaterialDesignSpinner {
                if lodingV.isAnimating {
                    lodingV.stopAnimating()
                    lodingV.startAnimating()
                }
            }
        }
        
        postedRecommendationView.fetchStatus = 1
        if user == User.current() || user == nil && User.current() != nil {
            self.iconLikeAndCountConstraint.priority = 500
        }
        if user == nil {
            user = User.current() as! User?
        }
        reloadImagesAndTexts()
        reload()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    func animateLabel(_ label: UILabel, withNumber number: Int) {
        if number == 0 {
            return
        }
        
        let animationPeriod = 3
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
            for i in 0...number {
                usleep(useconds_t(Int(animationPeriod/number * 1000000))) // sleep in microseconds
                DispatchQueue.main.async(execute: {

                    label.text = "\(i)"
                })
            }
        })
    }
    
    func fetchPostCountData(){
        let query = AVQuery(className:Recommendation.parseClassName())
        query.whereKeyExists("title")
        query.whereKeyExists("cover")
        query.whereKeyExists("author")
        query.whereKey("status", greaterThan: 0)
        query.whereKey("author", equalTo: self.user!)
        query.countObjectsInBackground({ (count, error) -> Void in
            if error != nil{
                log.error(error!.localizedDescription)
            } else {
                if count == 0 && self.currentPage == 0 {
                if self.tabBarController?.tabBar != nil {
                    self.noRecommendationNotice.isHidden = false
                }
                } else {
                    self.noRecommendationNotice.isHidden = true
                }
                self.postedTabButtonLabel.text = "\(count)"
            }
        })
    }
}


extension UserProfileViewController: StreamViewDelegate {
    func onDataFetched(_ streamView: StreamView, objects: [AnyObject]) {
        if streamView == postedRecommendationView {
            
            //            postedTabButtonLabel.text = "\(objects.count)"
        } else if streamView == followersUserView {
            followersTabButtonLabel.text = "\(objects.count)"
        } else if streamView == followeesUserView {
            followeesTabButtonLabel.text = "\(objects.count)"
        } else if streamView == likedRecommendationView {
            likedTabButtonLabel.text = "\(objects.count)"
        }
    }
    
    func onHeightChangedWithStream(_ streamView: StreamView,height: CGFloat) {
        
        if height > lateralContentViewHeightConstraint.constant{
            lateralContentViewHeightConstraint.constant = height
        }
        if streamView == postedRecommendationView {
            if self.currentPage != 10{
                PostedRecommendationViewHeightConstraint.constant = height
                if self.currentPage == 0{
                    switchToPage(0)
                }
                return
            }
            mainContentViewHeightConstraint.constant = coverImageView.bounds.height  + height
            lateralScrollViewHeightConstraint.constant = height
            PostedRecommendationViewHeightConstraint.constant = height
            switchToPage(0)
        } else if streamView == followersUserView {
            followerUserViewConstraint.constant = height
            
        } else if streamView == followeesUserView {
            followeesUserViewHeightConstraint.constant = height
            
        } else if streamView == likedRecommendationView {
            likedRecommendationViewHeigheConstraint.constant = height
            
        }
    }
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        if scrollView == mainScrollView{
            if scrollView.contentSize.height - scrollView.contentOffset.y < 1000{
                if postedRecommendationView.totalItems == postedRecommendationView.recommendations.count{
                    return
                }
                if postedRecommendationView.fetchStatus == 0{
                    return
                }
                postedRecommendationView.currentPage += 1
                postedRecommendationView.fetchData()
                postedRecommendationView.fetchStatus = 0
                
            }
        }
        
    }
}

extension UserProfileViewController: UITableViewDelegate {
    
}

extension UserProfileViewController: RecommendationSelectionProtocol {
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension UserProfileViewController: UserSelectionProtocol {
    func onUserSelected(_ user: User) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension UserProfileViewController:UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.tag == 1{
            if buttonIndex == 1{
                if user != nil {
                    Router.redirectToSettingsMain(fromViewcontroller: self)
                } else {
                    Router.redirectToLoginViewController(fromViewController: self)
                    noRecommendationNotice.isHidden = true
                }
                
            }else if buttonIndex == 2{
                if user != nil {
                    let vc = SettingsUserViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    Router.redirectToLoginViewController(fromViewController: self)
                    noRecommendationNotice.isHidden = true
                }

            }
        }else{
        if buttonIndex == 1{
            let sourceType = UIImagePickerControllerSourceType.camera
            if !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                self.showBasicAlertWithTitle("您的相册不可用,可能是您设置了这个应用禁止访问您的相册,请到设备设置中打开")
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            self.present(picker, animated: true, completion: { () -> Void in
                
            })
        }else if buttonIndex == 2{
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
            if !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
               self.showBasicAlertWithTitle("您的相册不可用,可能是您设置了这个应用禁止访问您的相册,请到设备设置中打开")
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            self.present(picker, animated: true, completion: { () -> Void in
                
            })
 
        }
        }
    }
}

extension UserProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true) { () -> Void in
            //save first
            _ = Photo.init(image: image, completion: { (photo) -> () in
                photo.saveInBackground { (success, error) -> Void in
                    if error != nil{
                        self.showBasicAlertWithTitle("上传失败,请检查网络或重新上传")
                    } else {
                        if self.isAvatarImageViewChanged {
                            self.user?.avatar = photo
                            self.user?.saveInBackground({ (success, error) -> Void in
                                if error != nil{
                                    self.showBasicAlertWithTitle("上传失败,请检查网络或重新上传")
                                } else {
                                    //update
                                    self.avatarImageView.image = image.exchangeImageToBlurImage(3.0)
                                    self.postedRecommendationView.isResetting = true
                                    self.postedRecommendationView.fetchData()
                                    self.showBasicAlertWithTitle(NSLocalizedString("Successfully", comment: "上传成功"))
                                    
                                }
                                
                            })
                        } else {
                            self.user?.cover = photo
                            self.user?.saveInBackground({ (success, error) -> Void in
                                if error != nil{
                                    self.showBasicAlertWithTitle("上传失败,请检查网络或重新上传")
                                }else{
                                    //update
                                    self.coverImageView.image = image.exchangeImageToBlurImage(3.0)
                                    self.showBasicAlertWithTitle(NSLocalizedString("Successfully", comment: "上传成功"))
                                }
                            })
                        }
                    }
                }
            })
        }
    }
}

extension UserProfileViewController: LoginDelegate {
    func needLogin() {
        noRecommendationNotice.isHidden = true
        Router.redirectToLoginViewController(fromViewController: self)
    }
}
extension UserProfileViewController : UserViewCellTapDelegate{
    func userViewCellUnfollowWithCell(_ cell: UserViewCell) {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "确认要取消关注吗?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            cell.unfollow()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
            cell.enableFollowButton()
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}

