//
//  GlobalSearchViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/29/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import TagListView
import MJRefresh
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


//categorySearch
struct CitySwitchLocation {
    
    static  let BeiJingLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: Double(39.915118999999997), longitude: Double(116.403963)), altitude: Double(0.0), horizontalAccuracy: Double(65.0), verticalAccuracy: Double(10.0), timestamp: Date())
    static let BeijingRadius = 76000
    
    static let ShangHaiLocation = CLLocation(coordinate:CLLocationCoordinate2D(latitude: Double(31.23000000000), longitude: Double(121.48000000000)), altitude: Double(0.0) , horizontalAccuracy: Double(100.0), verticalAccuracy: Double(-1.0), timestamp: Date())
    static let ShanghaiRadius = 46000

    
    static  let TokyoLocation = CLLocation(coordinate:CLLocationCoordinate2D(latitude:35.42 , longitude: 139.46), altitude: Double(0.0) , horizontalAccuracy: Double(0.0), verticalAccuracy: Double(0.0), timestamp: Date())
    static let TokyoRadius = 67000

    static   let NewYorkLocation = CLLocation(coordinate:CLLocationCoordinate2D(latitude: 40.7680617094 , longitude:-73.9767837524 ), altitude: Double(0.0) , horizontalAccuracy: Double(0.0), verticalAccuracy: Double(0.0), timestamp: Date())
    static let NewYorkRadius = 17000

    static   let AllLocation = CLLocation(coordinate:CLLocationCoordinate2D(latitude: 0 , longitude:0 ), altitude: Double(0.0) , horizontalAccuracy: Double(0.0), verticalAccuracy: Double(0.0), timestamp: Date())
}

enum ECity : String{
    case ALL = "all"
    case BEIJING = "beijing"
    case SHANGHAI = "shanghai"
    case TOKYO = "tokyo"
    case NEWYORK = "newyork"
}

/**

*/
class GlobalSearchViewController: BaseViewController, UISearchBarDelegate, RecommendationSelectionProtocol, UserSelectionProtocol,CLLocationManagerDelegate {

    enum FeedType {
        case venue,recommendation,user
    }
    enum GlobalSearchType {
        case allCategory,cityCategory,allInput,cityInput
    }
    
    //MARK: - Outlets

    @IBOutlet weak var leftTabButtonView: UIView!
    @IBOutlet weak var middleTabButtonView: UIView!
    @IBOutlet weak var rightTabButtonView: UIView!
    
    @IBOutlet weak var leftTabButtonLabel: UILabel!
    @IBOutlet weak var middleTabButtonLabel: UILabel!
    @IBOutlet weak var rightTabButtonLabel: UILabel!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var tableViewMiddle:SearchRecommendationTableView!
    @IBOutlet weak var tableViewRight: UserStreamView!
    
    @IBOutlet weak var lateralScrollView: NoAutoScrollUIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var tagListView: PositionScrollView!
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var historyScrollView: UIScrollView!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    
    @IBOutlet weak var searchLabel1: UILabel!
    @IBOutlet weak var searchLabel2: UILabel!
    @IBOutlet weak var searchLabel3: UILabel!
    @IBOutlet weak var searchLabel4: UILabel!
    @IBOutlet weak var searchLabel5: UILabel!
    @IBOutlet weak var searchLabel6: UILabel!
    @IBOutlet weak var searchLabel7: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    //CategoryCatalog
    @IBOutlet weak var categoryOverFlowView: UIView!
    @IBOutlet weak var categoryListView: CategoryListsView!
    
    @IBOutlet weak var hotSearchlab: UILabel!
    @IBOutlet weak var hotSearchTagView: UIView!
    
    
    @IBOutlet weak var bgCoverView: UIView!
    
    //MARK: - Properties
    var rootImage: UIImage?
    var searchBar: UISearchBar!
    lazy var fetcher = SearchResultFetcher()
    lazy var venueArray = [Venue]()
    lazy var searchArray = [Search]()
    var currentPage = 0
    var currentCity = ""
    var selectedCity = ""
    var selectCityEnum = ECity.ALL
    var skipParam : AnyObject?
    var venueQuery: ConcurrentSimpleQuery?
    
    fileprivate var keyboardChange = false
    lazy var loadingV:LoadingView = {
      return LoadingView()
    }()
    var searchType : GlobalSearchType?
    var categoryArray = [Category]()
    
    //begin
    lazy var leftButton:LocationView = {
        return LocationView()
    }()
    let all = NSLocalizedString("All", comment:"全部")
    var localLocation : CLLocation!
    var currLocation : CLLocation!
    let locationManager : CLLocationManager = CLLocationManager()
    fileprivate var cellIdentifer = "CategoryCatalogCell"
    let titleArray = ["咖啡","酒吧","餐厅","酒店","购物","娱乐","其他"]
    var fsVenueIdArray = [String]()
    
    var tagCurrentPage = 0
    var tagLimit = 20
    var locationInputLimit = 100

    var currentRadius = 0
    
    var categoryName = ""

    var category : Category!{
        didSet{
            setCategoty()
        }
    }
    var historySearchCounts = 0
    lazy var CurrentQuerys = [AVQuery]()
    @IBOutlet weak var bgImageHeightConstraint: NSLayoutConstraint!
    //end
    
    //MARK: - Actions
    
    @IBAction func reloadData(_ sender:AnyObject) {
        print("reload", terminator: "")
        print(sender, terminator: "")
        //        self.viewHandler.reloadData("", tableView: self.tableView) { () -> Void in
        //            print("reload block")
        //            if sender.respondsToSelector(NSSelectorFromString("endRefreshing")) {
        //                print("responds")
        //                sender.endRefreshing()
        //            }
        //        }
    }

    func onCancelButtonTapped() {

        navigationController?.popViewController(animated: true)
    }
    
    func switchToPage(_ index:Int) {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 4, height: lateralScrollView.bounds.height)
        
