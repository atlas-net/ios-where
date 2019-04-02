//
//  VenueSearchDataSource.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 11/11/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



@objc protocol VenueSearchDataSourceDelegate: NSObjectProtocol{
    @objc optional func finishSortedDataCallBack()
}
/**
VenueSearchDataSource

Interface that handle the data retrieving / ranking / sorting from different source
*/
class VenueSearchDataSource {
    

    //MARK: - Public Properties

    var venueObjects = [VenueSearchData]()
    var photoLocation: CLLocation?
    var userLocation: CLLocation?
    weak var venueSearchDataSourceDelegate : VenueSearchDataSourceDelegate!
    //MARK: - Public Methods
    
    func searchForPhotoLocation(matchingString string: String? = nil, reloadTableview: UITableView) {
        if photoLocation != nil {
            searchForLocation(.photo, matchingString: string, reloadTableview: reloadTableview)
        }
    }

    func searchForUserLocation(matchingString string: String? = nil, reloadTableview: UITableView) {
        if photoLocation == nil{
          if userLocation != nil {
            searchForLocation(.user, matchingString: string, reloadTableview: reloadTableview)
              }
          }
    }

    func searchMatchingString(_ string:String, reloadTableview: UITableView) {
        // Search around photo
        searchForPhotoLocation(matchingString: string, reloadTableview: reloadTableview)
        
        // Search around user
        searchForUserLocation(matchingString: string, reloadTableview: reloadTableview)

        // Global search
        globalSearchMatchingString(string, reloadTableview: reloadTableview)
    }

    fileprivate func globalSearchMatchingString(_ string: String, reloadTableview: UITableView) {
        var resCounter = 0

        // Where
        
        searchZanaduVenuesWithString(string) { (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                self.handleSearchResponse(.global, source: .where, objects: objects as [AnyObject]!)
            }
            
            resCounter += 1
            if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
            }
        }
        
        // Baidu

