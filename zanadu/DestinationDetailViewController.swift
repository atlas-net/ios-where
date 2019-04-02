//
//  File.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/4/8.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import TagListView
import Alamofire
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



public typealias Parameters = [String:String]


class DestinationDetailViewController : UIViewController ,RecommendationSelectionProtocol ,StreamViewDelegate{
    
    enum SearchType {
        case normalSearch,allSearch,inputSearch
    }
    var imageIndex = 0
    
    var topImageName = ["peking","SH","japan","ny"]
    var topImageName1 = ["pekingBottom","SHBottom","japanBottom","nyBottom"]
    
    //Property
   lazy  var currentPosition = ["":CLLocation()]

    
    lazy  var loadingV:LoadingView = {
        return LoadingView()
    }()
    lazy  var venueArray = [Venue]()
    
    lazy  var recommendationArray = [Recommendation]()
    
    var venueQuery: ConcurrentSimpleQuery?
    
    var currentPage = 0
    var endFlage = 0

    var locationRadius = 0
    var category : Category!{
        didSet{
            setCategoty()
        }
    }
    
    var tagCurrentPage = 0
    var tagLimit = 30
    
    var  switchBtn = UIButton()
    
    lazy var table = UITableView()
    var tableBackgroundView : UIButton!
    
    lazy  var  currLocation = CLLocation()
    var showCategoryList = false
    var currSearchType : SearchType = .normalSearch
    
    
    var categoryArray = [Category]()
    let  cellIdentifer = "tableViewCell"
    var topImageHeight = CGFloat(348)
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textfield: UITextField!
    
    
    @IBOutlet weak var inPutTextfield: UITextField!
    
    
    @IBOutlet weak var recommendationBtn: UIButton!
    
    @IBOutlet weak var venueBtn: UIButton!
    
    @IBOutlet weak var lateralScrollView: UIScrollView!
    
    @IBOutlet weak var scrollLabel: UILabel!
    
    @IBOutlet weak var scrollLabXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewRight: SearchRecommendationTableView!
    
    @IBOutlet weak var bottomImageView: UIImageView!
    
    @IBOutlet weak var bgImageView: UIImageView!
        
    @IBOutlet weak var imageCover: UILabel!

    @IBOutlet weak var positionScroll : PositionScrollView!

    @IBOutlet weak var bgScrollView : UIScrollView!

    @IBOutlet weak var positionHeightConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.bgImageView.image = UIImage(named: "loadingBg")
        self.addLoadingView()
        
//        bgScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height + 348)
//        bgScrollView.scrollEnabled = false
//        bgScrollView.bounces = false
//        bgScrollView.delegate = self
//        positionScroll.delegate = self
        imageCover.text = ""
        
        positionHeightConstraint.constant = UIScreen.main.bounds.height - topImageHeight
        setupTextfield()
        setUpScrollView()
        setupTopImage()
        
