//
//  Location.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/2/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import CoreLocation

/**
Location

contains the last known location
*/
class Location {
    
    //MARK: - Properties

    static var shared : CLLocation = CLLocation(latitude: 0, longitude: 0)
}
