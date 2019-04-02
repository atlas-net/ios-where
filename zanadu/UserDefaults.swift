//
//  UserPreferences.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
Reachability : test network connectivity
*/
class UserDefaults : NSObject {
    
    
    //MARK: - Class variables
    static let userDefaults: Foundation.UserDefaults = Foundation.UserDefaults(suiteName:Config.AppData.Group)!

    
    //MARK: - Public methods
    
    class func getAccessToken() -> String? {
        return objectForKey(Config.AppData.AuthData.AccessToken) as? String
    }
    
    class func setAccessToken(_ token:String) {
        saveObject(token as AnyObject, forkey: Config.AppData.AuthData.AccessToken)
    }
    
    class func getRefreshToken() -> String? {
        return objectForKey(Config.AppData.AuthData.RefreshToken) as? String
    }

    class func setRefreshToken(_ token:String) {
        saveObject(token as AnyObject, forkey: Config.AppData.AuthData.RefreshToken)
    }

    class func getOpenId() -> String? {
        return objectForKey(Config.AppData.AuthData.AccessToken) as? String
    }

    class func setOpenId(_ openid:String) {
        saveObject(openid as AnyObject, forkey: Config.AppData.AuthData.Openid)
    }

    class func populateWithWechatData(_ dict: [AnyHashable: Any]) {
        if let openid = dict["openid"] as? String {
            UserDefaults.setOpenId(openid)
        }
        if let accessToken = dict["access_token"] as? String {
            UserDefaults.setAccessToken(accessToken)
        }
        
        if let refreshToken = dict["refresh_token"] as? String {
            UserDefaults.setRefreshToken(refreshToken)
        }
    }

    class func populateWithWeiboData(_ dict: [AnyHashable: Any]) {
        if let openid = dict["id"] as? String {
            UserDefaults.setOpenId(openid)
        }
        if let accessToken = dict["access_token"] as? String {
            UserDefaults.setAccessToken(accessToken)
        }
    }
    
    //MARK: - Private methods
    
    /**
    Save object to UserDefaults
    
    - parameter object: The object to save
    - parameter key: The key to retrieve the value
    */
    fileprivate class func saveObject(_ object:AnyObject, forkey key:String) {
        userDefaults.set(object, forKey: key)
        userDefaults.synchronize()
    }
    
    /**
    Get object from UserDefaults
    
    - parameter key: The key to retrieve the value
    - returns: Optional AnyObject
    */
    fileprivate class func objectForKey(_ key:String) -> AnyObject? {
        return userDefaults.object(forKey: key) as AnyObject?
    }
}