        recommendationBtn.addTarget(self, action:#selector(DestinationDetailViewController.switchToPageRight), for: .touchUpInside)
        venueBtn.addTarget(self, action:#selector(DestinationDetailViewController.switchToPageLeft), for: .touchUpInside)
        scrollLabel.backgroundColor = Config.Colors.DestinationHighiledColor
        
        tableViewRight.backgroundColor = UIColor.clear

        tableViewRight.countDelegate = self
        
        imageCover.backgroundColor = UIColor(bd_hexColor : "1b1919c1")
        let positionName = currentPosition.keys.first

        currLocation = currentPosition[positionName!]!
        currSearchType = .allSearch
        allCategoriesSearch()
        switchToPageLeft()
        
        
        imageView.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DestinationDetailViewController.hiddenKeyBoard(_:)))
        imageView.addGestureRecognizer(tap)
        
        
    }
    
    func hiddenKeyBoard(_ sender: AnyObject?) {
        inPutTextfield.resignFirstResponder()
        showCategoryList = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false

        let positionName = currentPosition.keys.first
        setupNav(positionName!)
        reActiveLoadingAnimation()
    
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    fileprivate func setupTopImage(){
        imageView.image = UIImage(named: topImageName[imageIndex])
        bottomImageView.image = UIImage(named: topImageName1[imageIndex])
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 85)
        let alphaImage = self.screenViewShots(frame, view: bottomImageView)
        bottomImageView.image = alphaImage.exchangeImageToBlurImage(4.0)
    }
    
    func screenViewShots(_ imageFrame : CGRect , view : UIView) -> UIImage{
        let rect = imageFrame
        UIRectClip(imageFrame)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        view.layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    fileprivate func setUpScrollView(){
        lateralScrollView.backgroundColor = UIColor.clear
        lateralScrollView.isScrollEnabled = false

        lateralScrollView.bounces = false
        lateralScrollView.delegate = self
        lateralScrollView.isPagingEnabled = true
        tableViewRight.selectionDelegate = self
        tableViewRight.commonInit()
        tableViewRight.contentInset = UIEdgeInsets.zero
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height - 348
        positionScroll.showsVerticalScrollIndicator = true
        positionScroll.isScrollEnabled = true
        positionScroll.isDirectionalLockEnabled = true
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight + 1)
        positionScroll.positionViewDelegate = self
        positionScroll.setDefaultCompents(rect)
       
    }
    fileprivate func setupNav(_ titleName : String){
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem()
        self.title = titleName
        
        navigationItem.hidesBackButton = false
    }
    
    func setupTextfield(){

        switchBtn.frame = CGRect(x: 0, y: 10, width: 40, height: 10)
        switchBtn.backgroundColor = UIColor.clear
        switchBtn.setImage(UIImage(named: "up"), for: UIControlState())
        let imageRect = CGRect(x: 11,y: 0, width: 18, height: 10)
        switchBtn.imageRect(forContentRect: imageRect)
        switchBtn.addTarget(self, action: #selector(DestinationDetailViewController.switchBtnClick(_:)), for: UIControlEvents.touchUpInside)
        textfield.rightView = switchBtn
        textfield.rightViewMode = .always
        textfield.textColor = Config.Colors.TextfieldTextColor
        textfield?.font = UIFont.systemFont(ofSize: 15)
        textfield?.text = NSLocalizedString("All", comment:"全部")
        
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        leftView.backgroundColor = UIColor.clear
        textfield.leftView = leftView
        textfield.leftViewMode = .always
        textfield.delegate = self
        textfield.returnKeyType = .search
        textfield.backgroundColor = Config.Colors.TextfieldBackgrounColor
        
        
        
        let width = UIScreen.main.bounds.width/2 - 20
        let leftView1 = UIView()
        leftView1.frame = CGRect(x: 0, y: 0,width: width , height: 30)
        leftView1.backgroundColor = UIColor.clear
        let iconView = UIImageView()
        iconView.frame = CGRect(x: width - 30, y: 8, width: 15, height: 14)
        iconView.image = UIImage(named: "gray_search")
        iconView.backgroundColor = UIColor.clear
        leftView1.addSubview(iconView)
        
        let  leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        leftBtn.backgroundColor = UIColor.clear
        leftBtn.addTarget(self, action: #selector(DestinationDetailViewController.changeTextfield(_:)), for: UIControlEvents.touchUpInside)
        leftView1.addSubview(leftBtn)

        inPutTextfield.leftView = leftView1
        inPutTextfield.leftViewMode = .always
        inPutTextfield.textColor = Config.Colors.TextfieldTextColor
        inPutTextfield.backgroundColor = Config.Colors.TextfieldBackgrounColor
        inPutTextfield.delegate = self
        inPutTextfield?.font = UIFont.systemFont(ofSize: 15)
        inPutTextfield.returnKeyType = .search
        inPutTextfield.clearButtonMode = .always
        inPutTextfield.tintColor = Config.Colors.TextfieldTextColor
        
    }
    
    func changeTextfield(_ sender : UIButton){
        self.textFieldShouldBeginEditing(inPutTextfield)
    }
    func switchBtnClick(_ sender : UIButton) {
        showCategoryList = !showCategoryList
        let placeHolderLabel = inPutTextfield!.value(forKey: "placeholderLabel")as?UILabel

        if showCategoryList {
            inPutTextfield.isUserInteractionEnabled = false

            createCategoryTable()
            if inPutTextfield.text?.characters.count > 0 {
                inPutTextfield.textColor = UIColor.lightGray
            }else{
                placeHolderLabel?.textColor = UIColor.lightGray
            }
        }else{
            inPutTextfield.isUserInteractionEnabled = true

            if inPutTextfield.text?.characters.count > 0 {
                inPutTextfield.textColor = Config.Colors.TextfieldTextColor
                
            }else{
                placeHolderLabel?.textColor = Config.Colors.LightGreyTextColor
            }
            removeCategoryTable()
        }
    }
    
  
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height )
        self.view.addSubview(self.loadingV)
        reActiveLoadingAnimation()
        switchToPageLeft()
    }
    
    func switchToPageLeft()  {
        switchToPage(0)
    }
    func switchToPageRight()  {
        switchToPage(1)
    }
    //动态和地点
    func switchToPage(_ index:Int) {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: lateralScrollView.bounds.height)



        let rect = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.view.frame.width, height: lateralScrollView.frame.height)
        lateralScrollView.scrollRectToVisible(rect, animated: false )
        
        let color1 = index == 1 ? Config.Colors.DestinationHighiledColor : Config.Colors.DestinationNormalColor
        recommendationBtn.setTitleColor(color1, for: UIControlState())
        let color2 = index == 0 ? Config.Colors.DestinationHighiledColor : Config.Colors.DestinationNormalColor
        venueBtn.setTitleColor(color2, for: UIControlState())

        //animation
        let x1 = (UIScreen.main.bounds.width)/4 - 36
        let x2 = (UIScreen.main.bounds.width)*3/4 - 36

        let scrollLabelX = index == 0 ? x1 : x2
        UIView.animate(withDuration: 1, animations: {
            self.scrollLabXConstraint.constant = scrollLabelX
        }) 
        self.currentPage = index
    }
    override func viewDidLayoutSubviews() {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: lateralScrollView.bounds.height)
