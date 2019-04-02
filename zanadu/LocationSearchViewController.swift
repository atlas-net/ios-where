//
//  LocationSearchViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/13/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
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


protocol LocationSearchViewControllerDelegate {
    func locationSearchViewControllerDelegateDidSelectVenue(_ venue: Venue)
}

class LocationSearchViewController: BaseViewController,LocationAddViewControllerDelegate ,VenueSearchHandlerDelegate{

    //MARK: - Outlets
    
    @IBOutlet var viewHandler: VenueSearchHandler!
    @IBOutlet weak var topButtonView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var topView: UIView!
    
    
    //MARK: - Properties
    
    var searchController: UISearchController!
    var  isFromRecommendationDetail = false
    var didSelectVenueDelegete:LocationSearchViewControllerDelegate?
    var categoriesArray = [Category]()

    lazy var loadingV:UIView = LoadingView()
    //MARK: - Actions
    
    
    //MARK: - ViewController's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        topButtonView.backgroundColor = UIColor.white
        
        tableView.register(VenueSearchTavleViewCell.self, forCellReuseIdentifier: "VSHCell")
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.topView.frame.size.height)
        
        self.topView!.addSubview(self.searchController.searchBar)
        self.definesPresentationContext = false

        searchController!.searchBar.barTintColor = UIColor.clear
        searchController!.searchBar.tintColor = Config.Colors.ZanaduCerisePink
        searchController!.searchBar.barStyle = UIBarStyle.default
        searchController!.searchBar.keyboardAppearance = UIKeyboardAppearance.default
        searchController!.searchBar.returnKeyType = UIReturnKeyType.search
        searchController!.searchBar.backgroundImage = UIImage()
        searchController!.searchBar.backgroundColor = UIColor.white
        searchController!.searchBar.placeholder = NSLocalizedString("Search", comment:"搜索")
        viewHandler.venueSearchHandleDelagete = self
        

        self.addCircleLoadingView()
        
        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = Config.Colors.MainContentColorBlack
            textFieldInsideSearchBar.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        }
        if let photoLocation = RecommendationFactory.sharedInstance.photosCenter {
            viewHandler.setPhotoLocation(photoLocation)
        }
        let userLocation = Location.shared
        if userLocation.coordinate.latitude != 0 && userLocation.coordinate.longitude != 0 {
            viewHandler.setUserLocation(userLocation)
        }
        self.viewHandler.selectHandler = { venue in
            if self.isFromRecommendationDetail {
                if let didSelectVenueDelegete = self.didSelectVenueDelegete {
                    didSelectVenueDelegete.locationSearchViewControllerDelegateDidSelectVenue(venue)
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                RecommendationFactory.sharedInstance.venue = venue
                print("venue stored to appDelegate. Launching preview....", terminator: "")
                let query =  DataQueryProvider.categoryQuery()
                query.findObjectsInBackground { (objects:[Any]?, error) in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    }else{
                        
                        if let categorys = objects as? [Category]{
                            self.categoriesArray = categorys
                            let vcs = self.navigationController?.viewControllers
                            if vcs?.count > 3{
                                return
                            }
                            self.performSegue(withIdentifier: "showCreationFormScreen", sender: self)
 
                        }else{

                        }
                    }
                }
                print("Segue performed", terminator: "")
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.viewHandler.reloadData("", tableView: self.tableView)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
        let locationManager = LocationManager.sharedInstance
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        setNav()
    }
    
    func setNav() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        backButton.backgroundColor = UIColor.clear
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setImage(UIImage(named: "backIcon"), for: UIControlState())
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setTitle(NSLocalizedString("Back", comment:"返回"), for: UIControlState())
        backButton.setTitleColor(Config.Colors.MainContentColorBlack, for:.normal)
        backButton.addTarget(self, action: #selector(LocationSearchViewController.backButtonClick), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
    }
    
    func  backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationItem.title = NSLocalizedString("Location current", comment:"所在位置")
        tableView.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
 
        
        if RecommendationFactory.sharedInstance.venue != nil {
             self.viewHandler.reloadResultsWithSelectedVenueOnTopInTableView(self.tableView)

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        searchController.isActive = false
        self.loadingV.removeFromSuperview()
        let locationManager = LocationManager.sharedInstance
        locationManager.stopUpdatingLocation()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "creatANewVenue"{
            let vc = segue.destination as! LocationAddViewController
            vc.delegate = self
             vc.photoLocation = RecommendationFactory.sharedInstance.photosCenter
        }
        
        if segue.identifier == "showCreationFormScreen" {
            let destinationVC = segue.destination as? CreationFormViewController
            destinationVC?.categoriesArray = self.categoriesArray

            if let venue = RecommendationFactory.sharedInstance.venue{
                let draftVenue = DraftRecommendationVenue()
                draftVenue.createVenueRecommendationInfo(venue)
                draftVenue.createRecommendationText("", description: "")
                RecommendationFactory.sharedInstance.draftArray.insert(draftVenue, at: 1)
            }
        }
    }
    func locationAddViewControllerDidAddVenue(_ tmpVenue: AnyObject) {
         let newVenue = tmpVenue as! Venue
        viewHandler.addVenue(newVenue, inTableView: tableView, atIndex: 0)
    }
    
    //MARK: - Method Overrides
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    func addCircleLoadingView() {
        self.view.addSubview(self.loadingV)
        self.loadingV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.loadingV.isHidden = false
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
    func finishReloadCallBack(){
        self.loadingV.isHidden = true
    }
    
    func showAlert()  {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: "请前往到设置->隐私->定位服务，打开where获取地理位置权限", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            self.goToSetting()
            self.loadingV.isHidden = true
            
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
            self.loadingV.isHidden = true

        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    func goToSetting() {
        let url = URL.init(string: UIApplicationOpenSettingsURLString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        }
    }
}

extension LocationSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.addCircleLoadingView()
        let searchString = searchController.searchBar.text ?? ""
        viewHandler.reloadData(searchString, tableView: tableView)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        viewHandler.reloadData("", tableView: tableView)
    }
}

extension LocationSearchViewController : LocationManagerDelegate{
    func locationFound(_ latitude: Double, longitude: Double) {

    }
    
    func locationManagerStatus(_ status:NSString){
        if status as String == NSLocalizedString("Denied access", comment: "") {
            self.showAlert()

        }
    }
}
