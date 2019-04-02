//
//  ListItem.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/14/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
ListItem
*/
class ListItem: AVObject, AVSubclassing {
    
    // MARK: - Properties
    
    @NSManaged
    var title: String?
    @NSManaged
    var text: String?
    @NSManaged
    var photos: AVRelation?
    @NSManaged
    var venue: Venue?
    @NSManaged
    var recommendation: Recommendation?
    @NSManaged
    var sort: NSNumber
    
    
    //MARK: - Methods
    
    //MARK: - AVSublassing Methods
    class func parseClassName() -> String! {
        return "ListItem"
    }
}
