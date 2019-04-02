//
//  Invite.swift
//  Atlas
//
//  Created by yingyang on 16/4/26.
//  Copyright © 2016年 Atlas. All rights reserved.
//



/**
 Invite
 */
class Invite: AVObject, AVSubclassing {
    
    // MARK: - Properties
    @NSManaged
    var mail: String?
    @NSManaged
    var phoneNumber: String?
    @NSManaged
    var professional: String?
    
    //MARK: - Methods
    
    
    //MARK: - AVSublassing Methods
    class func parseClassName() -> String! {
        return "Invite"
    }
}
