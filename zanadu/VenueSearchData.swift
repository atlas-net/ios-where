//
//  VenueCellData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


class VenueSearchData : NSObject {
    
    
    // MARK - Properties
    
    var id: String
    var name: String
    var address: String
    var distance: Double?
    var popularity:Int?
    var score: Float


    // MARK - Initializers

    init(id: String, score: Float, name: String, address: String) {
        self.id = id
        self.score = score
        self.name = name
        self.address = address
    }

    init(id: String, score: Float, name: String, address: String, distance: Double, popularity: Int) {
        self.id = id
        self.score = score
        self.name = name
        self.address = address
        self.distance = distance
        self.popularity = popularity
    }
    
    /**
     Score the venue search entry depending on given parameters
     
     - parameter source: the data source (Where, Baidu, Foursquare...)
     - parameter type:   the type of search (around User, Global...)
     - parameter rank:   the place of the item in API's results (1st, 3rd, 26th...)
     
     - returns: The score given by the formula
     */
    static func calculateScore(_ source: SearchDataSource, type: SearchDataType, rank: Int) -> Float {
        return Config.VenueSearch.scoreMatrix[source]![type]! * 1 / Float(rank + 1) * 3
    }
}
