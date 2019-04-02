//
//  SectionItem.swift
//  Atlas
//
//  Created by yingyang on 16/6/3.
//  Copyright © 2016年 Atlas. All rights reserved.
//


class SectionItem: AVObject {
    
    @NSManaged
    var recommendation: Recommendation?
    @NSManaged
    var section: Section?
    
    class func parseClassName() -> String! {
        return "SectionItem"
    }
    
}
