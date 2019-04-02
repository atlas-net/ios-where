//
//  DraftRecommendationVenue.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/6/30.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class DraftRecommendationVenue: NSObject ,NSCoding{
    
    var recommendationTitle:String
    var recommendationText:String
    
    //venue
    var venueCustomName: String
    var venueCustomAddress: String
    var venuePhone: String
    var venuePlaceName: String
    var venueCountryCode: String
    var venueCountryName: String
    var venueAdministrativeArea: String
    var venueLocality: String
    var venueSublocality: String
    var venueThoroughfare: String
    var venueSubthoroughfare: String
    var venueFullAddress: String
    var venueCoordinate: CGPoint
    var venuePopularity: Int32
    
    
    override init() {
        recommendationTitle = ""
        recommendationText = ""
        
        venueCustomName = ""
        venueCustomAddress = ""
        venuePhone = ""
        venuePlaceName = ""
        venueCountryCode = ""
        venueCountryName = ""
        venueAdministrativeArea = ""
        venueLocality = ""
        venueSublocality = ""
        venueThoroughfare = ""
        venueSubthoroughfare = ""
        venueFullAddress = ""
        venueCoordinate = CGPoint.zero
        venuePopularity = 0
        
        super.init()
    }
    
    required init  (coder aDecoder: NSCoder){
        
        
        recommendationTitle=aDecoder.decodeObject(forKey: "recommendationTitle") as! String
        recommendationText=aDecoder.decodeObject(forKey: "recommendationText") as! String
        
        venueCustomName=aDecoder.decodeObject(forKey: "venueCustomName") as! String
        venueCustomAddress=aDecoder.decodeObject(forKey: "venueCustomAddress") as! String
        venuePhone=aDecoder.decodeObject(forKey: "venuePhone") as! String
        venuePlaceName=aDecoder.decodeObject(forKey: "venuePlaceName") as! String
        venueCountryCode=aDecoder.decodeObject(forKey: "venueCountryCode") as! String
        venueCountryName=aDecoder.decodeObject(forKey: "venueCountryName") as! String
        venueAdministrativeArea=aDecoder.decodeObject(forKey: "venueAdministrativeArea") as! String
        venueLocality=aDecoder.decodeObject(forKey: "venueLocality") as! String
        venueSublocality=aDecoder.decodeObject(forKey: "venueSublocality") as! String
        venueThoroughfare=aDecoder.decodeObject(forKey: "venueThoroughfare") as! String
        venueSubthoroughfare=aDecoder.decodeObject(forKey: "venueSubthoroughfare") as! String
        venueFullAddress=aDecoder.decodeObject(forKey: "venueFullAddress") as! String
        venueCoordinate=aDecoder.decodeCGPoint(forKey: "venueCoordinate")
        venuePopularity=aDecoder.decodeCInt(forKey: "venuePopularity")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder){
        
        //venue
        aCoder.encode(venueCoordinate, forKey: "venueCoordinate")
        aCoder.encode(venueCustomName, forKey: "venueCustomName")
        aCoder.encode(venueCustomAddress, forKey: "venueCustomAddress")
        aCoder.encode(venuePhone, forKey: "venuePhone")
        aCoder.encode(venuePlaceName, forKey: "venuePlaceName")
        aCoder.encode(venueCountryCode, forKey: "venueCountryCode")
        aCoder.encode(venueCountryName, forKey: "venueCountryName")
        aCoder.encode(venueAdministrativeArea, forKey: "venueAdministrativeArea")
        aCoder.encode(venueLocality, forKey: "venueLocality")
        aCoder.encode(venueSublocality, forKey: "venueSublocality")
        aCoder.encode(venueThoroughfare, forKey: "venueThoroughfare")
        aCoder.encode(venueSubthoroughfare, forKey: "venueSubthoroughfare")
        aCoder.encode(venueFullAddress, forKey: "venueFullAddress")
        aCoder.encode(venuePopularity, forKey: "venuePopularity")
        
        aCoder.encode(recommendationTitle, forKey: "recommendationTitle")
        aCoder.encode(recommendationText, forKey: "recommendationText")

    }
    
    func createVenueRecommendationInfo(_ venue : Venue){

        venueCustomName = venue.customName!
        if let customAddress =  venue.customAddress{
            venueCustomAddress = customAddress
        }
        if let customAddress =  venue.phone{
            venueCustomAddress = customAddress
        }
        if let phone =  venue.phone{
            venuePhone = phone
        }
        if let placeName =  venue.placeName{
            venuePlaceName = placeName
        }
        if let countryCode =  venue.countryCode{
            venueCountryCode = countryCode
        }
        if let countryName =  venue.countryName{
            venueCountryName = countryName
        }
        if let administrativeArea =  venue.administrativeArea{
            venueAdministrativeArea = administrativeArea
        }
        if let locality =  venue.locality{
            venueLocality = locality
        }
        if let sublocality =  venue.sublocality{
            venueSublocality = sublocality
        }
        if let subthoroughfare =  venue.subthoroughfare{
            venueSubthoroughfare = subthoroughfare
        }
        if let fullAddress =  venue.fullAddress{
            venueFullAddress = fullAddress
        }
        if let popularity =  venue.popularity{
            venuePopularity = Int32(popularity)
        }
        if let coordinate =  venue.coordinate{
            let  locationPoint = CGPoint(x: CGFloat(coordinate.latitude), y: CGFloat(coordinate.longitude))
            venueCoordinate = locationPoint
        }
    }
    func createRecommendationText(_ title : String,description:String) {

        recommendationTitle = title
        recommendationText = description
        
    }
   
}
