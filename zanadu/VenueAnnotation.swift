//
//  VenueAnnotation.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit

/**
VenueAnnotation


*/
class VenueAnnotation : NSObject, MKAnnotation {
    
    //MARK: - Properties
    
    var venue: Venue
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    //MARK: - Outlets

    

    //MARK: - Initializers
    
    init(venue: Venue, coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.venue = venue
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    
    //MARK: - Actions
    
    
    
    
    //MARK: - Methods
    
    
    
    
    //MARK: - ViewController's Lifecycle
}