        let rect = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.view.frame.width, height: lateralScrollView.frame.height)
        lateralScrollView.manuallyScrollRectToVisible(rect, animated: true)
        
        leftTabButtonView.backgroundColor = index == 0 ? Config.Colors.MainContentBackgroundWhite : UIColor.white
        middleTabButtonView.backgroundColor = index == 1 ? Config.Colors.MainContentBackgroundWhite : UIColor.white
        rightTabButtonView.backgroundColor = index == 2 ? Config.Colors.MainContentBackgroundWhite : UIColor.white
        
        leftTabButtonLabel.textColor = index == 0 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        middleTabButtonLabel.textColor = index == 1 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        rightTabButtonLabel.textColor = index == 2 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        
        self.currentPage = index
    }
    
    func onLeftTabButtonTapped() {

        switchToPage(0)
//        self.searchBar.endEditing(true)
    }
    
    func onMiddleTabButtonTapped() {

        switchToPage(1)
//        self.searchBar.endEditing(true)
    }
    
    func onRightTabButtonTapped() {

        switchToPage(2)
//        self.searchBar.endEditing(true)
    }
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        bgImageHeightConstraint.constant = UIScreen.main.bounds.height - 64
        if let image = self.rootImage{
        self.bgImage.image = image.exchangeImageToBlurImage(4.0)
        }
        bgCoverView.backgroundColor = Config.Colors.MainContentBackgroundWhite

        tableViewRight.pullToRefresh = false
        tableViewRight.loginDelegate = self
        tableViewRight.tapDelegate = self
        
        lateralScrollView.autoScrollEnabled = false
        
        tableViewMiddle.searchDelegate = self
        tableViewMiddle.selectionDelegate = self
        tableViewMiddle.isFromGlobalSearch = true
        tableViewMiddle.commonInit()
        tableViewRight.selectionDelegate = self
        tableViewRight.isFromGlobalSearch = true
        tableViewRight.commonInit()
        tableViewRight.refreshDelegate = self

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.keyboardAppearance = UIKeyboardAppearance.default
        contentView.frame.size.width = UIScreen.main.bounds.width * 3
        historyScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        initTabButtons()
        hideOverlay()
        initCateList()
    }
    
    func initCateList() {

        categoryListView.currType = .noTitleView
        categoryListView.categoryArray = categoryArray
        categoryListView.initWithType()
        categoryListView.selectedCategoryArray.removeAll()
        categoryListView.delegate = self
        self.view.bringSubview(toFront: categoryOverFlowView)
        
        
        
        
        hotSearchlab.textColor = Config.Colors.MainContentColorBlack
        hotSearchlab.backgroundColor = UIColor.clear
        
        hotSearchTagView.backgroundColor = UIColor.clear
        let nameArray = ["米其林","安缦","下午茶","长城"]
        var x = 0
        for i in 0...3{
            let str = nameArray[i]
            let strLength = str.characters.count*15 + 20
            let tagButton = UIButton()
            tagButton.frame = CGRect(x: CGFloat(x), y: 33 , width: CGFloat(strLength), height: 24)
            tagButton.clipsToBounds = true
            tagButton.layer.cornerRadius = 3
            tagButton.layer.borderWidth = 1
            tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            
            tagButton.layer.borderColor = Config.Colors.SecondTitleColor.cgColor
            tagButton.backgroundColor = UIColor.clear
            tagButton.setTitle(str, for:UIControlState())
            tagButton.setTitleColor(Config.Colors.SecondTitleColor,for:.normal)
            hotSearchTagView.addSubview(tagButton)
            //传递触摸对象（即点击的按钮），需要在定义action参数时，方法名称后面带上冒号
            tagButton.addTarget(self,action:#selector(GlobalSearchViewController.tapped(_:)),for:.touchUpInside)
            x += strLength + 20
        }
        currLocation = CitySwitchLocation.AllLocation
        
    }
    func tapped(_ button:UIButton){
        self.hideCateListView()
        self.addCircleLoadingView()
        self.clearResultUI()
        print(button.title(for: UIControlState()))
        let str = button.title(for: UIControlState())!
        self.leftButton.settitle(all)
        self.matchCurrentLocation(all)
        searchBar.text = str

        globalSearchWithString(str)

        hideOverlay()
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(all, forKey: "city")
        userDefaults.synchronize()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNav()
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(GlobalSearchViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object:nil)
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(GlobalSearchViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object:nil)
        reactiveLoadingAnimation()
        
    }
    
    func reactiveLoadingAnimation() {
        for  subViews in self.loadingV.subviews{
            if let lodingV = subViews as? SARMaterialDesignSpinner {
                if lodingV.isAnimating {
                    lodingV.stopAnimating()
                    lodingV.startAnimating()
                }
            }
        }
    }
    func setupNav(){
        self.navigationController?.isNavigationBarHidden = false
        for subObj in (self.navigationController?.navigationBar.subviews)! {

        }

        searchBar.barTintColor = Config.Colors.TagViewBackground
        searchBar.tintColor = Config.Colors.ButtonLightPink
        searchBar.keyboardAppearance = UIKeyboardAppearance.default
        searchBar.placeholder = NSLocalizedString("Search", comment:"搜索")
        searchBar.backgroundImage = UIImage()
        let searchImg = UIImage(named:"icon_search")
        let  searchTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        searchBar.setImage(searchImg, for: .search, state: UIControlState())
        searchTextField?.textColor = Config.Colors.FirstTitleColor
        searchTextField?.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        searchTextField?.font = UIFont.systemFont(ofSize: 12)
        let textFieldInsideSearchBarLabel = searchTextField!.value(forKey: "placeholderLabel")as?UILabel
        textFieldInsideSearchBarLabel?.textColor = Config.Colors.CateCellTextColor
        self.navigationItem.titleView = searchBar

        let cancleFrame = CGRect(x: 0, y: 0, width: 60, height: 40)
        let cancelButton = UIButton(frame: cancleFrame)
        cancelButton.setTitle(NSLocalizedString("Cancle", comment: "取消"), for: UIControlState())
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.setTitleColor(Config.Colors.SecondTitleColor, for:.normal)
        cancelButton.addTarget(self, action: #selector(GlobalSearchViewController.onCancelButtonTapped), for: UIControlEvents.touchUpInside)
        let cancelBarButton = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.rightBarButtonItem = cancelBarButton

        let leftButtonFrame = CGRect(x: 0, y: 0, width: 60, height: 62)
        leftButton.frame = leftButtonFrame
        leftButton.create()
        leftButton.settitle(all)
        if let localCity = Foundation.UserDefaults.standard.object(forKey: "city") as? String {
            self.leftButton.settitle(localCity)
            self.matchCurrentLocation(localCity)
        }
        if selectedCity != "" {
            leftButton.settitle(selectedCity )
            matchCurrentLocation(selectedCity)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSelectCityButtonTapped))
        leftButton.addGestureRecognizer(tap)
        leftButton.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        keyboardChange = false
        AVQuery.clearAllCachedResults()
        let geocoder = CLGeocoder()
        geocoder.cancelGeocode()
        clearCurrentQuery()
    }
    
    @available(iOS 9.0, *)
    lazy var previewDelegate : RecommendationTableViewPreviewDelegate = {
        let previewDelegate = RecommendationTableViewPreviewDelegate(viewController: self, tableview: self.tableViewMiddle, recommendationGetBlock: { (indexPath) -> Recommendation? in
            if (indexPath as NSIndexPath).row < 0 || (indexPath as NSIndexPath).row >= self.tableViewMiddle.recommendations.count{
                return nil
            }
            return self.tableViewMiddle.recommendations[(indexPath as NSIndexPath).row]
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if  historySearchCounts > 0 {
            return
        }
        initOverlay()
        initTagPanel()

        lateralScrollView.contentSize = contentView.frame.size
        localLocation = Location.shared
        if  let cityTitle = Foundation.UserDefaults.standard.object(forKey: "city")  {
            selectedCity = cityTitle as! String
            leftButton.settitle(selectedCity )
            matchCurrentLocation(selectedCity)

        }
        self.reverse(localLocation)
    }
    

    //MARK: - Methods
    
    func initTagPanel() {
        self.leftView.backgroundColor = Config.Colors.MainContentBackgroundWhite
        
        let scrollWidth = UIScreen.main.bounds.size.width
        let scrollHeight = UIScreen.main.bounds.size.height - 52 -  Config.AppConf.navigationBarAndStatuesBarHeight
        tagListView.showsVerticalScrollIndicator = true
        tagListView.isScrollEnabled = true
        tagListView.isDirectionalLockEnabled = true
        let rect = CGRect(x: 0, y: 0, width: scrollWidth, height: scrollHeight)
        tagListView.positionViewDelegate = self
        tagListView.setDefaultCompents(rect)
        tagListView.contentSize = tagListView.bounds.size
        tagListView.backgroundColor = UIColor.white
        self.tagListView.maximumHeight = self.tagListView.frame.height
    }
    
    
    func initTabButtons() {
        let leftTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onLeftTabButtonTapped))
        leftTabButtonView.addGestureRecognizer(leftTap)
        let middleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onMiddleTabButtonTapped))
        middleTabButtonView.addGestureRecognizer(middleTap)
        let rightTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onRightTabButtonTapped))
        rightTabButtonView.addGestureRecognizer(rightTap)
        

        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: lateralScrollView.bounds.height)


    }
    
    func addCircleLoadingView() {
        let window = UIApplication.shared.keyWindow

        let darkGaryBgView = UIView()
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height )
        self.loadingV.backImageView.isHidden = true
        self.loadingV.whereImageView.isHidden = true
        window!.addSubview(loadingV)
        reactiveLoadingAnimation()

    }
    
    func  setCategoty(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tmpObject = self.category as AnyObject?
        
    }
    func backBtnClick(_ sender: AnyObject){
        self.loadingV.removeFromSuperview()
        self.onCancelButtonTapped()
    }

    func removeLoadingView(){

        self.loadingV.removeFromSuperview()
    }
    
    func globalSearchWithString(_ string: String) {
        self.globalSearchVenueMatchString(string)
        
        self.tableViewMiddle.recommendationRefreshType = .titleMatch
        self.tableViewMiddle.titleRecommendationId.removeAll()
        skipParam = nil
        self.queryRecommendationMatchTitle(string)
        
        self.searchUserMatch(string)
    }
    
    func globalSearchVenueMatchString(_ string : String) {
        searchType = .allInput
        
        let query = DataQueryProvider.queryForVenuesMatchingString(string)
        query.limit = tagLimit
        query.skip = tagLimit*tagCurrentPage
        
        query.countObjectsInBackground { (count, error) -> Void in
            
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if count == 0{

                self.searchDoneWithoutResult(.venue)
                self.tagListView.mj_footer.endRefreshingWithNoMoreData()
            }else{
                
                query.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        if objects != nil && objects?.count > 0 {
                            let paging = true
                            //                                delay(Double(i) * 0.2) {
                            self.categorySearchDoneWithResult(objects as! [AnyObject], forFeed: .venue, withPaging: paging)
                            //                                }
                        } else {
                            self.tagListView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                })
            }
        }

    }
    func searchDoneWithResult(_ objects: [AnyObject], forFeed feed: FeedType, withPaging paging: Bool = false) {

        switch feed {
        case .venue:
            if paging {
                venueArray += objects as! [Venue]
            } else {
                venueArray = objects as! [Venue]
            }
            self.fillTagViewWithArray(self.venueArray)
            self.removeLoadingView()
        default:
            return
        }
    }
    
    func categorySearchDoneWithResult(_ objects: [AnyObject], forFeed feed: FeedType, withPaging paging: Bool = false) {

        switch feed {
        case .venue:
            if paging {
                venueArray += objects as! [Venue]
            } else {
                venueArray = objects as! [Venue]
            }
            self.fillTagViewWithArray(self.venueArray)
            self.removeLoadingView()
            if self.searchType == .cityCategory{
                if self.searchType == .cityCategory{
                    self.tableViewMiddle.recommendationRefreshType = .cityCate
                }else{
                    self.tableViewMiddle.recommendationRefreshType = .cityInput
                    
                }
            }

        default:
            return
        }
    }
    
    func searchDoneWithoutResult(_ feed: FeedType) {

        venueArray.removeAll()
        tagListView.deleteAllTags()
        self.tableViewMiddle.emptyStreamLabel.isHidden = false
        self.removeLoadingView()

    }
    
    
    func fillTagViewWithArray(_ array: [Venue]){
        var tags = [TagControl]()
        let diffArray =  filterSameVenues(array)
        self.tagListView.tags.removeAll()
        if diffArray.count > 0 {
            for location in diffArray {
                guard let customName = location.customName else{
                    continue
                }
                let tagControl = TagControl(title: "\(customName)", object: location)
                tagControl.tagBackgroundColor = UIColor.clear
                tagControl.borderColor = Config.Colors.SecondTitleColor
                tagControl.borderWidth = 1
                tagControl.tagTextColor = Config.Colors.SecondTitleColor
                tagControl.maxWidth = self.tagListView.frame.width / 2 - 32
                tags.append(tagControl)
                
                self.tagListView.addTag(tagControl)
                
                
                print("\(location.customName)")
            }
            self.tagListView.tagSize()
        }
        self.tagListView.mj_footer.endRefreshing()

    }
    
    func filterSameVenues(_ array: [Venue]) -> [Venue] {
        var venueArr = [Venue]()
        for i in 0..<array.count{
            let ven = array[i]
            var repeats = 0
            venueArr.append(ven)
            for j in 0..<venueArr.count{

                let ven1 = venueArr[j]

                var equals = false
                if (ven1.customName != nil) && (ven.customName != nil) {
                    let equal1 = ven1.customName == ven.customName
                    equals = equal1
                }
                if (ven1.customName != nil) && (ven.customName != nil) && (ven.coordinate?.longitude != nil) && (ven1.coordinate?.longitude != nil) && (ven.coordinate?.latitude != nil) && (ven1.coordinate?.latitude != nil) {
                    let equal2 = (ven.coordinate?.longitude)! == (ven1.coordinate?.longitude)! && (ven.coordinate?.latitude)! == (ven1.coordinate?.latitude)!  && ven.customName! == ven1.customName!
                    equals = equal2
                }
                
                if equals  {
                    repeats += 1
                }
                if repeats > 1 {
                    venueArr.remove(at: j)
                    repeats = 0
                    break
                }
            }
        }
        
        return venueArr
    }


    //MARK: - UISearchBar Delegate

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        if searchBar.text == "" {
            navigationController?.popViewController(animated: true)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if searchBar.text!.characters.count > 0 {
            self.addCircleLoadingView()
            hideOverlay()
            beginSearchResult(searchBar.text!)
        } else {
            venueArray.removeAll(keepingCapacity: true)

            tagListView.deleteAllTags()

            tableViewMiddle.removeAll()

            tableViewMiddle.reloadData()
            tableViewRight.dataQuery = nil
            tableViewRight.cancelQuery()
            tableViewRight.removeAll()
            tableViewRight.reloadData()
        }




        keyboardChange = true

        self.searchBar.resignFirstResponder()
        
        if  (User.current() != nil) {// Adapter visitor login
            let search = Search(string: searchBar.text!, author: User.current() as! User)
            search.saveInBackground { (saved, error) -> Void in
                if error != nil {
                    log.error("Search save : \(error?.localizedDescription)")
                } else if saved {

                    DataQueryProvider.searchPopularityForString(search.string!).executeInBackground({ (objects:[Any]?, error) -> () in
                        if objects?.count > 0 {
                            if let searchPopularity = objects?[0] as? SearchPopularity {
                                searchPopularity.popularity = NSNumber(integerLiteral: searchPopularity.popularity!.intValue + 1)
                                searchPopularity.saveInBackground { (saved, error) -> Void in
                                    if error != nil {
                                        log.error("SearchPopularity update : \(error?.localizedDescription)")
                                    } else if saved {

                                    } else {

                                    }
                                }
                            } else {
                                if error != nil {
                                    log.error("searchPopularityForString : \(error?.localizedDescription)")
                                }
                                let searchPopularity = SearchPopularity(string: search.string!, popularity: 1)
                                searchPopularity.saveInBackground { (saved, error) -> Void in
                                    if error != nil {
                                        log.error("SearchPopularity save : \(error?.localizedDescription)")
                                    } else if saved {

                                    } else {

                                    }
                                }
                            }
                        }
                    })
                } else {

                }
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.hideCateListView()
        self.showOverlay()
        keyboardChange = true
        self.clearResultUI()
    }
    
    func clearResultUI() {
        self.venueArray.removeAll()

        self.tableViewMiddle.removeAll()
        self.tableViewMiddle.reloadData()
        self.tableViewMiddle.emptyStreamLabel.isHidden = true
        
        self.tagListView.deleteAllTags()
        self.tagListView.emptyLabel.isHidden = true
        
        self.tableViewRight.removeAll()
        self.tableViewRight.reloadData()
        self.tableViewRight.emptyStreamLabel.isHidden = true
    }
    
    func searchUserMatch(_ string : String) {
        self.tableViewRight.exsitsUserIds.removeAll()
        self.tableViewRight.existsUsers.removeAll()
        let query = DataQueryProvider.queryForUserNickNameMatchString(string)
        userStreamViewFetchRefreshData(query, currentType: .nickName, nextType: .city)
    }
    func beginSearchResult(_ text : String) -> Void {
        venueArray.removeAll(keepingCapacity: true)
        self.tagCurrentPage = 0
        self.tableViewMiddle.removeAll()
        if currLocation == CitySwitchLocation.AllLocation{
            self.globalSearchWithString(text)

        }else{
            self.locationAndInputStringSearchResult(text)
        }
    }
    
    //MARK: - UIKeyboard Notification Handlers
    
    func keyboardWasShown(_ notification: Foundation.Notification) {

        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {


            
            if venueArray.count == 0 {
            }
            
            self.tagListView.maximumHeight = leftView.frame.height
            keyboardChange = false
            let rect = CGRect(x: 0, y: 0, width: leftView.bounds.width, height: leftView.bounds.height)
            self.tagListView.setDefaultCompents(rect)
//            tagListView.contentSize = rect.size

        }
    }
    
    
    
    func keyboardWillHide(_ notification: Foundation.Notification) {


        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {


            if venueArray.count == 0 {
            }
            
            
            self.tagListView.frame.size.height = self.leftView.frame.height
            self.tagListView.maximumHeight = leftView.frame.height
            let rect = CGRect(x: 0, y: 0, width: leftView.bounds.width, height: leftView.bounds.height)
            self.tagListView.setDefaultCompents(rect)
//            tagListView.contentSize = rect.size

            keyboardChange = false
        }
    }
    

    //MARK: - RecommendationSelection Protocol
    
    func onRecommendationSelected(_ recommendation: Recommendation) {
        // leancloud AVAnalytics
        AVAnalytics.event("搜索进动态详情页面")
        keyboardChange = true
        searchBar.resignFirstResponder()
        let previewViewController = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }


    //MARK: - UserSelection Protocol
    
    func onUserSelected(_ user: User) {
        // leancloud AVAnalytics
        AVAnalytics.event("搜索进用户详情页面")
        keyboardChange = true
        searchBar.resignFirstResponder()
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

/**
Extension handling the GlobalSearchViewController onboarding overlay
*/
extension GlobalSearchViewController {
    
    //MARK: - Actions
    
    func onSearchLabelTapped(_ sender: AnyObject?) {
        guard let label = sender?.view as? UILabel else { return }
        let string = label.text
        searchBar.text = string
        hideOverlay()
        self.clearResultUI()
        self.searchBar.resignFirstResponder()
        self.addCircleLoadingView()
        beginSearchResult(string!)
    }
    
    
    //MARK: - Methods
    
    func initOverlay() {
        bgImage.backgroundColor = Config.Colors.TagFieldBackground
        titleLabel1.textColor = Config.Colors.HistoryTitleColor

        addSearchLabelsTapListeners()
        hideTitleLabels()
        hideSearchLabels()
        
        guard let query = DataQueryProvider.lastSearchesForCurrentUser() else { return }
        DataQueryProvider.lastSearchesForCurrentUser()
        query.executeInBackground({ (searchObjects:[Any]?, error) -> () in


            if error != nil {
                log.error("LastSearchesForCurrentUser : \(error?.localizedDescription)")
            } else if searchObjects != nil && searchObjects?.count > 0 {
                self.searchArray = searchObjects as! [Search]
                self.showSearchTitle()
                self.showSearchLabels(true)
                self.historySearchCounts += 1
            } else {
                DataQueryProvider.popularSearchPopularity().executeInBackground({ (searchPopularityObjects:[Any]?, error) -> () in


                    if error != nil {
                        log.error("popularSearchPopularity : \(error?.localizedDescription)")
                    } else if searchPopularityObjects != nil && searchPopularityObjects?.count > 0 {

                        for popularity in searchPopularityObjects as! [SearchPopularity] {
                            DataQueryProvider.searchWithString(popularity.string!).executeInBackground({ (popularityObjects:[Any]?, error) -> () in
                                if error != nil {
                                    log.error("searchWithString : \(error?.localizedDescription)")
                                } else if let popularityObjects = popularityObjects as? [Search] {
                                    if popularityObjects.count > 0 {
                                        self.searchArray.append(popularityObjects[0])
                                        //self.showPopularTitle()
                                        self.showSearchLabels(true, startAtIndex: self.searchArray.count - 1)
                                    }
                                }
                            })
                        }
                    } else {

                    }
                })
            }
        })
    }
    
    func hideOverlay() {
        overlayView.isHidden = true
    }
    func showOverlay() {
        overlayView.isHidden = false
    }
    func hideTitleLabels() {
        titleLabel1.isHidden = true
    }
    
    func showSearchTitle() {
        titleLabel1.text = NSLocalizedString("Search history", comment:"搜索历史")
        titleLabel1.isHidden = false
    }
    
    func showPopularTitle() {
        titleLabel1.text = NSLocalizedString("Popular searches", comment:"热门搜索")
        titleLabel1.isHidden = false
    }
    
    func hideSearchLabels() {
        
        searchLabel1.isHidden = true
        searchLabel2.isHidden = true
        searchLabel3.isHidden = true
        searchLabel4.isHidden = true
        searchLabel5.isHidden = true
        searchLabel6.isHidden = true
        searchLabel7.isHidden = true
        
    }
    func hideCateListView() {
        categoryOverFlowView.isHidden = true
    }

    func addSearchLabelsTapListeners() {

        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel1.addGestureRecognizer(tap1)
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel2.addGestureRecognizer(tap2)
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel3.addGestureRecognizer(tap3)
        let tap4: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel4.addGestureRecognizer(tap4)
        let tap5: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel5.addGestureRecognizer(tap5)
        let tap6: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel6.addGestureRecognizer(tap6)
        let tap7: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GlobalSearchViewController.onSearchLabelTapped(_:)))
        searchLabel7.addGestureRecognizer(tap7)
    }
    
    func showSearchLabels(_ animated: Bool = false, startAtIndex startIndex: Int = 0) {
        searchLabel1.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel2.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel3.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel4.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel5.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel6.textColor = Config.Colors.HistoryLabelTextColor
        searchLabel7.textColor = Config.Colors.HistoryLabelTextColor
        let delay = TimeInterval(0.2)

        let numbers = searchArray.count >= 7 ? 7 : searchArray.count
        var searchArr = [Search]()
        for i in 0..<numbers{
            let search = searchArray[i]
            var repeats = 0
            searchArr.append(search)
            for j in 0..<searchArr.count{
                let search1 = searchArr[j]
                let equals = search.string == search1.string
                if equals  {
                    repeats += 1
                }
                if repeats > 1 {
                    searchArr.remove(at: j)
                    break
                }
            }
        }

        
        
        for (index, search) in searchArr.enumerated() {
            if index < startIndex {
                continue
            }
            switch index {
            case 0:
                self.showSearchLabel(self.searchLabel1, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 1:
                self.showSearchLabel(self.searchLabel2, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 2:
                self.showSearchLabel(self.searchLabel3, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 3:
                self.showSearchLabel(self.searchLabel4, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 4:
                self.showSearchLabel(self.searchLabel5, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 5:
                self.showSearchLabel(self.searchLabel6, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            case 6:
                self.showSearchLabel(self.searchLabel7, withText: search.string!, animated: animated, withDelay: delay * Double(index+1))
            default:
                return
            }
        }
    }
    
    func showSearchLabel(_ label: UILabel, withText text: String, animated: Bool = false, withDelay delay: TimeInterval = 0) {
        let duration = TimeInterval(0.4)
        
        label.text = text
        label.alpha = 0
        label.isHidden = false
        
        if animated {
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                label.alpha = 1
            }, completion: { (success) -> Void in
            })
        } else {
            label.isHidden = false
        }
    }
}


extension GlobalSearchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        if scrollView == tagListView {
            return
        }
        
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1

        self.currentPage = Int(currentPage)
        

        switch Int(currentPage) {
        case 1:
            lateralScrollView.manuallySetContentOffset(CGPoint(x: leftView.frame.width, y: 0), animated: false)
            self.onMiddleTabButtonTapped()
        case 2:
            lateralScrollView.manuallySetContentOffset(CGPoint(x: leftView.frame.width * 2, y: 0), animated: false)
            self.onRightTabButtonTapped()
        default:
            lateralScrollView.manuallySetContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.onLeftTabButtonTapped()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        
        if scrollView == tagListView {
            return
        }
        if keyboardChange {
            switch Int(currentPage) {
            case 1:
                lateralScrollView.manuallySetContentOffset(CGPoint(x: leftView.frame.width, y: 0), animated: false)
                self.onMiddleTabButtonTapped()
            case 2:
                lateralScrollView.manuallySetContentOffset(CGPoint(x: leftView.frame.width * 2, y: 0), animated: false)
                self.onRightTabButtonTapped()
            default:
                lateralScrollView.manuallySetContentOffset(CGPoint(x: 0, y: 0), animated: false)
                self.onLeftTabButtonTapped()
            }
           // keyboardChange = true
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}


extension GlobalSearchViewController {
    
    //MARK: - Methods
    
}

//MARK: - positionScrollViewDelegate
extension GlobalSearchViewController : positionScrollViewDelegate {
    func didSelectedTag(_ tagControl : TagControl)
    {

        for location in venueArray {
            if location.customName == nil{
                continue
            }
            if tagControl.title == location.customName! {
                // leancloud AVAnalytics
                AVAnalytics.event("搜索进地点详情页面")
                navigationController?.navigationBar.isHidden = false
                let vc = storyboard?.instantiateViewController(withIdentifier: "VenueHomeListingViewController") as! VenueHomeListingViewController
                vc.venue = location
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
                break
            }
        }
    }
    
    func positionScrViewPushCallback(){
        self.tagCurrentPage += 1
        
        if self.searchType == .allCategory{
            self.allCategorySearchWithoutCity()
            
        }else if self.searchType == .cityCategory{
            self.cityCategoryVenuesSearch()
            
        }else if self.searchType == .allInput{
            self.globalSearchVenueMatchString(self.searchBar.text!)
            
        }else if self.searchType == .cityInput{
            self.locationAndInputStringSearchResult(self.searchBar.text!)
        }
    }
}

extension GlobalSearchViewController: LoginDelegate {
    func needLogin() {
        searchBar.resignFirstResponder()
        Router.redirectToLoginViewController(fromViewController: self)
    }
}
extension GlobalSearchViewController : UserViewCellTapDelegate{
    func userViewCellUnfollowWithCell(_ cell: UserViewCell) {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "确认要取消关注吗?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            cell.unfollow()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

/**
 Extension handling the GlobalSearchViewController refresh currentCity
 */
extension GlobalSearchViewController : selectedCityCallBackProtocol,UIAlertViewDelegate{
    
    
    func onSelectCityButtonTapped(){

        searchBar.resignFirstResponder()
        let vc = storyboard?.instantiateViewController(withIdentifier: "CitySelectedViewController") as! CitySelectedViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: { () -> Void in
        })
    }

    
    func showLocationAlert(_ tips : String) {

        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: tips, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            self.alertConfirmClick()
        })
        let cancleAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
            self.alertCancleClick()
        })
        alertController.addAction(okAction)
        alertController.addAction(cancleAction)
        if self.navigationController?.viewControllers.count > 0{
            
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    func alertCancleClick() {
        if let localCity = Foundation.UserDefaults.standard.object(forKey: "city") as? String {
            self.leftButton.settitle(localCity)
            self.matchCurrentLocation(localCity)
        }

        Foundation.UserDefaults.standard.set(true, forKey: "onceShown")
        
        Foundation.UserDefaults.standard.synchronize()
    }
    
    func alertConfirmClick() {
        self.leftButton.settitle(self.currentCity)
        self.matchCurrentLocation(self.currentCity)

        Foundation.UserDefaults.standard.set(true, forKey: "onceShown")
        
        Foundation.UserDefaults.standard.set(self.currentCity, forKey: "city")
        
        Foundation.UserDefaults.standard.synchronize()
    }
    
    func reverse(_ location:CLLocation){
        let geocoder = CLGeocoder()
        typealias CLGeocodeCompletionHandler = (_ p:[CLPlacemark]?, _ error : NSError?) -> Void
        var place : [CLPlacemark]?
        weak var weakSelf = self
        geocoder.reverseGeocodeLocation(location) { CLGeocodeCompletionHandler in
            guard let errorMsg = CLGeocodeCompletionHandler.1 else{
                place = CLGeocodeCompletionHandler.0
                let pm =  place![0] as CLPlacemark
                let  locationName = pm.locality
                let index : Int = (locationName?.characters.count)! - 1
                
                
                if locationName?.characters.count > 0{
              let preferredLanguage =  self.getPerferredLanguage()
                    var  cityName = locationName
                    if preferredLanguage.hasPrefix("zh-Hans") || preferredLanguage.hasPrefix("zh-Hant") || preferredLanguage.hasPrefix("zh-HK") ||  preferredLanguage.hasPrefix("zh-TW"){
                         cityName = locationName?.substring(to: (locationName?.characters.index((locationName?.startIndex)!, offsetBy: index))!)
                        self.currentCity = cityName!
                    }else{
                        self.currentCity = locationName!
                    }
                    let onceShown = Foundation.UserDefaults.standard.bool(forKey: "onceShown")
                    if onceShown {
                        return
                    }
                    if self.selectedCity == ""{
                        let tips = NSLocalizedString("The current location was detected", comment:"检测到当前地理位置是") + cityName! + "," + NSLocalizedString("Whether to switch to the current city", comment: "是否切换到当前城市")
                        weakSelf!.showLocationAlert(tips)
                        return
                    }
                    if cityName != self.selectedCity{
                            if (cityName == "Beijing" || cityName == "北京") && (self.selectedCity == "北京" || self.selectedCity == "Beijing"){
                                self.selectCityEnum = .BEIJING
                                if preferredLanguage == "zh-Hans"{
                                    self.leftButton.settitle("北京")
                                }else{
                                    self.leftButton.settitle("Beijing")
                                }
                                return
                                }
                            if (cityName == "Shanghai" || cityName == "上海") && (self.selectedCity == "上海" || self.selectedCity == "Shanghai"){
                                self.selectCityEnum = .SHANGHAI
                                if preferredLanguage == "zh-Hans"{
                                    self.leftButton.settitle("上海")
                                }else{
                                    self.leftButton.settitle("Shanghai")
                                }
                                return
                            }
                            if (cityName == "Tokyo" || cityName == "东京") && (self.selectedCity == "东京" || self.selectedCity == "Tokyo"){
                                self.selectCityEnum = .TOKYO
                                if preferredLanguage == "zh-Hans"{
                                    self.leftButton.settitle("东京")
                                }else{
                                    self.leftButton.settitle("Tokyo")
                                }
                                return
                            }
                            if (cityName == "New York" || cityName == "纽约") && (self.selectedCity == "纽约" || self.selectedCity == "New York"){
                                self.selectCityEnum = .NEWYORK
                                if preferredLanguage == "zh-Hans"{
                                    self.leftButton.settitle("纽约")
                                }else{
                                    self.leftButton.settitle("New York")
                                }
                                return
                            }
                        let tips = NSLocalizedString("Have you detected a change in your city and switched to the current city?", comment:"检测到您所在城市发生变化，是否切换到当前城市？")
                        weakSelf!.showLocationAlert(tips)
                    }
                }
                return
            }
        }
    }
    
    func getPerferredLanguage() -> String {
        let languageArray = Foundation.UserDefaults.standard.object(forKey: "AppleLanguages") as? [AnyObject]
        let perferrdLanguage = languageArray![0]
        print("\(perferrdLanguage)")
        return perferrdLanguage as! String
    }
    func didSelectedCity(_ result : String){
        self.hideOverlay()
        self.leftButton.settitle(result)
        self.matchCurrentLocation(result)
        selectedCity = result
        
        if categoryName != "" {
            if searchBar.text?.characters.count > 0 {
               self.searchSearchbarText(result )
                categoryName = ""
            } else{
                venueArray.removeAll()
                tagListView.deleteAllTags()
                tableViewMiddle.removeAll()
                tableViewMiddle.reloadData()
                self.addCircleLoadingView()

                self.categorySwitchSearch(self.category)
            }
        }
       else if searchBar.text?.characters.count > 0 {
            venueArray.removeAll()
            tagListView.deleteAllTags()
            tableViewMiddle.removeAll()
            tableViewMiddle.reloadData()
            self.addCircleLoadingView()

            self.searchSearchbarText(result)
        }
    }
    
    func searchSearchbarText( _ result : String) {
        if result == all{
            globalSearchWithString(searchBar.text!)
            
        }else {
            locationAndInputStringSearchResult(searchBar.text!)
        }
    }
    
    func clearCurrentQuery() {
        if CurrentQuerys.count < 1 {
            return
        }
        for query in CurrentQuerys {
            query.cancel()
        }
    }
}
//MARK: - CategoryListsViewDelegate
extension GlobalSearchViewController : CategoryListsViewDelegate{
    //MARK: CategoryListsViewDelegate
    
    func didSelectCategoryListsRowCallBack(_ categorys : [Category]){
        tagCurrentPage = 0
        let category = categorys[0]
        hideCateListView()
        searchBar.text = ""
        categorySwitchSearch(category)
        categoryName = category.name
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: lateralScrollView.bounds.height)
    }
   
    func matchCurrentLocation(_ cityName : String){

        switch cityName{
        case "北京":
            currLocation = CitySwitchLocation.BeiJingLocation
            currentRadius = CitySwitchLocation.BeijingRadius
            self.selectCityEnum = .BEIJING
        case "上海":
            currLocation = CitySwitchLocation.ShangHaiLocation
            currentRadius = CitySwitchLocation.ShanghaiRadius
            self.selectCityEnum = .SHANGHAI
        case "东京":
            currLocation = CitySwitchLocation.TokyoLocation
            currentRadius = CitySwitchLocation.TokyoRadius
            self.selectCityEnum = .TOKYO
        case "纽约":
            currLocation = CitySwitchLocation.NewYorkLocation
            currentRadius = CitySwitchLocation.NewYorkRadius
            self.selectCityEnum = .NEWYORK
        case all:
            currLocation = CitySwitchLocation.AllLocation
            self.selectCityEnum = .ALL
        default:
            if  let localLocation = localLocation {
                currLocation = localLocation
            }else{
                currLocation = CitySwitchLocation.AllLocation
            }
        }
    }
    func categorySwitchSearch(_ category : Category){
        tagCurrentPage = 0
        self.venueArray.removeAll()
        self.tagListView.deleteAllTags()
        self.tableViewMiddle.removeAll()
        self.tableViewMiddle.reloadData()
        self.addCircleLoadingView()
        self.category = category
        self.tableViewRight.removeAll()
        self.tableViewRight.reloadData()
        self.categorySearchResult()
    }
    
    func searchCategoryRecommendationResult() {
        self.tableViewMiddle.recommendationRefreshType = .allCate
        let count = self.tableViewMiddle.recommendations.count
        var paramsJson:NSMutableDictionary =
            [
            "category" : self.category.objectId!,
            "offset":count,
            "location":selectCityEnum.rawValue,
        ]
        if let _ = skipParam , let skip = skipParam as? Int{
            paramsJson.setValue(skip, forKey: "skip")
        }
        AVCloud.rpcFunction(inBackground: "recommendationListByCategory", withParameters: paramsJson) { (obj, error) in
            if error != nil{
                self.removeLoadingView()
                self.tableViewMiddle.mj_footer.endRefreshingWithNoMoreData()
                print(error)
            }else{
                self.skipParam = (obj! as AnyObject).object(forKey: "skip") as? AnyObject
                if let result = (obj! as AnyObject)["result"] as? [Recommendation]{
                    self.removeLoadingView()
                    self.reloadRecommendationTable(result)
                }
                else{
                    self.tableViewMiddle.mj_footer.endRefreshingWithNoMoreData()
                    self.removeLoadingView()
                }
            }
        }    }
    
    func categorySearchResult(){

        if currLocation ==  CitySwitchLocation.AllLocation{
            self.allCategorySearchWithoutCity()
        }else{
            self.cityCategoryVenuesSearch()
        }
        skipParam = nil
        self.searchCategoryRecommendationResult()
        self.searchUserMatch("")

    }
    
    fileprivate func cityCategoryVenuesSearch(){
       self.searchType = .cityCategory

        let query: AVQuery = AVQuery(className: "Venue")
        query.limit =  tagLimit
        query.skip = tagLimit * tagCurrentPage
        query.whereKey("category", containedIn: [self.category])
        query.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: currLocation), withinKilometers: Double(currentRadius / 1000))
        
        query.includeKey("category")
        CurrentQuerys.append(query)

        query.countObjectsInBackground { (counts, error) in
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if counts == 0{
                self.removeLoadingView()
                self.searchDoneWithoutResult(.venue)
            }else{
                
                query.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    
                    if error != nil {
                        log.error(error?.localizedDescription)
                        self.removeLoadingView()
                    }
                    else{
                        if objects?.count > 0 {
                            self.categorySearchDoneWithResult(objects as! [AnyObject], forFeed: .venue, withPaging: true)
                        }else{
                            self.removeLoadingView()
                            self.tagListView.mj_footer.endRefreshingWithNoMoreData()
                            self.tableViewMiddle.mj_footer.endRefreshing()

                        }
                    }
                })
                
            }
        }

    }
    fileprivate func allCategorySearchWithoutCity(){
        
        searchType = .allCategory
        let query: AVQuery = AVQuery(className: "Venue")
        query.limit =  tagLimit
        query.skip = tagLimit * tagCurrentPage
        query.whereKey("category", containedIn: [self.category])
        CurrentQuerys.append(query)

        query.countObjectsInBackground { (counts, error) in
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if counts == 0{
                self.searchDoneWithoutResult(.venue)
                self.tagListView.mj_footer.endRefreshing()
            }else{
                
                query.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    
                    if error != nil {
                        log.error(error?.localizedDescription)
                        self.removeLoadingView()
                    }
                    else{
                        if objects?.count > 0 {
                            delay(0.2, closure: {
                                self.categorySearchDoneWithResult(objects as! [AnyObject], forFeed: .venue, withPaging: true)
                            })
                        }else{
                            self.tagListView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                })
                
            }
        }

        
    }
    func locationAndInputStringSearchResult(_ inputStr : String){

        searchType = .cityInput
        let radius = 100000
        let stringQuery = DataQueryProvider.queryForVenuesMatchingString(inputStr)
        let locationQuery = DataQueryProvider.venuesAround(currLocation, withinRadius: radius)
        let andQuery = AVQuery.andQuery(withSubqueries: [(locationQuery as! SimpleQuery).query, stringQuery ])
        andQuery.maxCacheAge = 60 * 300
        andQuery.limit =  locationInputLimit
        andQuery.skip = locationInputLimit * tagCurrentPage
        
            andQuery.countObjectsInBackground { (count, error) -> Void in
                
                if error != nil {
                    log.error(error?.localizedDescription)
                    self.removeLoadingView()
                }
                else if count == 0{

                    self.searchDoneWithoutResult(.venue)
                }else{
                    andQuery.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else {
                            if objects != nil && objects?.count > 0 {
//                                let paging = i != 0 && i < count / limit + addOne
                                let paging = true
//                                delay(Double(i) * 0.2) {
                                    self.categorySearchDoneWithResult(objects as! [AnyObject], forFeed: .venue, withPaging: paging)
//                                }
                            } else {
                                self.tagListView.mj_footer.endRefreshingWithNoMoreData()
                            }
                        }
                    })
                }
            }

        self.tableViewMiddle.recommendationRefreshType = .titleMatch
        self.tableViewMiddle.titleRecommendationId.removeAll()
        self.queryRecommendationMatchTitle(inputStr)
        self.searchUserMatch(inputStr)

    }
}

