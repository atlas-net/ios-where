//
//  LocalRecentTagsHandler.swift
//  Atlas
//
//  Created by yingyang on 16/3/28.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
class LocalRecentTagsHandler: NSObject {
    
    var tagIds = [String]()
    
    
    func addTagId(_ tagId:String){
        // add tag
        if let objects = UserDefaults.userDefaults.object(forKey: Config.locals.RecentTagIds){
            tagIds = objects as! [String]
            // check repeat
            for (index,strId) in tagIds.enumerated(){
                if strId == tagId{
                    tagIds.remove(at: index)
                    tagIds.insert(tagId, at: 0)
                    UserDefaults.userDefaults.set(tagIds, forKey: Config.locals.RecentTagIds)
                    return
                }
            }
            //  update tag
            if tagIds.count == 8{
                tagIds.removeLast()
                tagIds.insert(tagId, at: 0)
                UserDefaults.userDefaults.set(tagIds, forKey: Config.locals.RecentTagIds)
            }else{
                tagIds.insert(tagId, at: 0)
                UserDefaults.userDefaults.set(tagIds, forKey: Config.locals.RecentTagIds)
            }
        }else{
            tagIds.append(tagId)
            UserDefaults.userDefaults.set(tagIds, forKey: Config.locals.RecentTagIds)
        }
    }
    func getTagIds() -> [String]?{
        //   fetch tag from local
        var tagIds = [String]()
        if let objects = UserDefaults.userDefaults.object(forKey: Config.locals.RecentTagIds){
            tagIds = objects as! [String]
        }
        return tagIds
    }
    func addTagIdsWithTags(_ tags: [Tag]){
        
        if tags.count == 0 { return}
        for tag in tags{
            addTagId(tag.objectId!)
        }
    }

}
