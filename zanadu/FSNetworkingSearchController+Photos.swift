//
//  FSNetworkingSearchController+Photos.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

//import FSNetworkingSearchController

let FSNSCVenuesURLString: String = "https://api.foursquare.com/v2/venues/"
let FSNSCAPIPhotosPath: String = "photos"

extension FSNetworkingSearchController {
    
//    static func getPhotos(venueId:String, completion:((String?, NSError?) -> Void)?) {
//        let urlString:NSMutableString = NSMutableString(string: "\(FSNSCVenuesURLString)\(venueId)/\(FSNSCAPIPhotosPath)")
//        FSNetworkingSearchController.authorizeMutableURLString(urlString)
//        urlString.appendString("&limit=1")
//        print(urlString, terminator: "")
//        
//        let url: NSURL = NSURL(string: urlString as String)!
//        let communicator: FSNetworkingCommunicatorProtocol = FSNetworkingSearchController.sharedController().communicator as FSNetworkingCommunicatorProtocol
//        
//        let block: FSNCompletionBlock = {(connection) in
//            if completion != nil {
//                
//                
//                if let results = (connection as FSNConnection).parseResult {
//                    if let response = (results as! NSDictionary)["response"] as? NSDictionary {
//                        
//                        let photos = (response["photos"] as! NSDictionary)
//                        
//                        print("IMG URL RESPONSE", terminator: "")
//                        
//                        if photos["count"] as! Int == 1 {
//                            
//                            let item = (photos["items"] as! NSArray)[0] as! NSDictionary
//                            var prefix = item["prefix"] as! String
//                            prefix.removeAtIndex(prefix.startIndex.advancedBy(4))
//                            let suffix = item["suffix"] as! String
//                            
//                            let url = "\(prefix)\(VSHImageSize.Size88.rawValue)\(suffix)"
//                            print(url, terminator: "")
//                            
//                            completion!(url, nil)
//                        }
//                        completion!(nil, nil)
//                    }
//                }
//                completion!(nil, nil)
//            }
//            return
//        }
//        communicator.startWithUrl(url as NSURL!, completionBlock: block)
//    }
}
