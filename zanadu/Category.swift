//
//  Category.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/5/19.
//  Copyright © 2016年 Atlas. All rights reserved.
//



class Category: AVObject ,AVSubclassing{
    // MARK: - Variables
    @NSManaged
    var name: String!
    @NSManaged
    var status : NSNumber?
    
    
    // MARK: - Initializers
    //
    override init() {
        super.init()
    }
    
    init(name: String, status: NSNumber) {
        super.init()
        self.name = name
        self.status = status


    }
    
    
    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Category"
    }
    
    
    //MARK: - Methods
    

}

class SubCategory: Category {
    var isSelected : Bool?
    // MARK: - Initializers
    //
    override init() {
        super.init()
    }
    
    override init(name: String, status: NSNumber) {
        super.init()
        self.name = name
        self.status = status
        self.isSelected = false
//
    }

}