//MARK recommendationSearch
extension GlobalSearchViewController : SearchRecommendationTableViewDelegate{

    func allCategoryRecommendationQuery() -> AVQuery{
        searchType = .allCategory
        let query: AVQuery = AVQuery(className: "Recommendation")
        query.limit =  tagLimit
        query.whereKey("category", containedIn: [self.category])
        query.whereKey("status", greaterThan: 0)
        query.whereKeyExists("title")
        query.whereKeyExists("author")
        query.whereKeyExists("cover")
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.includeKey("cover")
        query.order(byDescending: "createdAt")
        return query
        }
    
    func RecommendationNearLocationMatching(_ string : String) -> CQLQuery{
         let baseRequest = "select include author,include author.avatar,include venue,include cover,* from Recommendation where status > 0 and cover is exists and (title like '%\(string)%' or text like '%\(string)%') and author is exists"
         let andStr = " and "
         var request = baseRequest
        
        let  requestCondition = "venue in (select * from Venue where coordinate near geopoint(\(currLocation.coordinate.longitude), \(currLocation.coordinate.latitude)) max \(currentRadius/1000) km)"
        let  requestOrder = " order by createdAt desc"

         request += andStr
         request += requestCondition
         request += " limit \(tagLimit*tagCurrentPage)"
        request += ",100"
        request += requestOrder


         return CQLQuery(query: request)
    }
    
