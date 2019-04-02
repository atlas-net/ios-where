//
//  Ad.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
Ad
*/
class Ad: AVObject, AVSubclassing {
    
    // MARK: - Properties
    @NSManaged
    var author: User?
    @NSManaged
    var title: String?
    @NSManaged
    var subtitle: String?
    @NSManaged
    var image: AVFile?
    @NSManaged
    var type: NSNumber?
    @NSManaged
    var recommendation: Recommendation?
    @NSManaged
    var link: String?
    @NSManaged
    var order: NSNumber?

    
    //MARK: - Methods
    
    
    //MARK: - AVSublassing Methods
    class func parseClassName() -> String! {
        return "Ad"
    }
}
