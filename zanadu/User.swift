//
//  User.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/20/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import SwiftyJSON

enum UserStatus: Int {
    case disabled = 0
    case registered = 1
    case chosenTribes = 2
}

/**
User model (LeanCloud Object)
*/
class User: AVUser {

    //MARK: - Properties
    
    @NSManaged
    var openId: String?
    @NSManaged
    var unionId: String?
    @NSManaged
    var nickname: String?
    @NSManaged
    var message: String?
    @NSManaged
    var country: String?
    @NSManaged
    var province: String?
    @NSManaged
    var city: String?
    @NSManaged
    var language: String?
    @NSManaged
    var headImgUrl: String?
    @NSManaged
    var sex: NSNumber?
    @NSManaged
    var avatar: Photo?
    @NSManaged
    var cover: Photo?
    @NSManaged
    var technicalData: TechnicalData?
    @NSManaged
    var lastLoginTime: Date?
    @NSManaged
    var likes: AVRelation?
    
    
    func populateWithWechatData(_ dict: JSON) {
        unionId = dict["unionid"].stringValue
        nickname = dict["nickname"].stringValue
        country = dict["country"].stringValue
        province = dict["province"].stringValue
        city = dict["city"].stringValue
        language = dict["language"].stringValue
        headImgUrl = dict["headimgurl"].stringValue
        sex = dict["sex"].intValue as NSNumber?
    }

    func populateWithWeiboData(_ dict: [AnyHashable: Any]) {
        if let id = dict["id"] as? String {
            unionId = id
        }
        
        if let username = dict["username"] as? String {
            nickname = username
        }
        
        if let userDict = dict["raw-user"] as? [AnyHashable: Any]{
            if let lang = userDict["lang"] as? String {
                language = lang
            }

            if let avatar = userDict["avatar_hd"] as? String {
                headImgUrl = avatar
            }
            
            if let locationDict = (userDict["location"] as? String)?.characters.split(separator: " ") {
                if locationDict.count > 0 {
                    province = String(locationDict[0])
                }
                if locationDict.count > 1 {
                    city = String(locationDict[1])
                }
            }
            
            if let userSex = userDict["gender"] as? String {
                if userSex == "m" {
                    sex = 1
                } else if userSex == "f" {
                    sex = 2
                }
            }

        }
    }
    
    
    /**
     like
     
     - parameter object:     the AVObject to like (due to Leancloud typing it only works with Recommendation)
     - parameter completion: the completion function has a Boolean param. if user is liking => true, else => false
     */
    func like(_ object: AVObject, completion: @escaping (Bool) -> ()) {

        
        isLiking(object) { (liking) -> () in

            if !liking {
                let like = Like(user: self, like: object)
                like.saveInBackground({ (saved, error) -> Void in
                    completion(saved)
                })
            } else {
                completion(true)
            }
        }
    }
    
    /**
     unlike
     
     - parameter object:     the AVObject to unlike (due to Leancloud typing it only works with Recommendation)
     - parameter completion: the completion function has a Boolean param. if user is not liking => true, else => false
     */
    func unlike(_ object: AVObject, completion: @escaping (Bool) -> ()) {

        
        isLiking(object) { (liking) -> () in

            if liking {
                let likingQuery = AVQuery(className: "Like")
                likingQuery.whereKey("user", equalTo: self)
                likingQuery.whereKey("like", equalTo: object)
                likingQuery.deleteAllInBackground({ (deleted, error) -> Void in
                    completion(deleted)
                })
            } else {
                completion(true)
            }
        }
    }
    
    /**
     isLiking
     
     - parameter object:     the AVObject to unlike (due to Leancloud typing it only works with Recommendation)
     - parameter completion: the completion function has a Boolean param. if user is liking => true, else => false
     */
    func isLiking(_ object: AVObject, completion: @escaping (Bool) -> ()) {

        let likingQuery = AVQuery(className: "Like")
        likingQuery.whereKey("user", equalTo: self)
        likingQuery.whereKey("like", equalTo: object)
        likingQuery.countObjectsInBackground { (count, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                completion(count > 0)
            }
        }
    }
}