//        bgScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height + 348)

    }
    
     func fillTagViewWithArray(_ array: [Venue]) -> [Venue]{
        var tags = [TagControl]()
        
        let diffArray = filterSameVenues(array)
        for location in diffArray {
            guard let customName = location.customName else {
                continue
            }
            let tagControl = TagControl(title: "\(customName)", object: location)
            tagControl.tagBackgroundColor = UIColor.clear
            tagControl.borderColor = Config.Colors.LightGreyTextColor
            tagControl.borderWidth = 1
            tagControl.tagTextColor = Config.Colors.LightGreyTextColor
            tagControl.maxWidth = self.positionScroll.frame.width / 2 - 32
            tags.append(tagControl)

            self.positionScroll.addTag(tagControl)
            
            
            print("\(location.customName)")
        }
                self.positionScroll.tagSize()
        return diffArray
    }

    func showAlert(_ title : String)  {
        let alert = UIAlertView(title: NSLocalizedString("remind", comment: "提醒"), message:title, delegate: nil, cancelButtonTitle: NSLocalizedString("Sure", comment: "确定"))
        alert.show()
    }
    
    func categorySwitchSearch(_ index : NSInteger){
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: lateralScrollView.bounds.height)
        
        currSearchType = .normalSearch
        
        tagCurrentPage = 0
        venueArray.removeAll()

        if index == 0{
            currSearchType = .allSearch
            self.positionScroll.deleteAllTags()
            allCategoriesSearch()
        }else{
            self.category = self.categoryArray[index - 1]
            self.sigleCategorySearch()
        }
    }
    
    func locationAndInputStringSearchResult(_ inputStr : String){

        let radius = 100000
        let limit = 50

        let stringQuery = DataQueryProvider.queryForVenuesMatchingString(inputStr)
        let locationQuery = DataQueryProvider.venuesAround(currLocation, withinRadius: radius)
        let andQuery = AVQuery.andQuery(withSubqueries: [(locationQuery as! SimpleQuery).query, stringQuery ])
        andQuery.maxCacheAge = 60 * 300
        andQuery.limit =  limit
        andQuery.skip = limit * tagCurrentPage
        
        andQuery.countObjectsInBackground { (counts, error) in
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if counts == 0{
                self.searchDoneWithoutResult()
            }else{
                andQuery.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    if error != nil {
                        log.error(error!.localizedDescription)
                        self.removeLoadingView()
                    }
                    else{
                        if objects!.count > 0 {
                            self.categorySearchDoneWithResult(objects! as [AnyObject], withPaging: true)
                        }else {
//                            self.showAlert("没有更多了")
                        }
                    }
                })
                
            }
        }
    }

    func reActiveLoadingAnimation() {
        for  subViews in self.loadingV.subviews{
            if let lodingV = subViews as? SARMaterialDesignSpinner {
                if lodingV.isAnimating {
                    lodingV.isAnimating = !lodingV.isAnimating
                    lodingV.startAnimating()
                }
            }
        }
    }
    func removeLoadingView()  {
        self.loadingV.removeFromSuperview()
        inPutTextfield.isUserInteractionEnabled = true
        inPutTextfield.textColor = Config.Colors.TextfieldTextColor
        textfield.isUserInteractionEnabled = true
        let placeHolderLabel = inPutTextfield!.value(forKey: "placeholderLabel")as?UILabel
        placeHolderLabel!.textColor = Config.Colors.TextfieldTextColor
    
        self.tableViewRight.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        switchBtn.isUserInteractionEnabled = true
    }
    
    func categorySearchDoneWithResult(_ objects: [AnyObject], withPaging paging: Bool = false) {
        
//        let pageVenues = objects as! [Venue]

        if paging {
            venueArray += objects as! [Venue]
        } else {
            venueArray = objects as! [Venue]
        }
        self.removeLoadingView()
        let diffArray = self.fillTagViewWithArray(venueArray)
        self.positionScroll.mj_footer.endRefreshing()
        let str = String(diffArray.count)
        let title = NSLocalizedString("Location", comment:"地点 ") + str
        venueBtn.setTitle(title, for: UIControlState())
    
        let query = DataQueryProvider.queryForVenuesRecommendations(venueArray)
        self.tableViewRight.handleSimpleQuery(query)
    }

    
    //MARK: - RecommendationSelection Protocol
    
    func onRecommendationSelected(_ recommendation: Recommendation) {
        // leancloud AVAnalytics
        AVAnalytics.event("搜索进动态详情页面")
        let previewViewController = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    
    func searchDoneWithoutResult(){
        venueArray.removeAll()
        positionScroll.deleteAllTags()
        tableViewRight.removeAll()
        tableViewRight.reloadData()
        self.removeLoadingView()
        venueBtn.setTitle(NSLocalizedString("Location", comment:"地点"), for: UIControlState())
        recommendationBtn.setTitle(NSLocalizedString("Dynamic", comment:"动态"), for: UIControlState())
        
    }
}

