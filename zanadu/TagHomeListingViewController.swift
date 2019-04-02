//
//  TagHomeListingViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Display a page with cover, tabs and listings
*/
class TagHomeListingViewController : BaseViewController,NYTPhotosViewControllerDelegate {
    
    //MARK: - Properties
    var tag: Tag! {
        didSet {
            tagDidSet()
        }
    }
    
    let defaultCoverImage = UIImage(named: "coverBg")
    fileprivate var currentPage = 0
    var lastScrollOffset: CGFloat = 0
    var loadingV = LoadingView()
    var recommendation: Recommendation!
    fileprivate var fetcher = SearchResultFetcher()
    
    //MARK: - Outlets
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var homeListingCoverView: HomeListingCoverView!
    @IBOutlet weak var tabButtonsContainer: UIView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var popularityLabel: UILabel!
    
    @IBOutlet weak var leftTabButtonView: UIView!
    @IBOutlet weak var middleTabButtonView: UIView!
    @IBOutlet weak var rightTabButtonView: UIView!
    
    @IBOutlet weak var leftTabButtonLabel: UILabel!
    @IBOutlet weak var middleTabButtonLabel: UILabel!
    @IBOutlet weak var rightTabButtonLabel: UILabel!
    
    @IBOutlet weak var allRecommendationView: RecommendationStreamView!
    
    @IBOutlet weak var allRecommendationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var aroundRecommendationView: RecommendationStreamView!
    
    
    @IBOutlet weak var aroundRecommendationViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var popularRecommendationView: RecommendationStreamView!
    
    @IBOutlet weak var popularRecommendationViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var lateralScrollView: NoAutoScrollUIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lateralScrollViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Actions
    
    func switchToPage(_ index:Int) {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: lateralScrollView.bounds.height)
        
        let rect = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.view.frame.width, height: lateralScrollView.frame.height)
        lateralScrollView.manuallyScrollRectToVisible(rect, animated: true)
        
        leftTabButtonView.backgroundColor = index == 0 ? Config.Colors.TagFieldBackground : Config.Colors.TagViewBackground
        middleTabButtonView.backgroundColor = index == 1 ? Config.Colors.TagFieldBackground : Config.Colors.TagViewBackground
        rightTabButtonView.backgroundColor = index == 2 ? Config.Colors.TagFieldBackground : Config.Colors.TagViewBackground
        
        leftTabButtonLabel.textColor = index == 0 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        middleTabButtonLabel.textColor = index == 1 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        rightTabButtonLabel.textColor = index == 2 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        
        self.currentPage = index
        
        var tabBarHeight: CGFloat = 0
        if let tabBarController = tabBarController {
            tabBarHeight = tabBarController.tabBar.bounds.height
        }
        
        if index == 0{
            mainContentViewHeightConstraint.constant = coverImage.bounds.height  + tabButtonsContainer.frame.size.height + allRecommendationViewHeightConstraint.constant + tabBarHeight
            lateralScrollViewHeightConstraint.constant = allRecommendationViewHeightConstraint.constant
        }else if index == 1{
            mainContentViewHeightConstraint.constant = coverImage.bounds.height  + aroundRecommendationViewHeightConstraint.constant + tabButtonsContainer.frame.size.height + tabBarHeight
            lateralScrollViewHeightConstraint.constant = aroundRecommendationViewHeightConstraint.constant
        }else {
            mainContentViewHeightConstraint.constant = coverImage.bounds.height + tabButtonsContainer.frame.size.height + popularRecommendationViewHeightConstraint.constant + tabBarHeight
            lateralScrollViewHeightConstraint.constant = popularRecommendationViewHeightConstraint.constant
        }

    }
    
    func onLeftTabButtonTapped() {

        switchToPage(0)
    }
    
    func onMiddleTabButtonTapped() {

        switchToPage(1)
    }
    
    func onRightTabButtonTapped() {

        switchToPage(2)
    }
    
    
    //MARK: - Methods
    
    func tagDidSet() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tmpObject = self.tag
    }
    
    func initTabButtons() {
        let leftButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagHomeListingViewController.onLeftTabButtonTapped))
        leftTabButtonView.addGestureRecognizer(leftButtonTap)
        
        let middleButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagHomeListingViewController.onMiddleTabButtonTapped))
        middleTabButtonView.addGestureRecognizer(middleButtonTap)
        
        let rightButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagHomeListingViewController.onRightTabButtonTapped))
        rightTabButtonView.addGestureRecognizer(rightButtonTap)
    }
    
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.mainScrollView.delegate = self
        self.view.backgroundColor = Config.Colors.TagFieldBackground
        mainScrollView.backgroundColor = Config.Colors.TagFieldBackground
        mainContentView.backgroundColor = Config.Colors.TagFieldBackground
        tabButtonsContainer.backgroundColor = Config.Colors.TagFieldBackground
        lateralScrollView.backgroundColor = Config.Colors.TagFieldBackground
        contentView.backgroundColor = Config.Colors.TagFieldBackground
        coverImage.layer.masksToBounds = true
        lateralScrollView.isScrollEnabled = false
        //lateralScrollView.delegate = self
        
        switchToPage(0)
        
        title = tag!.name
        titleLabel.text = " " + tag!.name + " "
        titleLabel.backgroundColor = Config.Colors.TagViewColor
        
        allRecommendationView.streamViewDelegate = self
        aroundRecommendationView.streamViewDelegate = self
        popularRecommendationView.streamViewDelegate = self
        
        allRecommendationView.selectionDelegate = self
        aroundRecommendationView.selectionDelegate = self
        popularRecommendationView.selectionDelegate = self
        
        allRecommendationView.pullToRefresh = false
        aroundRecommendationView.pullToRefresh = false
        popularRecommendationView.pullToRefresh = false
        
        allRecommendationView.isScrollEnabled = false
        aroundRecommendationView.isScrollEnabled = false
        popularRecommendationView.isScrollEnabled = false
        
        allRecommendationView.fetchStatus = 1
        allRecommendationView.paging = true
        allRecommendationView.isResetting = true
        
        aroundRecommendationView.fetchStatus = 1
        aroundRecommendationView.paging = true
        aroundRecommendationView.isResetting = true
        
        popularRecommendationView.fetchStatus = 1
        popularRecommendationView.paging = true
        popularRecommendationView.isResetting = true
        
        
        allRecommendationView.dataQuery = DataQueryProvider.queryForTagRecommendations(tag!)
        popularRecommendationView.dataQuery = DataQueryProvider.queryForPopularTagRecommendations(self.tag!)
        aroundRecommendationView.dataQuery = DataQueryProvider.queryForAroundTagRecommendations(Location.shared, forTag: tag)
        initTabButtons()
        setupCover()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.loadingV)
    }
    
    func setupCover(){
        let dataQuery = DataQueryProvider.queryForTagMostLikedRecommendation(tag)
        dataQuery.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil && count > 0{
                dataQuery.executeInBackground({ (objects:[Any]?, error) -> () in
                    if error != nil{
                        log.error(error?.localizedDescription)
                    }else{
                        self.handleQueryForObjects(objects!)
                    }
                })
            }
        }
    }
    
    func handleQueryForObjects(_ objects: [Any]) {
        fetcher.emptyTmpQueries()
        var recommendations = [Recommendation]()
        for obj in objects {
            if  (obj as! AVObject).isKind(of: Recommendation.self){
                recommendations.append(obj as! Recommendation)
            }
        }
        self.recommendation = recommendations.first
        if let cover = self.recommendation.cover {
                cover.fetchIfNeededInBackground({ (object, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else if let file = cover.file {
                        self.coverImage.image = nil
                        file.getImageWithBlock( withBlock: { (image, error) -> Void in
                            if error != nil {
                                log.error(error?.localizedDescription)
                            } else {
                                self.coverImage.image = image
                                
                            }
                        })
                    }
                })
            }
        
    }
}

