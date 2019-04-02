//
//  VenueSearchHandler.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/16/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit


@objc protocol VenueSearchHandlerDelegate: NSObjectProtocol{
    @objc optional func finishReloadCallBack()
}
typealias VSHVenueBlock = (_ venue: Venue) -> ()

class VenueSearchHandler: NSObject, NSSecureCoding, UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating ,VenueSearchDataSourceDelegate{

    //MARK: - Class Properties

    let VSHDefaultCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
    let VSHDefaultTimeout = 30.0
    let VSHDefaultMinimumScaleFactor: CGFloat = 0.5
    let VSHDefaultCellReuseIdentifier = "VSHCell"
    
    
    //MARK: - Instance Properties
    
    var venueSearchDataSource = VenueSearchDataSource()
    
    var selectHandler: VSHVenueBlock?
    var selectedRowIndex: IndexPath?
    //var lastSearchText: String?

    weak var venueSearchHandleDelagete : VenueSearchHandlerDelegate!

    //MARK: - IBInspectable Properties

    @IBInspectable var cellHeight: Float
    @IBInspectable var refreshControl: Bool
    @IBInspectable var categoryImage: Bool
    @IBInspectable var addressDetail: Bool
    @IBInspectable var distanceDetail: Bool
    @IBInspectable var textLabelColor: UIColor
    @IBInspectable var detailLabelColor: UIColor
    @IBInspectable var backgroundColor: UIColor
    
    
    //MARK: - Initializers
    
    override init() {
        cellHeight = 60
        refreshControl = true
        categoryImage = true
        addressDetail = true
        distanceDetail = true
        textLabelColor = Config.Colors.MainContentBackgroundWhite
        detailLabelColor = Config.Colors.SecondTitleColor
        backgroundColor = Config.Colors.MainContentBackgroundWhite
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        cellHeight = aDecoder.decodeFloat(forKey: "cellHeight")
        refreshControl = aDecoder.decodeBool(forKey: "refreshControl")
        categoryImage = aDecoder.decodeBool(forKey: "categoryImage")
        addressDetail = aDecoder.decodeBool(forKey: "addressDetail")
        distanceDetail = aDecoder.decodeBool(forKey: "distanceDetail")
        textLabelColor = aDecoder.decodeObject(forKey: "textLabelColor") as! UIColor
        detailLabelColor = aDecoder.decodeObject(forKey: "detailLabelColor") as! UIColor
        backgroundColor = aDecoder.decodeObject(forKey: "backgroundColor") as! UIColor
        super.init()        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(cellHeight, forKey: "cellHeight")
        coder.encode(refreshControl, forKey: "refreshControl")
        coder.encode(categoryImage, forKey: "categoryImage")
        coder.encode(addressDetail, forKey: "addressDetail")
        coder.encode(distanceDetail, forKey: "distanceDetail")
        coder.encode(textLabelColor, forKey: "textLabelColor")
        coder.encode(detailLabelColor, forKey: "detailLabelColor")
        coder.encode(backgroundColor, forKey: "backgroundColor")
    }

    
    //MARK: - NSSecureCoding
    
    static var supportsSecureCoding : Bool {
        return true
    }

    
    //MARK: - Public methods
    
    func setPhotoLocation(_ location: CLLocation) {
        self.venueSearchDataSource.photoLocation = location
    }

    func setUserLocation(_ location: CLLocation) {
        self.venueSearchDataSource.userLocation = location
        self.venueSearchDataSource.venueSearchDataSourceDelegate = self
    }
    
    func reloadResultsWithSelectedVenueOnTopInTableView(_ tableView: UITableView) {
        if let selectedRowIndex = selectedRowIndex , venueSearchDataSource.venueObjects.count > (selectedRowIndex as NSIndexPath).row {

            venueSearchDataSource.venueObjects.insert(venueSearchDataSource.venueObjects.remove(at: (selectedRowIndex as NSIndexPath).row), at: 0)
            tableView.reloadData()
        }
    }

    func addVenue(_ venue:Venue, inTableView tableView: UITableView, atIndex index:Int) {
        let vsd = ZanaduVenueSearchData(venue: venue, score: -1, currentLocation: FSNetworkingSearchController.currentLocation())
        
        if index >= 0 && index < venueSearchDataSource.venueObjects.count {
            venueSearchDataSource.venueObjects.insert(vsd, at: 0)
            selectedRowIndex = IndexPath(row: 0, section: 0)
            tableView.reloadData()
        }
        
    }
    
