//
//  BaiduVenueSearchData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 11/4/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



/**
BaiduVenueSearchData


*/
class BaiduVenueSearchData : VenueSearchData {
    
    //MARK: - Properties
    
    var venueAddress: VenueAddress


    //MARK: - Initializers

    init(baiduVenue venue:NSDictionary, score: Float, currentLocation: CLLocation?) {
        venueAddress = VenueAddress()
        
        if let venueAddress = venue["address"] as? String {
            self.venueAddress.formattedAddress = venueAddress
        }
        
        if let venueCity = venue["city"] as? String {
            venueAddress.city = venueCity
        }
        
        if let venueDistrict = venue["district"] as? String {
            venueAddress.district = venueDistrict
        }

        super.init(id: venue["uid"] as? String ?? "", score: score, name: (venue["name"] as! String) ?? "", address: venue["address"] as? String ?? "" )

        
        If: if let location = venue["location"] as? Dictionary<String, AnyObject>{
            guard let latitude = location["lat"] as? Double,
                let longitude = location["lng"] as? Double else {
                    break If
            }
            self.venueAddress.location = CLLocation(latitude: latitude, longitude: longitude)
            if let currentLocation = currentLocation {
                distance = (venueAddress.location?.distance(from: currentLocation))! / Double(1000)
            }
    
        }
        
        if let venuePhone = venue["telephone"] as? String {
            self.venueAddress.phone = venuePhone
            // remove parenthesis
            venueAddress.phone!.remove(at: venueAddress.phone!.characters.index(venueAddress.phone!.startIndex, offsetBy: 4))
            venueAddress.phone!.remove(at: venueAddress.phone!.startIndex)
        }
        
    }
    
    
    //MARK: - Methods
    
    func toVenue() -> Venue {
        let venue:Venue = Venue()
        venue.placeName = name
        venue.customName = name
        venue.fullAddress = address
        venue.customAddress = address

        if let location = venueAddress.location {
            venue.coordinate = AVGeoPoint(location: location)
        }
        
        if let phone = venueAddress.phone {
            venue.phone = phone
        }

        venue.countryCode = "CN"
        venue.countryName = "中国"
        
        if let venueCity = venueAddress.city {
            venue.locality = venueCity
        }
        
        if let venueDistrict = venueAddress.district {
            venue.sublocality = venueDistrict
        }
        
        return venue
    }
}
