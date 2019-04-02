//
//  UIApplication+FirstLaunch.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/23/16.
//  Copyright © 2016 Atlas. All rights reserved.
//


extension AppDelegate {
    
    /**
     Know if it's the first time the app is launched, thanks to NSUserDefaults
     
     - returns: false the first time it's called, and then always return true unless you reinstall the app
     */
    class func isFirstLaunch() -> Bool {
        // get current version
        let infoDictionary = Bundle.main.infoDictionary
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        
        // take the before version
        let userDefaults = Foundation.UserDefaults.standard
        let appVersion = userDefaults.string(forKey: "appVersion")
        
        if appVersion == nil || appVersion != currentAppVersion {
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")
            return true
        }else{
            return false
        }
    }
}