extension DestinationDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func createCategoryTable(){
        
        if tableBackgroundView ==  nil{
            let   tableWidth  = (UIScreen.main.bounds.width) - 20
            table.frame = CGRect(x: 10, y: textfield.frame.origin.y, width: tableWidth, height: 272)
            table.dataSource = self
            table.delegate = self
            
            table.register(tableViewCell.self,
                                forCellReuseIdentifier: cellIdentifer)
            
            tableBackgroundView = UIButton()
            tableBackgroundView.bounds = view.bounds
            tableBackgroundView.center = view.center
            tableBackgroundView.backgroundColor = UIColor.init(colorLiteralRed: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
            tableBackgroundView.addSubview(table)
            tableBackgroundView.addTarget(self, action: #selector(DestinationDetailViewController.removeCategoryTable), for: .touchUpInside)
            self.view.addSubview(tableBackgroundView)
            table.backgroundColor = UIColor.clear
            table.layer.cornerRadius = 2
            table.clipsToBounds = true
            table.isScrollEnabled = false
            tableBackgroundView.isHidden = false
            
            if UIScreen.main.bounds.size.height <= 568 {
                table.frame = CGRect(x: 10, y: textfield.frame.origin.y + 30, width: tableWidth, height: 200)
                table.isScrollEnabled = true
            }

        }else{
            tableBackgroundView.isHidden = false
        }
               hiddenTextfield()
    }
    
    func hiddenTextfield() {
        textfield.isHidden = true
        textfield.backgroundColor = UIColor.clear
        textfield.leftView?.isHidden = true
        textfield.rightView?.isHidden = true
    }
    func showTextfield() {
        textfield.isHidden = false
        textfield.backgroundColor = Config.Colors.TextfieldBackgrounColor
        textfield.leftView?.isHidden = false
        textfield.rightView?.isHidden = false
    }
    func removeCategoryTable(){
        inPutTextfield.isUserInteractionEnabled = true
        tableBackgroundView.isHidden = true
        showTextfield()
//        textfield.text = items[0]
        showCategoryList = false
        switchBtn.isUserInteractionEnabled = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count + 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer,
                                                               for: indexPath) as! tableViewCell
        if (indexPath as NSIndexPath).row != 0 {
            cell.initCustomView(categoryArray[(indexPath as NSIndexPath).row-1].name)
            cell.accessoryButton.isHidden = true
        }else{
            cell.initCustomView(NSLocalizedString("All", comment:"全部"))
        }
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        self.textfield.isUserInteractionEnabled = true
        inPutTextfield.text = ""
        showCategoryList = true
        switchBtnClick(switchBtn)
        showTextfield()
        self.addLoadingView()
        var text = NSLocalizedString("All", comment:"全部")
        if (indexPath as NSIndexPath).row != 0 {
            text = categoryArray[(indexPath as NSIndexPath).row-1].name
        }
        textfield.text = text
        venueArray.removeAll()
        positionScroll.deleteAllTags()
        categorySwitchSearch((indexPath as NSIndexPath).row)

    }
    
}

