//
//  DraftCategorys.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/6/30.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class DraftCategorys: NSObject ,NSCoding{
    //category
    var categoryObjectId: String
    var categoryName: String
    var categoryStatus : String
    
    override init() {
        
        categoryObjectId = ""
        categoryName = ""
        categoryStatus = "1"
        super.init()
    }
    
    required init  (coder aDecoder: NSCoder){
        
        categoryObjectId = aDecoder.decodeObject(forKey: "categoryObjectId") as! String
        categoryName = aDecoder.decodeObject(forKey: "categoryName") as! String
        categoryStatus = aDecoder.decodeObject(forKey: "categoryStatus") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(categoryObjectId, forKey: "categoryObjectId")
        aCoder.encode(categoryName, forKey: "categoryName")
        aCoder.encode(categoryStatus, forKey: "categoryStatus")
    }
    
    func createCategoryInfo(_ category : Category){
        if let objectId = category.objectId {
            categoryObjectId = objectId
        }
        if let name = category.name {
            categoryName = name
        }
        
        if let status = category.status {
            categoryStatus = String(describing: status)
        }
    }
}