    func locationAndInputStringRecommendation(_ string : String) {
        let query =   RecommendationNearLocationMatching(string)
        query.executeInBackground({ (objects: [Any]?, error) -> () in
            if error != nil {

                
            } else {

                if let recommendations = objects as? [Recommendation]{
                    self.tableViewMiddle.recommendations += recommendations
                    self.tableViewMiddle.reloadData()
                    self.removeLoadingView()

                }
                
            }
        })
    }
    
    func cityCategoryRecommendation() -> CQLQuery{
        let baseRequest = "select include author,include author.avatar,include venue,include cover,* from Recommendation where (category=pointer('Category' , '\(self.category.objectId)') and status > 0) and cover is exists and author is exists"
        let andStr = " and "
        var request = baseRequest
        
        let  requestConditionVenue = "venue in (select * from Venue where coordinate near geopoint(\(currLocation.coordinate.longitude), \(currLocation.coordinate.latitude)) max \(currentRadius / 1000) km)"
        request += andStr
        request += requestConditionVenue
        request += " limit \(tagLimit*tagCurrentPage)"
        request += ",100"
        


        let query = CQLQuery(query: request)
        query.executeInBackground({ (objects: [Any]?, error) -> () in
            if error != nil {

                self.removeLoadingView()

            } else {

                if let recommendations = objects as? [Recommendation]{
                    self.tableViewMiddle.recommendations += recommendations
                    self.tableViewMiddle.reloadData()
                    self.removeLoadingView()

                }
                
            }
        })
        return query
    }

