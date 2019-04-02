//
//  BaiduAPI.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 11/4/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import Alamofire
import SwiftyJSON


enum BaiduAPIUrlPath {
    case place
    case poi
}


/**
Baidu API
*/
class BaiduAPI {

    //MARK: - Methods
    
    static func poiListForLocation(_ location: CLLocation, radius: Int, page: Int = 0, completion: @escaping ([AnyObject]?, Error?) -> Void) {
        let params = [
            "query": Config.VenueSearch.QueryTags,
            "scope": "1",
            "page_size": "\(Config.VenueSearch.VenuesPerPage)",
            "page_num": "\(page)",
            "location": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "radius": "\(radius)",
            "output": "json",
            "mcode": Config.App.BundleId,
            "ak": Config.Baidu.Key
        ]

        Alamofire.request(Config.Baidu.PlaceSearchUrl, parameters: params).responseJSON { response in
            switch response.result {
            case .failure(let error):
                log.error("\(error)")
                completion(nil, error)
            case .success(let value):
                let json = JSON(value)
                let jsonRes = json["results"]
                let jsonSts = json["status"]
                let jsonMsg = json["message"]
                
                if jsonSts != 0 {
                    log.error("\(jsonMsg)")
                }
                



                
                completion(jsonRes.arrayObject as [AnyObject]?, nil)
            }
        }
    }
    
    static func poiListForSearchQuery(_ query: String, inRegion region: String = "全国", withLocation location: CLLocation? = nil, completion:@escaping ([AnyObject]?, Error?) -> Void) {
        self.poiListForQuery(query, inRegion: region, withLocation: location, completion: completion)
    }

    static func poiListForSuggestionQuery(_ query: String, inRegion region: String = "全国", withLocation location: CLLocation? = nil, completion:@escaping ([AnyObject]?, Error?) -> Void) {
        self.poiListForQuery(query, inRegion: region, withLocation: location, suggestion: true, completion: completion)
    }
    
    fileprivate static func poiListForQuery(_ query: String, inRegion region: String = "全国", withLocation location: CLLocation? = nil, suggestion: Bool = false, completion: @escaping ([AnyObject]?, Error?) -> Void) {
        
        let url = suggestion ? Config.Baidu.PlaceSuggestionUrl : Config.Baidu.PlaceSearchUrl
        
        var params = [
            "query": query,
            "region": region,
            "output": "json",
            "mcode": Config.App.BundleId,
            "ak": Config.Baidu.Key,
        ]
        
        if let location = location {
            params["location"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        
        Alamofire.request(url, parameters: params).responseJSON { response in
            switch response.result {
            case .failure(let error):
                log.error("\(error)")
                completion(nil, error)
            case .success(let value):
                let json = JSON(value)
                let jsonRes = json["result"]
                let jsonSts = json["status"]
                let jsonMsg = json["message"]



                
                completion(jsonRes.arrayObject as [AnyObject]?, nil)
            }
        }
    }

    /**
    Get an address from GPS coordinate
    
    CLLocationCoordinate2D uses WGS84 coordinate
    
    - parameter location:    GPS coordinate
    - parameter includePois: returns POIs around the location (within a 100m radius)
    - parameter completion:  callback
    */
    static func addressForLocation(_ location: CLLocation, withPois includePois: Bool = false, completion:@escaping (AnyObject?, Error?) -> Void) {
        let params: [String:String] = [
            "coordtype": "wgs84ll",
            "location": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "pois": includePois ? "1" : "0",
            "output": "json",
            "mcode": Config.App.BundleId,
            "ak": Config.Baidu.Key
        ]

        
        Alamofire.request(Config.Baidu.GeocodingBaseUrl, parameters: params).responseJSON { response in
            switch response.result {
            case .failure(let error):
                log.error("\(error)")
                completion(nil, error)
            case .success(let value):
                let json = JSON(value)
                let jsonRes = json["result"]
                let jsonSts = json["status"]


                completion(nil, nil)
            }
        }
    }
}