extension TagHomeListingViewController: StreamViewDelegate {
    func onDataFetched(_ streamView: StreamView, objects: [AnyObject]) {
        if streamView == allRecommendationView {
            if let text = popularityLabel.text {
                popularityLabel.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: 3)) + "\(objects.count)"
            }
        }
    }
    func onHeightChangedWithStream(_ streamView: StreamView, height: CGFloat) {
        self.loadingV.removeFromSuperview()
        var tabBarHeight: CGFloat = 0
        if let tabBarController = tabBarController {
            tabBarHeight = tabBarController.tabBar.bounds.height
        }
        if streamView == allRecommendationView {
            allRecommendationViewHeightConstraint.constant = height
            mainContentViewHeightConstraint.constant = coverImage.bounds.height  + height + tabBarHeight + tabButtonsContainer.frame.size.height
            lateralScrollViewHeightConstraint.constant = height
            switchToPage(0)
            
        } else if streamView == aroundRecommendationView {
            aroundRecommendationViewHeightConstraint.constant = height
            mainContentViewHeightConstraint.constant = coverImage.bounds.height  + height + tabBarHeight + tabButtonsContainer.frame.size.height
            lateralScrollViewHeightConstraint.constant = height
            
        } else if streamView == popularRecommendationView {
            popularRecommendationViewHeightConstraint.constant = height
            mainContentViewHeightConstraint.constant = coverImage.bounds.height  + height + tabBarHeight + tabButtonsContainer.frame.size.height
            lateralScrollViewHeightConstraint.constant = height
            
        }


    }
    
}

extension TagHomeListingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView{
            if currentPage == 0{
                if scrollView.contentSize.height - scrollView.contentOffset.y < 1000{
                    if allRecommendationView.totalItems == allRecommendationView.recommendations.count{
                        return
                    }
                    if allRecommendationView.fetchStatus == 0{
                        return
                    }
                    allRecommendationView.currentPage += 1
                    allRecommendationView.fetchData()
                    allRecommendationView.fetchStatus = 0
                    
                }
            }
            else if currentPage == 1{
                if scrollView.contentSize.height - scrollView.contentOffset.y < 1000{
                    if aroundRecommendationView.totalItems == aroundRecommendationView.recommendations.count{
                        return
                    }
                    if aroundRecommendationView.fetchStatus == 0{
                        return
                    }
                    aroundRecommendationView.currentPage += 1
                    aroundRecommendationView.fetchData()
                    aroundRecommendationView.fetchStatus = 0
                    
                }
                
            }else{
                if scrollView.contentSize.height - scrollView.contentOffset.y < 1000{
                    if popularRecommendationView.totalItems == popularRecommendationView.recommendations.count{
                        return
                    }
                    if popularRecommendationView.fetchStatus == 0{
                        return
                    }
                    popularRecommendationView.currentPage += 1
                    popularRecommendationView.fetchData()
                    popularRecommendationView.fetchStatus = 0
                }
                
            }
            
            
        }

    }
}

extension TagHomeListingViewController: RecommendationSelectionProtocol {
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}
