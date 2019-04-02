//
//  VenueHomeListingViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit

/**
Display a page with cover, tabs and listings
*/
class VenueHomeListingViewController : BaseViewController, TagViewDelegate, MKMapViewDelegate {
    
    //MARK: - Properties
    
    var venue:Venue! {
        didSet {
            venueDidSet()
        }
    }

    var tags = Set<Tag>()

    static let maxTagsDisplayed = 5

    fileprivate var currentPage = 0
    var lastScrollOffset: CGFloat = 0
    var loadingV = LoadingView()
    
    //MARK: - Outlets
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!

    @IBOutlet weak var homeListingCoverView: HomeListingCoverView!
    @IBOutlet weak var tabButtonsContainer: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var tagView: UITagSelectionView!
    @IBOutlet weak var popularityLabel: UILabel!

    @IBOutlet weak var leftTabButtonView: UIView!
    
    @IBOutlet weak var leftTabButtonLabel: UILabel!

    @IBOutlet weak var allRecommendationView: RecommendationStreamView!
    
    @IBOutlet weak var lateralScrollView: NoAutoScrollUIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lateralScrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var allRecommendationHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Actions
    
    func switchToPage(_ index:Int) {
        lateralScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: lateralScrollView.bounds.height)
        
        let rect = CGRect(x: self.view.frame.width * CGFloat(index), y: 0, width: self.view.frame.width, height: lateralScrollView.frame.height)
        lateralScrollView.manuallyScrollRectToVisible(rect, animated: true)
        
        leftTabButtonView.backgroundColor = index == 0 ? Config.Colors.TagFieldBackground : Config.Colors.TagViewBackground
        
        leftTabButtonLabel.textColor = index == 0 ? Config.Colors.ZanaduCerisePink : Config.Colors.LightGreyTextColor
        
        self.currentPage = index
    }
    
    func onLeftTabButtonTapped() {

        switchToPage(0)
    }
    
    
    //MARK: - Methods
    
    func venueDidSet() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tmpObject = self.venue
    }
    
    func setupMap() {
        
        if let coordinate = venue.coordinate {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.deviatedCoordinates(), 200, 200), animated: true)
            self.mapView.setCenter(location.deviatedCoordinates(), animated: true)
        }
    }
    
    fileprivate func setupTags() {
        

//        var query: AVQuery = Tag.query()
//        query.whereKey("tags", containedIn: )
//        query.wh
        
//        AVQuery.doCloudQueryInBackgroundWithCQL("select include tags, tags.objectId from Recommendation where venue=pointer('Venue', '\(venue.objectId)') limit 10") { (result, error) -> Void in
//            if error != nil {
//                log.error(error?.localizedDescription)
//            } else {
//
//
//            }
//        }
//        var query = AVRelation.reverseQuery(Recommendation.parseClassName(), relationKey: "tags", childObject: Tag.parseClassName())
//        query.whereKey(, containedIn: <#[AnyObject]!#>)
//
//
        if tags.count <= 0 {
            return
        }
     //       self.tagView.removeFromSuperview()
    //    } else {
            log.error("TAGLOADING : add tags => \(self.tags)")
            self.tagView.setTags(Array(tags))
        tagView.inputTagView._tagField._scrollView.setContentOffset(CGPoint.zero, animated: true)
      //  }
    }
    
    
    func initTabButtons() {
        let leftButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VenueHomeListingViewController.onLeftTabButtonTapped))
        leftTabButtonView.addGestureRecognizer(leftButtonTap)
    }
    
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.view.backgroundColor = Config.Colors.TagFieldBackground
        mainContentView.backgroundColor = Config.Colors.TagFieldBackground
        tabButtonsContainer.backgroundColor = Config.Colors.TagFieldBackground
        lateralScrollView.backgroundColor = Config.Colors.TagFieldBackground
        contentView.backgroundColor = Config.Colors.TagFieldBackground
        lateralScrollView.autoScrollEnabled = false
        lateralScrollView.delegate = self
        allRecommendationView.isScrollEnabled = false
        allRecommendationView.isBiggerCellSize = true
        
        switchToPage(0)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if venue == nil {
            guard let tmpVenue = appDelegate.tmpObject as? Venue else {
                log.error("Venue object not set")
                return
            }
            self.venue = tmpVenue
        }
        
        setupMap()
        locationButton.setTitle(" " + venue!.customName!, for: UIControlState())
        title = venue!.customName!
        
        
        if #available(iOS 9.0, *) {
            SpotlightSearch.setupSearchableItemWithImage(UIImage(named: Config.AppConf.defaultUserAvatar)!, uniqueId: venue.objectId!, domainId: venue.objectId!, title: venue.customName!, description: venue.customAddress!)
        }
        
        allRecommendationView.streamViewDelegate = self
        allRecommendationView.selectionDelegate = self
        allRecommendationView.pullToRefresh = false
        allRecommendationView.delegate = self
        
        allRecommendationView.dataQuery = DataQueryProvider.queryForVenueRecommendations(venue!)

        tagView.setup(self)
        tagView.inputTagView.editable = false
        tagView.inputTagView.style = .none
        tagView.inputTagView.placeholder = ""
        
        tagView.backgroundColor = UIColor.clear
        tagView.inputTagView.backgroundColor = UIColor.clear        