        BaiduAPI.poiListForSuggestionQuery(string) { (objects, error) -> Void in
            if error != nil {
                log.error("\(error)")
            } else {
                self.handleSearchResponse(.global, source: .baidu, objects: objects)
            }
            resCounter += 1
            if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
            }
        }
        
        
        // Foursquare
        
        FSNetworkingSearchController.searchWithNoSuggestion(string, location: nil, radius: nil, limit: Config.VenueSearch.VenuesPerPage as NSNumber!, intent: "global") { (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                self.handleSearchResponse(.global, source: .foursquare, objects: objects as [AnyObject]!)
            }
            resCounter += 1

            if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
            }
        }
    }
    
    
    //MARK: - Private Methods
    
    fileprivate func searchForLocation(_ type: SearchDataType, matchingString string: String?, reloadTableview: UITableView) {
        var resCounter = 0
        
        // location init
        
        var tmpLocation: CLLocation?
        switch type {
        case .user:
            tmpLocation = userLocation
        case .photo:
            tmpLocation = photoLocation
        default:
            break
        }
        guard let location = tmpLocation else { return }
        
        // Where Search
        
        searchZanaduVenuesNearLocation(location, matchingString: string) { (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                self.handleSearchResponse(type, source: .where, objects: objects as [AnyObject]!)
            }
            resCounter += 1
//
//            if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
//            }
        }
        
        // Baidu Search
        
        if let string = string {
            BaiduAPI.poiListForSuggestionQuery(string, withLocation: location, completion: { (objects, error) -> Void in
                if error != nil {
                    log.error("\(error)")
                } else {
                    self.handleSearchResponse(type, source: .baidu, objects: objects)
                }
                resCounter += 1

//                if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
//                }
            })
        } else {
            BaiduAPI.poiListForLocation(location, radius: Config.VenueSearch.SearchRadius) { (objects, error) -> Void in
                if error != nil {
                    log.error("\(error)")
                } else {
                    self.handleSearchResponse(type, source: .baidu, objects: objects)
                }
                resCounter += 1
//
//                if resCounter > 2 {
                self.sortNReload(reloadTableview, resCount: resCounter)
//                }
            }
        }
        
        // FS Search
        
        FSNetworkingSearchController.search(string ?? "", location: location, radius: Config.VenueSearch.SearchRadius as NSNumber!, limit: Config.VenueSearch.VenuesPerPage as NSNumber!, intent:"browse") { (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                self.handleSearchResponse(type, source: .foursquare, objects: objects as [AnyObject]!)
            }
            resCounter += 1
//
//            if resCounter > 2 {
            self.sortNReload(reloadTableview, resCount: resCounter)
//            }
        }
        

    }
    
    fileprivate func handleSearchResponse(_ type: SearchDataType, source: SearchDataSource, objects: [AnyObject]!) {
        if objects.count > 0 {
            for (index, object) in objects.enumerated() {
                let score = VenueSearchData.calculateScore(source, type: type, rank: index)
                let venue:VenueSearchData
                
                switch source {
                case .where:
                    venue = ZanaduVenueSearchData(venue: object as! Venue, score: score, currentLocation: self.userLocation)
                case .baidu:
                    venue = BaiduVenueSearchData(baiduVenue: object as! NSDictionary, score: score, currentLocation: self.userLocation)
                case .foursquare:
                    venue = FoursquareVenueSearchData(foursquareVenue: object as! NSDictionary, score: score)
                }
                

                
                self.venueObjects.append(venue)
            }
        }
    }
    
    /**
     SortNReload
     
     Sort, Deduplicate and Reload the TableView
     
     - parameter tableview: The TableView to reload once data is sorted
     */
    fileprivate func sortNReload(_ tableview: UITableView , resCount : NSInteger) {
        var uniqArray = [VenueSearchData]()
        
        venueObjects = venueObjects.reversed()
        
        for venue in venueObjects {
            var replace = false
            
            let index = uniqArray.index { (venueObject:VenueSearchData) -> Bool in
                let equals = venueObject.name == venue.name
                if equals {
                    if let _ = venue as? ZanaduVenueSearchData {
                        replace = true
                    }
                }
                return equals
            }
            if index == nil {
                uniqArray.append(venue)
            } else if replace {
                uniqArray[index!] = venue
            }
        }
        
        venueObjects = venueObjects.reversed()
        
        self.venueObjects = uniqArray.sorted { (venue1, venue2) -> Bool in
            venue1.score > venue2.score
        }
        
        tableview.reloadData()
        if let delegate = venueSearchDataSourceDelegate {
            delegate.finishSortedDataCallBack!()
        }
        if resCount > 2{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false 
        }

    }

    //MARK: - Search related  methods
    
    fileprivate func searchZanaduVenuesNearLocation(_ location:CLLocation, matchingString string: String? = nil, withCompletionBlock completion: @escaping AVArrayResultBlock) {
        
        let query: Query?
        
        if let string = string {
            query = DataQueryProvider.queryForVenuesAroundLocation(location, withinRadius: Config.VenueSearch.SearchRadius, matchingString: string)
        } else {
            query = DataQueryProvider.venuesAround(location, withinRadius: Config.VenueSearch.SearchRadius)
        }
        
        query!.setLimit(Config.VenueSearch.VenuesPerPage)
        
        
        query!.executeInBackground({ (objects, error) -> () in
            completion(objects, error)
        })
    }
    
    fileprivate func searchZanaduVenuesWithString(_ string: String, andCompletionBlock completion: @escaping AVArrayResultBlock) {
        
        let   searchAVQuery = DataQueryProvider.queryForVenuesMatchingString(string)
      let   searchQuery = SimpleQuery(query: searchAVQuery) as? Query
        searchQuery!.setLimit(Config.VenueSearch.VenuesPerPage)
        
        searchQuery!.executeInBackground() { (objects, error) -> Void in
            completion(objects, error)
        }
    }
}
