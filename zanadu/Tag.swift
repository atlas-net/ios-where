//
//  Tag.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
Tag
*/
class Tag: AVObject, AVSubclassing {
    
    
    // MARK: - Variables
    @NSManaged
    var name: String!
    @NSManaged
    var popularity : NSNumber?
    @NSManaged
    var author: User!
    
    
    // MARK: - Initializers
//    
    override init() {
        super.init()
    }
    
    init(name: String, author: User) {
        super.init()
        self.name = name
        self.author = author
        self.popularity = 0
    }
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Tag"
    }
    
    
    //MARK: - Methods
    
    
    
}
