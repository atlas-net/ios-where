//
//  FriendsViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//
import MJRefresh

class FriendsViewController: BaseViewController ,FollowProtocol{
    
    //MARK: - Properties
    
    @IBOutlet weak var recommendationTopConstraint: NSLayoutConstraint!
    var overlayView: UIView!
    var hasLogIn = false
    var overLayFrameHeight = CGFloat(190)
    var stateBarHeight = CGFloat(20)
    var followCount = 0
    var loadingV = LoadingView()

    var currentPage = 0
    //MARK: - Outlets
    
    @IBOutlet weak var recommendationStream: SearchRecommendationTableView!
    var invitateButton = UIButton()
    
    //    var  friendsStream = SectionedUserStreamView()
    //MARK: - Actions
    
    func onWechatCellTapped() {
        WeixinApi.instance.shareToWechat(Config.Weixin.sharingFriendTitle, description: Config.Weixin.sharingFriendDescription, url: Config.Weixin.appUrl, image: UIImage(named: Config.App.IconName), sharingMethod: WXScene.wxSceneSession)
    }
    
    //MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initOverlayView()
        recommendationStream.contentInset = UIEdgeInsetsMake(Config.AppConf.navigationBarAndStatuesBarHeight, 0, 0, 0)
        recommendationTopConstraint.constant = 0
        recommendationStream.selectionDelegate = self
        recommendationStream.addLoadingView()
        recommendationStream.searchDelegate = self
        recommendationStream.isFromGlobalSearch = true
        recommendationStream.commonInit()
        
