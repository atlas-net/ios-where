//
//  ZanaduVenueSearchData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



class ZanaduVenueSearchData: VenueSearchData {
    
    //TODO: add a global locationProvider
    init(venue: Venue, score: Float, currentLocation: CLLocation?) {
        super.init(id: venue.objectId!, score: score, name: venue.customName!, address: venue.customAddress!)
        venue.fetchIfNeeded()
        if let currentLocation = currentLocation {
            self.distance = venue.coordinate?.distanceInKilometers(to: AVGeoPoint(location: currentLocation))
        } else {
            self.distance = Double.infinity
        }
        self.popularity = venue.popularity
    }
}
