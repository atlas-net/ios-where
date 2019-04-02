//
//  AppDelegate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit

import XCGLogger
import SwiftLocation
import CoreLocation
import Fabric
import Crashlytics
import IQKeyboardManagerSwift


let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - Variables

    var window: UIWindow?

    var tmpObject: AnyObject?

    var location: CLLocation?

    weak var navigationController: NavigationController?
    
      var remoteNotificationUserInfo : Notification?
    
    //MARK: - Application Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        let tabController = self.navigationController?.visibleViewController as? MainTabBarController
        tabController?.tabBarOriginalHeight
        // XCGLogger init
        if DEVELOPMENT {
            log.setup(level: .verbose, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: nil)
        } else {
            log.setup(level: .error, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: nil)
        }

        Fabric.with([Crashlytics.self])
        let locationManager = LocationManager.sharedInstance
        locationManager.showVerboseMessage = true
        locationManager.autoUpdate = true

        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) -> () in
            Location.shared = CLLocation(latitude: latitude, longitude: longitude)
        }
        AVOSCloud.setAllLogsEnabled(false)
        User.registerSubclass()
        Recommendation.registerSubclass()
        Venue.registerSubclass()
        Photo.registerSubclass()
        Tag.registerSubclass()
        Like.registerSubclass()
        Liker.registerSubclass()
        Comment.registerSubclass()
        Ad.registerSubclass()
        Search.registerSubclass()
        SearchPopularity.registerSubclass()
        Notification.registerSubclass()
        Section.registerSubclass()
        ListItem.registerSubclass()
        TechnicalData.registerSubclass()
        Report.registerSubclass()
        Invite.registerSubclass()
        InviteCode.registerSubclass()
        Category.registerSubclass()
        SectionItem.registerSubclass()

        if !DEVELOPMENT{
            AVOSCloud.setApplicationId(Config.AVOSCloud.AVOSAppID, clientKey: Config.AVOSCloud.AVOSAppKey)
        }else{
            //AVOSCloud.setApplicationId(Config.AVOSCloud.AVOSAppID_Dev, clientKey: Config.AVOSCloud.AVOSAppKey_Dev)
            AVOSCloud.setApplicationId(Config.AVOSCloud.AVOSAppID, clientKey: Config.AVOSCloud.AVOSAppKey)
        }
        
        if DEVELOPMENT {
            AVCloud.setProductionMode(false)
        }
 
        // Weixin init
        WXApi.registerApp(Config.Weixin.WXAppID)


        // Foursquare search API init
            FSNetworkingSearchController.configure(withClientID: "41S3Z535ROMBR4IBDAPHFX5CKZ0AQAVL4VDANCYJRYHVDKKZ", clientSecret: "LG200JKI5J5SHVZDUFSGZ2F5H1FODQEHCXCPPVCRIK4D5BBS", redirectURI: "fsnetworkingsearchcontroller://foursquare")
        
        // Tracking : app opened
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        
        // Register to Push Notifications
       // NotificationCenter.registerAppToLeanCloudNotificationService(application)
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        AVOSCloudSNS.setupPlatform(AVOSCloudSNSType.snsWeiXin,
            withAppKey: Config.Weixin.WXAppID,
            andAppSecret: Config.Weixin.WXAppSecret,
            andRedirectURI: "")
        AVOSCloudSNS.setupPlatform(AVOSCloudSNSType.snsSinaWeibo,
            withAppKey: Config.SinaWeibo.SWAppID,
            andAppSecret: Config.SinaWeibo.SWAppSecret,
            andRedirectURI: Config.SinaWeibo.redirectUrl)
        
        
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.removeObject(forKey: "onceShown")
        userDefaults.synchronize()
        
        IQKeyboardManager.shared.enable = true
        AVCloud.setProductionMode(true)
        return true
    }
    

    
    /**
    Likes on your own posts
    Comments on your own posts
    Replies to your comments
    General app notifications (e.g. user became an expert, download new version of app, new mission waiting for you)
    New posts by ppl you’re following
    Someone’s following you
    Somebody posted an article about a venue you posted on.
    
    News
    */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

//TODO: first launch only
        
        let notificationCenter = ZanNotificationCenter.sharedCenter
        notificationCenter.initWithToken(deviceToken)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get token, error: %@", error);
    }

    
    // MARK: - WeiXin Url Handlers

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("url1", terminator: "")
//        return WXApi.handleOpenURL(url, delegate: WeixinApi.instance)
        return AVOSCloudSNS.handleOpen(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {

        
        //
        FSNetworkingSearchController.handleOpen(url)
  //      return WXApi.handleOpenURL(url, delegate: WeixinApi.instance)
        return AVOSCloudSNS.handleOpen(url)
    }
     
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication:
//        String?, annotation: AnyObject) -> Bool {
//    }

    //MARK: - Notification Handler
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {


        let notificationModel = Notification()
        notificationModel.targetType = "notificationInfo"
        self.remoteNotificationUserInfo = notificationModel
        let state = application.applicationState
        if state == UIApplicationState.inactive || state == UIApplicationState.background {
            pushToOneController(notificationModel)
        } else {
            // App is in UIApplicationStateActive
            let notificationCenter = ZanNotificationCenter()
            notificationCenter.badgeValueWithBlock({ (value) -> () in
                application.applicationIconBadgeNumber = value
                if let navigationController = self.navigationController {
                    if let tabController = navigationController.visibleViewController as? MainTabBarController {
                        tabController.onBadgeValueChanged(value)
//                        self.pushToOneController(notificationModel)

                    }
                }
            })
        }
    }

    func pushToOneController(_ userInfo:Notification) {
        
        if let navigationController = self.navigationController {
            if userInfo.targetType == "notificationInfo"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
                navigationController.pushViewController(vc, animated: true)
            }else{
                let vc = UIViewController()
                navigationController.pushViewController(vc, animated: true)
            }
        }

    }
    
}
//
//if let welcomeVc = self.window?.rootViewController  as? WelcomeViewController{
//    if let navVc = welcomeVc.toPresentVc as! NavigationController{
//        navigationController
//    }
//}