    func optimizeFoursquareSearchText(_ searchText: String) -> String{
        return searchText.replacingOccurrences(of: " " , with: " and ", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func reloadData(_ searchText: String, tableView: UITableView) {
        selectedRowIndex = nil
        
        self.venueSearchDataSource.venueObjects.removeAll()
        
        if searchText == ""{
            venueSearchDataSource.searchForPhotoLocation(reloadTableview: tableView)
            venueSearchDataSource.searchForUserLocation(reloadTableview: tableView)
        }else{
            venueSearchDataSource.searchMatchingString(searchText, reloadTableview: tableView)
        }
    }
    
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResult", terminator: "")
        reloadData(searchController.searchBar.text!, tableView: searchController.searchResultsController!.view as! UITableView)
    }
    

    //MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueSearchDataSource.venueObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VSHDefaultCellReuseIdentifier, for: indexPath) as! VenueSearchTavleViewCell
        
        
        if venueSearchDataSource.venueObjects.count > (indexPath as NSIndexPath).row {
            let venue = venueSearchDataSource.venueObjects[(indexPath as NSIndexPath).row]
            
            cell.textLabel!.text = venue.name
//            cell.textLabel!.minimumScaleFactor = VSHDefaultMinimumScaleFactor
            cell.textLabel?.textColor = textLabelColor
            
            var detailStr = ""
            var distanceStr = ""
            if addressDetail {
                detailStr = venue.address
            }
            if distanceDetail {
                if let distance = venue.distance {
                    if distance < 1 {
                        distanceStr = "\(Int(distance*1000))米"
                    } else if distance < 10 {
                        let formated = String(format:"%.1f",distance)
                        distanceStr = "\(formated)公里"
                    } else if distance < Double.infinity {
                        let formated = String(format:"%.0f",distance)
                        distanceStr = "\(formated)公里"
                    }
                    
                }
            }
//            if let zVenue = venue as? ZanaduVenueSearchData {
//                distanceStr = "W_" + "\(venue.score)"
//            } else {
//                distanceStr = "\(venue.score)"
//            }
            
            cell.addressLabel.text = detailStr
            cell.addressLabel.numberOfLines = 0
//            cell.addressLabel.minimumScaleFactor = VSHDefaultMinimumScaleFactor
            cell.addressLabel.textColor = self.detailLabelColor
            cell.distanceLabel.text = distanceStr
            cell.distanceLabel.textColor = self.detailLabelColor
            if selectedRowIndex != nil && (indexPath as NSIndexPath).row == 0 {
                cell.backgroundColor = Config.Colors.MainContentBackgroundWhite
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0, -64, 0, 0)
    }
    
    
    //MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedRowIndex = indexPath
        
        if selectHandler != nil && venueSearchDataSource.venueObjects.count > (indexPath as NSIndexPath).row {
            let venue = venueSearchDataSource.venueObjects[(indexPath as NSIndexPath).row]
            
            venueFromVenueSearchData(venue, completion: self.selectHandler!)
        }
    }
    
    func venueFromVenueSearchData(_ venueSearchData: VenueSearchData, completion: ((Venue)->())?) {
        if let completion = completion {
            switch venueSearchData {
            case is ZanaduVenueSearchData:
                let query = AVQuery(className: Venue.parseClassName())
                query.getObjectInBackground(withId: venueSearchData.id, block: { (object, error) -> Void in
                    if error != nil {
                        log.error("error: \(error?.localizedDescription)")
                    } else {
                        let venue = object as! Venue
                        completion(venue)
                    }
                })
            case is FoursquareVenueSearchData:
                print("foursquare venue", terminator: "")
                if let foursquareVenueSearchData = venueSearchData as? FoursquareVenueSearchData {
                    completion(foursquareVenueSearchData.toVenue())
                }
            case is BaiduVenueSearchData:
                print("foursquare venue", terminator: "")
                if let baiduVenueSearchData = venueSearchData as? BaiduVenueSearchData {
                    completion(baiduVenueSearchData.toVenue())
                }
            default:
                print("unknown type of venue... can't use it", terminator: "")
            }
        }
    }
    
    func finishSortedDataCallBack() {
        if let delegate = venueSearchHandleDelagete{
            delegate.finishReloadCallBack!()
        }
    }
}

