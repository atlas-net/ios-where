//
//  DraftTags.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/6/30.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class DraftTags: NSObject,NSCoding {
    //tag
    var tagName: String
    var tagPopularity : String
    override init() {
        
        tagName = ""
        tagPopularity = "1"
        super.init()
    }
    
    required init  (coder aDecoder: NSCoder){
        
        tagName = aDecoder.decodeObject(forKey: "tagName") as! String
        tagPopularity = aDecoder.decodeObject(forKey: "tagPopularity") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(tagName, forKey: "tagName")
        aCoder.encode(tagPopularity, forKey: "tagPopularity")
    }
    
    func createTagInfo(_ tag: Tag){
        if let name = tag.name {
            tagName = name
        }
        if let popularity = tag.popularity {
            tagPopularity = String(describing: popularity)
        }
    }
}