//        tagView.inputTagView._tagField.textAlignment = NSTextAlignment.Center
        
        initTabButtons()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
        lateralScrollView.contentSize = contentView.frame.size

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
    
    //Mark: - MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! LocationAnnotation
        
        anView!.image = UIImage(named:cpa.imageName)
        anView!.centerOffset = CGPoint(x: 6, y: -26)
        return anView
    }
    
    //MARK: - TagView Delegate

    func tagView(_ tag: TagView, performSearchWithString string: String, completion: ((_ results: Array<Tag>) -> Void)?) {
        
    }
    
    func tagView(_ tag: TagView, displayTitleForObject object: AnyObject) -> String {
        return "."
    }
    
    func tagView(_ tagView: TagView, didSelectTag tag: TagControl) {

        for tagObject in tags {
            if tag.title == tagObject.name {
                let vc = storyboard?.instantiateViewController(withIdentifier: "TagHomeListingViewController") as! TagHomeListingViewController
                vc.tag = tagObject
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


extension VenueHomeListingViewController: StreamViewDelegate {
    func onDataFetched(_ streamView: StreamView, objects: [AnyObject]) {
        if streamView == allRecommendationView {
            popularityLabel.text = popularityLabel.text!.substring(to: popularityLabel.text!.characters.index(popularityLabel.text!.startIndex, offsetBy: 3)) + "\(objects.count)"
        }
        
        guard let recommendations = objects as? [Recommendation] else {
            return
        }
        
        popularityLabel.text = popularityLabel.text!.substring(to: popularityLabel.text!.characters.index(popularityLabel.text!.startIndex, offsetBy: 3)) + "\(recommendations.count)"
        
        log.error("TAGLOADING : dataFetched \(recommendations.count)")
        
        for recommendation in recommendations {
            log.error("TAGLOADING : recommendation in recommendations \(recommendation.title)")
            
            var groupedTags: [String: (count: Int, tag: Tag)] = [:]
            recommendation.tags?.query().findObjectsInBackground({ (objects, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    log.error("TAGLOADING : found tags")
                    for tag in objects as! [Tag] {
                        if groupedTags.index(forKey: tag.name) != nil {
                            groupedTags[tag.name]!.count = groupedTags[tag.name]!.count + 1
                        } else {
                            groupedTags[tag.name] = (1, tag)
                        }
                    }
                    
                    let sortedArray = Array(groupedTags).sorted(by: {$0.0 > $1.0})
                    for (i,v) in sortedArray.enumerated() {
                        if i < VenueHomeListingViewController.maxTagsDisplayed {
                            self.tags.insert(v.1.tag)
                            log.error("TAGLOADING : added tag \(v.1.tag) ********")
                        }
                    }
                    delay(2, closure: { () -> () in

                        self.setupTags()
                    })
                }
            })
        }
    }
    
    func onHeightChangedWithStream(_ streamView: StreamView, height: CGFloat) {
        self.loadingV.removeFromSuperview()
        mainContentViewHeightConstraint.constant = homeListingCoverView.bounds.height + height + tabButtonsContainer.bounds.height + MainTabBarController.tabBarHeight
        lateralScrollViewHeightConstraint.constant = height
        allRecommendationHeightConstraint.constant = height

    }
}

extension VenueHomeListingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == lateralScrollView {
            // Test the offset and calculate the current page after scrolling ends
            let pageWidth:CGFloat = scrollView.frame.width
            let page = Int(floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1)

            self.switchToPage(page)
        }
        lastScrollOffset = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if allRecommendationView == scrollView {
            let scrolledOffset = scrollView.contentOffset.y
            
            if scrolledOffset < 0 {

                
                if mainScrollView.contentOffset.y > 0 && lastScrollOffset < 0 {
                    mainScrollView.contentOffset.y -= min(abs(scrolledOffset - lastScrollOffset) * 3, mainScrollView.contentOffset.y)
                }
            } else if scrolledOffset > 0 {
                if mainScrollView.contentOffset.y < mapView.frame.height && lastScrollOffset > 0 /*&& lastScrollOffset < scrolledOffset*/ {

                    mainScrollView.contentOffset.y += min(abs(scrolledOffset - lastScrollOffset) * 3, mapView.frame.height - mainScrollView.contentOffset.y)
                }
            }
            lastScrollOffset = scrolledOffset
        }
    }
}

extension VenueHomeListingViewController: RecommendationSelectionProtocol {
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension VenueHomeListingViewController: UITableViewDelegate {
    
}
