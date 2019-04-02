//
//  DiscoverViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class DiscoverViewController: BaseViewController, BannerViewTapDelegate {
    
    let defaultIcon = UIImage(named: "itemDefaultImage")
    lazy var myApplicationDelegate = UIApplication.shared.delegate as! AppDelegate
    //MARK: - Properties
    
    fileprivate var ads = [Ad]()
    fileprivate var isLoaded = false
    
    //MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bannerView: BannerView!
    
    @IBOutlet weak var recommendationSectionsStreamView: RecommendationSectionsStreamView!
    
    @IBOutlet weak var recommendationSectionsStreamViewHeightConstraint: NSLayoutConstraint!
    
    var loadingV = LoadingView()
    
    

    //MARK: - Actions
    
    func onSearchButtonTapped(_ sender:AnyObject) {

        let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        let query =  DataQueryProvider.categoryQuery()
        query.findObjectsInBackground { (objects:[Any]?, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                log.error(error?.localizedDescription)
            }else{
                if let categorys = objects as? [Category]{
                
                let vcs = self.navigationController?.viewControllers

                if vcs?.count > 1{
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSearchViewController") as! GlobalSearchViewController
                vc.rootImage = self.view.screenViewShots()
                self.navigationController?.pushViewController(vc, animated: true)
                vc.categoryArray = categorys
                }else{

                }
            }
        }

        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 2000)
        self.initBannerView()

        let adQuery = Ad.query()
        adQuery.order(byAscending: "position")
        adQuery.cachePolicy = AVCachePolicy.networkElseCache
        adQuery.findObjectsInBackground { (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
                let alert = UIAlertView(title: nil, message: "网络请求出错", delegate: nil, cancelButtonTitle: "ok")
                alert.show()
            } else {
                for ad in objects as! [Ad] {
                    self.ads.append(ad)
                }
                self.bannerView.setbannerObjects(objects as! [AnyObject])
                
                
            }
        }
        DataQueryProvider.sectionsWithPage(0).executeInBackground({ (objects:[Any]?, error) -> () in
            if error != nil {
                log.error("Sections fetching error : \(error!.localizedDescription)")
            } else if let sections = objects as? [Section] , objects!.count > 0 {
                self.recommendationSectionsStreamView.heightChangeDelegate = self
                self.recommendationSectionsStreamView.recommendationSelectionDelegate = self
                self.recommendationSectionsStreamView.sectionSelectionDelegate = self
                self.recommendationSectionsStreamView.setup(sections)
            }
            
        })
        
        if let notificationInfo = myApplicationDelegate.remoteNotificationUserInfo {
            myApplicationDelegate.remoteNotificationUserInfo = nil
            if notificationInfo.targetType == "notificationInfo"{
                let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
                navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = UIViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if let _ = Foundation.UserDefaults.standard.object(forKey: "draftLastStep") {
            self.showDraftAlert()
        }
    }
    
    
       func initBannerView(){
        self.bannerView.delegate = self
        self.bannerView.defaultSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        bannerView.tapShouldResponse = true
        initNavigationBar()
        if isLoaded {
            recommendationSectionsStreamView.update()
            return
        }
        isLoaded = true
    }
    
    func initNavigationBar(){
            self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem()
            let  img1=UIImage(named:"where_logo")
            let frameimg1 = CGRect(x: 0, y: 0, width: img1!.size.width, height: img1!.size.height)
            let logo = UIButton(frame:frameimg1)
            logo.setBackgroundImage(img1, for:UIControlState())
            logo.isUserInteractionEnabled = false
            self.tabBarController?.navigationItem.titleView = logo
//            let frame = CGRect(x: 0, y: 0, width: 144, height: 44);
//            let label = UILabel(frame:frame)
//            label.text = "Altas"
//            label.textColor = UIColor.black;
//            label.textAlignment = .center
//            label.font = UIFont.systemFont(ofSize: 18.0)
//            self.tabBarController?.navigationItem.titleView = label;
        
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem()
            self.tabBarController?.navigationItem.rightBarButtonItems = nil
            let searchImg = UIImage(named:"icon_search")
            let searchFrame = CGRect(x: 0, y: 0, width: 22, height: 22)
            let searchButton = UIButton(frame:searchFrame)
            searchButton.setBackgroundImage(searchImg, for:UIControlState())
            searchButton.addTarget(self, action: #selector(DiscoverViewController.onSearchButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            let searchBarButton = UIBarButtonItem(customView: searchButton)
            self.tabBarController?.navigationItem.rightBarButtonItem = searchBarButton
        
        let notificationCenter = ZanNotificationCenter.sharedCenter
        notificationCenter.badgeValueWithBlock { (value) -> () in
            if value > 0 {
                let tabBar = self.tabBarController?.tabBar
                let item = tabBar!.items![4]
                item.badgeValue = "\(value)"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bannerView.loadTopTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bannerView.setTimerInvalidate()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func BannerViewTapWithIndex(_ index: Int) {
        let ad = ads[index]
        if ad.type == 2 && ad.recommendation != nil {
            if ad.recommendation!.isDataAvailable() {
                onRecommendationSelected(ad.recommendation!)
            } else {
                ad.recommendation?.fetchInBackground({ (object, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {

                        self.onRecommendationSelected(object as! Recommendation)
                    }
                })
            }
        } else if ad.type == 1 && ad.link != nil {
            if let requestUrl = URL(string: ad.link!) {
                UIApplication.shared.openURL(requestUrl)
            }
        }
        
        // leancloud AVAnalytics
        let eventStr = "\(ad.title!) click"
        AVAnalytics.event( "bannerClick", label:eventStr)
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
    }
    
    func removeLoadingView() {
        self.loadingV.isHidden = true
    }
    
    func showDraftAlert() {
        
        let alertController = UIAlertController(title:NSLocalizedString("Tips", comment:"温馨提示"),message:NSLocalizedString("You have unposted updates. Do you want to continue editing?", comment: "您有未上传的动态，是否要继续编辑呢？"), preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:NSLocalizedString("Go to", comment:"前往"), style: UIAlertActionStyle.default,handler: {  action in
            self.alertConfirmClick()
        })
        let cancleAction = UIAlertAction(title: NSLocalizedString("Give up", comment:"放弃"), style: UIAlertActionStyle.default,handler: {  action in
            DraftManager.removeDraftFromSandBox()
            Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
            Foundation.UserDefaults.standard.synchronize()

        })
        alertController.addAction(okAction)
        alertController.addAction(cancleAction)
        if self.navigationController?.viewControllers.count > 0{
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func alertConfirmClick() {
        let step = Foundation.UserDefaults.standard.object(forKey: "draftLastStep") as? String
            if step == "threeStep" {
                let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                let query =  DataQueryProvider.categoryQuery()
                query.findObjectsInBackground { (objects:[Any]?, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if error != nil {
                        log.error(error?.localizedDescription)
                    }else{
                        if let categorys = objects as? [Category]{
                            
                            let vcs = self.navigationController?.viewControllers

                            if vcs?.count > 1{
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreationFormViewController") as! CreationFormViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                            vc.categoriesArray = categorys
                        }else{

                        }
                    }
                }
                
                
            }else if step == "forthStep"{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
    }

}

extension DiscoverViewController: RecommendationSectionsStreamViewHeightDelegate {
    func onHeightChanged(_ height: CGFloat) {
        recommendationSectionsStreamViewHeightConstraint.constant = height
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: height + bannerView.frame.height  + Config.AppConf.navigationBarAndStatuesBarHeight)
        self.removeLoadingView()

    }
}

extension DiscoverViewController: RecommendationSelectionProtocol {
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension DiscoverViewController: SectionSelectionProtocol {
    func onSectionButtonSelected(_ section: Section) {
        // leancloud AVAnalytics
        let eventIdStr = "首页\(section.title!)点击"
        AVAnalytics.event( "sectionTitleClick", label:eventIdStr)
        
        if section.type?.intValue == SectionType.normal.rawValue {
            
            let sectionViewController = storyboard?.instantiateViewController(withIdentifier: "SectionViewController") as! SectionViewController
            sectionViewController.section = section
            navigationController?.pushViewController(sectionViewController, animated: true)
        } else {
            let aroundMeSectionViewController = storyboard?.instantiateViewController(withIdentifier: "AroundMeSectionViewController") as! AroundMeSectionViewController
            aroundMeSectionViewController.section = section
            navigationController?.pushViewController(aroundMeSectionViewController, animated: true)
        }
    }
    
    func onSectionMapButtonSelected(_ section: Section) {
        // leancloud AVAnalytics
        AVAnalytics.event("首页周边地图点击")
        let aroundMapViewController = storyboard?.instantiateViewController(withIdentifier: "AroundMapViewController") as! AroundMapViewController
//        sectionViewController.section = section
        navigationController?.pushViewController(aroundMapViewController, animated: true)
    }
}


@available(iOS 9.0, *)
extension DiscoverViewController  :  UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        var recommendation : Recommendation?
        let recommendationViews = self.recommendationSectionsStreamView.getRecommendationViews()
        recommendationViews.forEach { (recommendationView) in
            let point = self.view.convert(location, to: recommendationView)
            if recommendationView.point(inside: point, with: nil){
                recommendation = recommendationView.recommendation
                return
            }
            
        }
        if recommendation == nil{
            return nil
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        return previewViewController

    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension DiscoverViewController: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