    func queryRecommendationMatchTitle(_ title:String)  {
        let count = self.tableViewMiddle.recommendations.count
        let paramsJson : NSMutableDictionary = [
            "kw" : title,
            "offset":count,
            "location":selectCityEnum.rawValue,
        ]
        if let _ = skipParam , let skip = skipParam as? Int{
            paramsJson.setValue(skip, forKey: "skip")
        }
        AVCloud.rpcFunction(inBackground: "recommendationList", withParameters: paramsJson) { (obj, error) in
            if error != nil{
                self.removeLoadingView()
                self.tableViewMiddle.mj_footer.endRefreshingWithNoMoreData()
                print(error)
            }else{
                self.skipParam = (obj! as AnyObject)["skip"] as? AnyObject
                if let result = (obj! as AnyObject)["result"] as? [Recommendation]{
                    self.removeLoadingView()
                    self.reloadRecommendationTable(result)
                }
                else{
                    self.tableViewMiddle.mj_footer.endRefreshingWithNoMoreData()
                    self.removeLoadingView()
                }
            }
        }
        
    }

    func reloadRecommendationTable(_ objects : [AnyObject]!){
        
        if let recommendations = objects as? [Recommendation]{
            self.tableViewMiddle.recommendations += recommendations
            self.tableViewMiddle.reloadData()
            self.removeLoadingView()
            if let footer = self.tableViewMiddle.mj_footer {
                footer.endRefreshing()
            }
            
            for (_,recommendate) in recommendations.enumerated(){
                let objectId = recommendate.objectId
                self.tableViewMiddle.titleRecommendationId.append(objectId!)
            }
            
        }
    }