//MARK: - TagView Delegate
extension DestinationDetailViewController : positionScrollViewDelegate ,UITextFieldDelegate{
    func didSelectedTag(_ tagControl : TagControl)
    {

        for location in venueArray {
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
        if self.currSearchType == SearchType.allSearch{
            self.allCategoriesSearch()
        }else if self.currSearchType == SearchType.inputSearch{
            self.locationAndInputStringSearchResult(self.inPutTextfield.text!)
        }else{
            self.sigleCategorySearch()
        }
    }

//MARK: - UITextfieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        venueArray.removeAll()
        self.tagCurrentPage = 0
        self.currSearchType = .inputSearch
        self.searchDoneWithoutResult()
        if textField == textfield {
            showCategoryList = false
            switchBtnClick(switchBtn)
            textfield.isUserInteractionEnabled = false
            return false
        }
        inPutTextfield.leftView = nil
        let width : CGFloat = 25
        let leftView1 = UIView()
        leftView1.frame = CGRect(x: 0, y: 0,width: width, height: 25)
        leftView1.backgroundColor = UIColor.clear
        let iconView = UIImageView()
        iconView.frame = CGRect(x: width - 20, y: 6, width: 15, height: 14)
        iconView.image = UIImage(named: "gray_search")
        iconView.backgroundColor = UIColor.clear
        leftView1.addSubview(iconView)
        inPutTextfield.leftView = leftView1
        inPutTextfield.text = ""

        textfield.textColor = UIColor.lightGray
        textfield.isUserInteractionEnabled = false
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textfield {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if inPutTextfield.text?.characters.count > 0 {
            self.addLoadingView()
            
            locationAndInputStringSearchResult(textField.text!)
        }else{
            self.searchDoneWithoutResult()
            
        }
        textField.resignFirstResponder()
        textfield.isUserInteractionEnabled = true
        textfield.textColor = Config.Colors.TextfieldTextColor
        showCategoryList = false
        self.perform(#selector(DestinationDetailViewController.saveSearchHistory(_:)), with: nil, afterDelay: 2)
        return true
    }
    
    func saveSearchHistory(_ inputStr : String){
        if  (User.current() != nil) {// Adapter visitor login
            if inPutTextfield.text?.characters.count < 1{
                return
            }
            let search = Search(string: inPutTextfield.text!, author: User.current() as! User)
            search.saveInBackground { (saved, error) -> Void in
                if error != nil {
                    log.error("Search save : \(error?.localizedDescription)")
                } else if saved {

                    DataQueryProvider.searchPopularityForString(search.string!).executeInBackground({ (objects:[Any]?, error) -> () in
                        if objects?.count > 0 {
                            if let searchPopularity = objects?[0] as? SearchPopularity {
                                searchPopularity.popularity = NSNumber(integerLiteral:searchPopularity.popularity!.intValue + 1)
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        textfield.isUserInteractionEnabled = true
        textfield.textColor = Config.Colors.TextfieldTextColor
        if textField == textfield {
            return
        }
    }
    
    
    func allCategoriesSearch()  {

        let radius = locationRadius
        let query: AVQuery = AVQuery(className: "Venue")
        query.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: currLocation), withinKilometers: Double(radius / 1000))
        
        query.limit =  tagLimit
        query.skip = tagLimit * tagCurrentPage
        query.order(byDescending: "createdAt")
        query.maxCacheAge = 60 * 300
        
        query.countObjectsInBackground { (counts, error) in
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if counts == 0{
                self.removeLoadingView()
                self.searchDoneWithoutResult()
            }else{
                
                query.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    if error != nil {
                        log.error(error?.localizedDescription)
                        self.removeLoadingView()
                    }
                    else{
                        if objects?.count > 0 {
                            self.categorySearchDoneWithResult(objects! as [AnyObject], withPaging: true)
                        }
                        else {
//                                self.showAlert("没有更多了"
                            self.positionScroll.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                })

            }
        }
        
    }

    func sigleCategorySearch() {


        let query: AVQuery = AVQuery(className: "Venue")
        query.limit =  tagLimit
        query.skip = tagLimit * tagCurrentPage
        query.whereKey("category", containedIn: [self.category])

        query.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: currLocation), withinKilometers: Double(locationRadius / 1000))

        query.includeKey("category")
        
        query.countObjectsInBackground { (counts, error) in
            if error != nil {
                log.error(error?.localizedDescription)
                self.removeLoadingView()
            }
            else if counts == 0{
                self.searchDoneWithoutResult()
            }else{
                
                query.findObjectsInBackground({ (objects:[Any]?, error) -> () in
                    
                    if error != nil {
                        log.error(error?.localizedDescription)
                        self.removeLoadingView()
                    }
                    else{
                        if objects?.count > 0 {
                            self.categorySearchDoneWithResult(objects as! [AnyObject], withPaging: true)
                        }
                        
                    }
                })
                
            }
        }

    }
    
   func  setCategoty(){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.tmpObject = self.category as AnyObject?

    }
    func filterSameVenues(_ array: [Venue]) -> [Venue] {
        var venueArr = [Venue]()
        for i in 0..<array.count{
            let ven = array[i]
            print("origin + \(ven.customName)")
            var repeats = 0
            venueArr.append(ven)
            for j in 0..<venueArr.count{
                let ven1 = venueArr[j]
                let equals = (ven.coordinate?.longitude)! == (ven1.coordinate?.longitude)! && (ven.coordinate?.latitude)! == (ven1.coordinate?.latitude)!  && ven.customName! == ven1.customName!
                if equals  {
                    repeats += 1
                }
                if repeats > 1 {
                    venueArr.remove(at: j)
                    break
                }
            }
        }
        
        return venueArr
    }
}



extension DestinationDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        if scrollView == bgScrollView {
            
        }
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        self.currentPage = Int(currentPage)
        

        switch Int(currentPage) {
        case 0:
            self.switchToPageLeft()
        case 1:
            self.switchToPageRight()
        default:
            self.switchToPageLeft()
        }
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Test the offset and calculate the current page after scrolling ends
    }
}

extension DestinationDetailViewController: SearchRecommendationCount{
    func searchRecommendationCountCallBack(_ count:Int){
        self.removeLoadingView()
        let commomtitle = NSLocalizedString("Dynamic", comment:"动态")
        let currTittle = recommendationBtn.currentTitle!
        
        if count > 0 {
            let str = String(count)
            let title = commomtitle + str
            recommendationBtn.setTitle(title, for: UIControlState())
        }else if commomtitle == currTittle{
            return
        }else{
            recommendationBtn.setTitle(commomtitle, for: UIControlState())
        }
    }

}

class tableViewCell: UITableViewCell {
    var titleLabel: UILabel? = UILabel()
    var separatorLine:UIView = UIView()
    var accessoryButton:UIButton = UIButton()

    func initCustomView(_ title : String){
        titleLabel?.frame = CGRect(x: 25, y: 0, width: frame.width, height: frame.height)
        titleLabel?.text = title
        titleLabel?.textColor = Config.Colors.TextfieldTextColor
        titleLabel?.textAlignment = .left
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(titleLabel!)
        
        backgroundColor = Config.Colors.TextfieldBackgrounColor
        separatorLine.frame = CGRect(x: 0, y: frame.height - 0.3, width: frame.width, height: 0.3)
        separatorLine.backgroundColor = UIColor(bd_hexColor : "98969680")
        self.addSubview(separatorLine)
        
        
        accessoryButton.frame = CGRect(x: 0, y: 12, width: 18, height: 10)
        accessoryButton.backgroundColor = UIColor.clear
        accessoryButton.setImage(UIImage(named: "down"), for: UIControlState())
        let imageRect = CGRect(x: 0,y: 0, width: 18, height: 10)
        accessoryButton.imageRect(forContentRect: imageRect)
        self.accessoryView = accessoryButton
    }
}


extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}


