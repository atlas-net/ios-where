//
//  Comment.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/20/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
Comment
*/
class Comment: AVObject, AVSubclassing {
    
    // MARK: - Variables
    
    @NSManaged
    var text: String?

    @NSManaged
    var author: User?
    
    @NSManaged
    var recommendation: Recommendation?
    
    @NSManaged
    var responseAuthor: User?

    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(text: String, author: User, recommendation: Recommendation) {
        super.init()
        self.text = text
        self.author = author
        self.recommendation = recommendation
    }
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Comment"
    }
}