        recommendationStream.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.recommendationFetchData()
        })
        if let header = recommendationStream.mj_header as? MJRefreshNormalHeader{
            header.stateLabel.textColor = Config.Colors.SecondTitleColor
            header.lastUpdatedTimeLabel.textColor = Config.Colors.SecondTitleColor
            header.activityIndicatorViewStyle = .gray
            header.arrowView.image = UIImage(named:"refreshArrow")?.withRenderingMode(.alwaysTemplate)
            header.arrowView.tintColor = Config.Colors.SecondTitleColor
            
        }
        recommendationStream.mj_header.isAutomaticallyChangeAlpha = true
        self.addLoadingView()

    }
    
    @available(iOS 9.0, *)
    lazy var previewDelegate : RecommendationTableViewPreviewDelegate = {
        let previewDelegate = RecommendationTableViewPreviewDelegate(viewController: self, tableview: self.recommendationStream, recommendationGetBlock: { (indexPath) -> Recommendation? in
            if (indexPath as NSIndexPath).row < 0 || (indexPath as NSIndexPath).row >= self.recommendationStream.recommendations.count{
                return nil
            }
            return self.recommendationStream.recommendations[(indexPath as NSIndexPath).row]
        })
        return previewDelegate
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: previewDelegate, sourceView: view)
            }
        }
    }
    
    func recommendationFetchData() {
        
        if let _ = User.current() {
            let query = DataQueryProvider.lastRecommendationsFromFriendsSecond()
            query.skip = 20 * currentPage
            recommendationStream.handleQuery(query, currentPage: currentPage)
            hasLogIn = true

        }else{
            let query = DataQueryProvider.lastRecommendationsFromFeaturedUsers()
            recommendationStream.handleSimpleQuery(query)
            hasLogIn = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
        if followCount < 1 {
            fetchrecommendationUsers()
        }
        followCount += 1
        currentPage = 0
         recommendationFetchData()
 
         // if logOut to logIn ,reload it
         if User.current() != nil{
             if !hasLogIn{
                 let query  = DataQueryProvider.lastRecommendationsFromFriends()
                 recommendationStream.handleSimpleQuery(query)
                
             }
         }
        
    }
    func setupNav(){
        let leftString = NSLocalizedString("Dynamic", comment:"动态")
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem()
        self.navigationController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.titleView = nil
        
        self.tabBarController?.navigationItem.title = leftString
        self.navigationController?.isNavigationBarHidden = false
        
        invitateButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        invitateButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        invitateButton.setTitleColor(UIColor.white, for: UIControlState())
        invitateButton.layer.backgroundColor =  UIColor.clear.cgColor
        invitateButton.addTarget(self, action: #selector(FriendsViewController.onWechatCellTapped), for: UIControlEvents.touchUpInside)
        
        let invitateButtonItem = UIBarButtonItem(customView: invitateButton)
        
        let img = UIImage(named: "B_02_Wechat")
        let imgView = UIImageView(image: img)
        imgView.frame = CGRect(x: 34, y:0, width:30, height: 25)
        invitateButton.addSubview(imgView)
//        invitateButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, -40)
        invitateButton.isHidden = false
        self.tabBarController?.navigationItem.rightBarButtonItem = invitateButtonItem
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invitateButton.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    func followCallBack()
    {
        self.recommendationStream.isScrollEnabled = false
        recommendationTopConstraint.constant = 0
        self.recommendationStream.addLoadingView()
        self.currentPage = 0
        self.recommendationStream.recommendations.removeAll()

        recommendationFetchData()
        
    }
    
    func addLoadingView(){
        self.view.addSubview(self.loadingV)
        self.loadingV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        for  subViews in self.loadingV.subviews{
            if let lodingV = subViews as? SARMaterialDesignSpinner {
                if lodingV.isAnimating {
                    lodingV.stopAnimating()
                    lodingV.startAnimating()
                }
            }
        }
        self.view.bringSubview(toFront: self.loadingV)

    }
    
    func removeLoadingView() {
        self.loadingV.removeFromSuperview()
    }

}


//MARK: - RecommendationSelectionProtocol

extension FriendsViewController: RecommendationSelectionProtocol {
    
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    func onAuthorSelected(_ author: User) {
        //            var vc: UserProfileViewController? = self.tabBarController!.viewControllers?.last as? UserProfileViewController
        //            //        var upvc = vc as? UserProfileViewController
        //            vc!.user = author
        //            self.tabBarController?.selectedIndex = 4
    }
}


//MARK: - UserSelectionProtocol

extension FriendsViewController: UserSelectionProtocol {
    func onUserSelected(_ user: User) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

/**
 overlayView management
 
 Here are defined all the overlayView and it's UserStreamView related methods
 */
extension FriendsViewController {
    
    func initOverlayView() {
        if overlayView == nil {
            let overLayFrame = CGRect(x: 0, y: Config.AppConf.navigationBarAndStatuesBarHeight, width: UIScreen.main.bounds.width, height: overLayFrameHeight - 65)
            overlayView = UIView(frame: overLayFrame)
            overlayView.backgroundColor =  Config.Colors.RecommendFriendsBackColor
            
            let friendsStreamFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: overLayFrameHeight)
            let friendsStream = SectionedUserStreamView()
            friendsStream.frame =  friendsStreamFrame
            friendsStream.isFromFriends = true
            friendsStream.backgroundColor = UIColor.clear
            friendsStream.sectionedUserStreamViewDelegate = self
            friendsStream.selectionDelegate = self
            friendsStream.loginDelegate = self
            friendsStream.tapDelegate = self
            friendsStream.setCustomSectionWithName(NSLocalizedString("Recommended", comment:"好友推荐"))
            friendsStream.isScrollEnabled = false
            overlayView.clipsToBounds = true
            friendsStream.backgroundColor = Config.Colors.RecommendFriendsBackColor
            friendsStream.sectionedFollowDelegate = self
            overlayView.addSubview(friendsStream)
            recommendationStream.tableHeaderView = overlayView
        }
    }
    
    func fetchrecommendationUsers() {
        let friendsStream = (overlayView.subviews[0] as! SectionedUserStreamView)
        friendsStream.isFromFriends = true
        friendsStream.setCustomSectionWithName(NSLocalizedString("Recommended", comment:"好友推荐"))
        if let user = User.current(){
            friendsStream.dataQuery = DataQueryProvider.usersUnFollow(user as! User)
        } else {
            friendsStream.dataQuery = DataQueryProvider.usersFeatured()
        }
        
    }
}

extension FriendsViewController: SectionedUserStreamViewDelegate {
    func onDataFetched(_ users: [String : [User]]) {
//        self.removeLoadingView()
//        if Array(users.keys).count == 0 {
//            overlayView.removeFromSuperview()
//            recommendationStream.tableHeaderView = UIView()
//        }
//        else  if Array(users.keys).count == 1 {
//            overlayView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, overLayFrameHeight - 75)
//            recommendationStream.tableHeaderView = overlayView
//
//        } else  if Array(users.keys).count > 1 {
//            overlayView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, overLayFrameHeight)
//            recommendationStream.tableHeaderView = overlayView
//            
//        }
    }
    
    func onDataFetchedNew(_ users: [User]){
        self.removeLoadingView()
        if users.count == 0 {
            overlayView.removeFromSuperview()
            recommendationStream.tableHeaderView = UIView()
        }
        else  if users.count == 1 {
            overlayView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: overLayFrameHeight - 75)
            recommendationStream.tableHeaderView = overlayView
            
        } else  if users.count > 1 {
            overlayView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: overLayFrameHeight)
            recommendationStream.tableHeaderView = overlayView
            
        }

    }
}


extension FriendsViewController: LoginDelegate {
    func needLogin() {
        Router.redirectToLoginViewController(fromViewController: self)
    }
}
extension FriendsViewController : UserViewCellTapDelegate{
    func userViewCellUnfollowWithCell(_ cell: UserViewCell) {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "确认要取消关注吗?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            
            cell.unfollow()
            self.recommendationStream.isScrollEnabled = false
            self.recommendationStream.addLoadingView()
            self.currentPage = 0
            self.recommendationFetchData()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
            cell.enableFollowButton()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension FriendsViewController: SearchRecommendationTableViewDelegate{
    
    func SearchRecommendationTableViewRefreshCallBack(){
        currentPage += 1
        recommendationFetchData()
    }
}

