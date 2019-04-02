//
//  Like.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/13/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



/**
Like
*/
class Like: AVObject, AVSubclassing {
    
    // MARK: - Variables
    
    @NSManaged
    var user: User?
    
    @NSManaged
    var like: AVObject?
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(user: User, like: AVObject) {
        super.init()
        self.user = user
        self.like = like
    }
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Like"
    }
}