    func SearchRecommendationTableViewRefreshCallBack(){
        if self.tableViewMiddle.recommendationRefreshType == .allCate{

            searchCategoryRecommendationResult()
        }
        else if self.tableViewMiddle.recommendationRefreshType == .titleMatch{
            queryRecommendationMatchTitle(searchBar.text!)
        }
        else if self.tableViewMiddle.recommendationRefreshType == .cityCate{
            self.tagCurrentPage += 1
            self.cityCategoryVenuesSearch()
            searchCategoryRecommendationResult()
        }
        else if self.tableViewMiddle.recommendationRefreshType == .cityInput{
            self.tagCurrentPage += 1
            self.locationAndInputStringSearchResult(self.searchBar.text!)
        }
    }
    
}

extension GlobalSearchViewController:UserStreamRefreshViewDelegate{
    func UserStreamViewPushCallback(){
        let matchType = self.tableViewRight.globalRefreshType!

        switch matchType {
        case .nickName:
            
            let query = DataQueryProvider.queryForUserNickNameMatchString(self.searchBar.text!)
            userStreamViewFetchRefreshData(query, currentType: .nickName, nextType: .city)

        case .city:
            
            let query = DataQueryProvider.queryForUserCityMatchString(self.searchBar.text!)
            userStreamViewFetchRefreshData(query, currentType: .city, nextType: .province)

        case .province:
            let query = DataQueryProvider.queryForUserProvinceMatchString(self.searchBar.text!)
            userStreamViewFetchRefreshData(query, currentType: .province, nextType: .province)
        default:

            return
        }
  
    }
    func userStreamViewFetchRefreshData(_ query : AVQuery , currentType : GlobalRefreshType, nextType : GlobalRefreshType){
        query.whereKey("objectId", notContainedIn: self.tableViewRight.exsitsUserIds)

            query.findObjectsInBackground { (objects:[Any]?, error) -> () in
                self.tableViewRight.mj_footer.endRefreshing()
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    if objects != nil && objects?.count > 0 {
                        if let users = objects as? [User]{
                            self.tableViewRight.existsUsers += users
                        }
                        if (objects?.count)! >= 20{
                            
                            self.tableViewRight.globalRefreshType = currentType
                        }
                        else {
                            
                            if nextType == .province {
                                self.tableViewRight.mj_footer.endRefreshingWithNoMoreData()
                            }else{
                                self.tableViewRight.globalRefreshType = nextType
                            }
                            
                        }
                        for (_,object) in (objects?.enumerated())! {
                            
                            self.tableViewRight.exsitsUserIds.append((object as! AVObject).objectId!)
                        }
                        self.tableViewRight.handleQueryForObjects(self.tableViewRight.existsUsers)

                    } else {
                        if nextType == .province {
                            self.tableViewRight.mj_footer.endRefreshingWithNoMoreData()
                        }else{
                            self.tableViewRight.globalRefreshType = nextType
                        }
                        self.tableViewRight.showEmptyStreamLabel()
                    }
                }
            }

    }


}
