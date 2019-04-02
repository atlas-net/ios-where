//
//  Venue.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import CoreLocation

/**
Venue
*/
class Venue: AVObject, AVSubclassing {

    
    // MARK: - Custom Properties
    @NSManaged
    var id: String?
    @NSManaged
    var customName: String?
    @NSManaged
    var customAddress: String?
    @NSManaged
    var phone: String?
    

    // MARK: - Placemark Properties
    
    @NSManaged
    var placeName: String?
    @NSManaged
    var countryCode: String?
    @NSManaged
    var countryName: String?
    @NSManaged
    var administrativeArea: String?
    @NSManaged
    var locality: String?
    @NSManaged
    var sublocality: String?
    @NSManaged
    var thoroughfare: String?
    @NSManaged
    var subthoroughfare: String?
    @NSManaged
    var fullAddress: String?
    @NSManaged
    var coordinate: AVGeoPoint?
    
    @NSManaged
    var category: AVRelation?
    // TODO: add author
    
    
    // MARK: Computed properties
    
    var popularity: Int?

    
    // MARK: - Initializers
    

    convenience  init(name:String, address:String, location:CLLocation ) {
        self.init()
        self.placeName = name
        self.customName = name
        self.fullAddress = address
        self.customAddress = address
        self.coordinate = AVGeoPoint(location: location)
    }
    // MARK: - Methods
    
    func updateWithPlacemark(_ placemark: CLPlacemark) {
        placeName = placemark.name
        countryCode = placemark.isoCountryCode
        countryName = placemark.country
        administrativeArea = placemark.administrativeArea
        locality = placemark.locality
        sublocality = placemark.subLocality
        thoroughfare = placemark.thoroughfare
        subthoroughfare = placemark.subThoroughfare
        coordinate = AVGeoPoint(location: placemark.location!)

        if let formated = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
            if self.countryCode == "CN" {
                fullAddress = formated[0]
            } else {
                fullAddress = ""

                if placemark.subThoroughfare != nil {
                    fullAddress = placemark.subThoroughfare! + " "
                }
                if placemark.thoroughfare != nil {
                    fullAddress! += placemark.thoroughfare! + ", "
                }
                if placemark.postalCode != nil {
                    fullAddress! += placemark.postalCode! + ", "
                }
                if placemark.locality != nil {
                    fullAddress! += placemark.locality! + ", "
                }
                if placemark.administrativeArea != nil && placemark.administrativeArea != placemark.locality {
                    fullAddress! += placemark.administrativeArea! + ", "
                }
                if placemark.country != nil {
                    fullAddress! += placemark.country!
                }
            }
        }
    }
    
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Venue"
    }
    
    
}
