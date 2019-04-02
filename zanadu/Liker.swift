//
//  Liker.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/13/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



/**
Liker
*/
class Liker: AVObject, AVSubclassing {
    
    // MARK: - Variables
    
    @NSManaged
    var object: AVObject?
    @NSManaged
    var liker: User?
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(object: AVObject, liker: User) {
        super.init()
        self.object = object
        self.liker = liker
    }
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Liker"
    }
}
