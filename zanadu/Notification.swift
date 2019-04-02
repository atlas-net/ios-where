//
//  Notification.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
Notification
*/
class Notification: AVObject {

    // MARK: - Variables
    
    @NSManaged
    var title: String?
    
    @NSManaged
    var body: String?
    
    @NSManaged
    var author: User?

    @NSManaged
    var recipient: User?

    @NSManaged
    var channel: String?
    
    @NSManaged
    var targetType: String?
    
    @NSManaged
    var targetId: String?
    
    @NSManaged
    var file: AVFile?
 }

extension Notification: AVSubclassing {
    
    //MARK - Methods
    
    class func parseClassName() -> String! {
        return "Notification"
    }
}

extension Notification: Comparable {

}

func < (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.objectId! < rhs.objectId!
}

func == (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.objectId == rhs.objectId
}
