//
//  FoursquareVenueSearchData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



class LocationData {
    var countryCode: String? // cc
    var countryName: String? // country
    var coordinate: CLLocation? // lat + lon
    var administrativeArea: String? // state
    var locality:String?   // city
}

class FoursquareVenueSearchData: VenueSearchData {
    
    var locationData: LocationData?
    
    init(foursquareVenue venue:NSDictionary, score: Float) {
        let addr: String?
        if let tmpAddress = (venue["location"] as! NSDictionary)["address"] as? String {
            addr = tmpAddress
        } else if let tmpAddress = ((venue["location"] as! NSDictionary)["formattedAddress"] as? NSArray) {
            addr = tmpAddress[0] as? String
        } else if let tmpAddress = ((venue["location"] as! NSDictionary)["crossStreet"] as? String) {
            addr = tmpAddress
        } else {
            addr = ""
        }
        
        super.init(id: venue["id"] as! String,
            score: score,
            name: (venue["name"] as! String),
            address: addr!)
        self.distance = Double((venue["location"] as! NSDictionary)["distance"] as! Int) / 1000.0
        
        if let stats = (venue["stats"] as? NSDictionary) {
            if let popularity = stats["checkinsCount"] as? Int {
                self.popularity = popularity
            } else {
                self.popularity = 0
            }
        } else {
            self.popularity = 0
        }
        
        // populate the additional data
        if let location = venue["location"] as? NSDictionary {
            self.locationData = LocationData()

            if let cc = location["cc"] as? String {
                self.locationData?.countryCode = cc
            }
            if let country = location["country"] as? String {
                self.locationData?.countryName = country
            }
            if let state = location["state"] as? String {
                self.locationData?.administrativeArea = state
            }
            if let city = location["city"] as? String {
                self.locationData?.locality = city
            }
            if let lat = location["lat"] as?  Double {
                if let lon = location["lng"] as?  Double {
                    self.locationData?.coordinate = CLLocation(latitude: lat, longitude: lon)
                } else {
                    print("no coordinate lon", terminator: "")
                }
            } else {
                print("no coordinate lat", terminator: "")
            }
        }
    }
    
    func toVenue() -> Venue {
        let venue:Venue = Venue()
        venue.placeName = name
        venue.customName = name
        venue.fullAddress = address
        venue.customAddress = address
        venue.id = self.id

        if let locationData = locationData {
            venue.countryCode = locationData.countryCode
            venue.countryName = locationData.countryName
            venue.administrativeArea = locationData.administrativeArea
            venue.locality = locationData.locality
            if let coordinate = locationData.coordinate {
                venue.coordinate = AVGeoPoint(location: coordinate)
            }
        }
        return venue
    }
}
