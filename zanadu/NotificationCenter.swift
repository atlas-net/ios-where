//
//  NotificationCenter.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



enum NotificationChannel: String {
    case likeOnMyRecommendation = "likeOnMyRecommendation"
    case commentOnMyRecommendation = "commentOnMyRecommendation"
    case recommendationInVenueIRecommended = "recommendationInVenueIRecommended"
    case promotedRecommendation = "promotedRecommendation"
    case newFollower = "newFollower"
    case replyToComment = "replyToComment"
    
    case appGeneral = "appGeneral"
    case appEvent = "appEvent"
    case appStatusChange = "appStatusChange"
    case pushRecommendationToUser = "PushRecommendationToUsers"
}

/**
Handles Push Notification related tasks

- Subscription to events
- Reception of Notifications
- Provide delegates for subscribing to handle notifications sent to a specific channel or all notifications received
*/
class ZanNotificationCenter {
    
    //MARK: - Properties
    
    
    lazy var installation : AVInstallation = {
        return AVInstallation.current()
    }()
    
    let channelsKey = "channels"
    let userKey = "user"
    
    static var sharedCenter = ZanNotificationCenter()
    //MARK: - Methods

    static func registerAppToLeanCloudNotificationService(_ app: UIApplication) {
//        let app = UIApplication.sharedApplication()
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
    
    func initWithToken(_ deviceToken:Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken) { (installation) in
            if let user = User.current() {
                installation.setObject(user, forKey: self.userKey)
            }
        }
        subscribeToChannel(.pushRecommendationToUser)
    }
    
    func registerUser(){
        if let user = User.current() {
            installation.setObject(user, forKey: self.userKey)
            installation.saveInBackground()
        }
    }
    
    func subscribeToChannel(_ channel: NotificationChannel) {
        installation.addUniqueObject(channel.rawValue, forKey: channelsKey)
        installation.saveInBackground()
    }
    
    func unsubscribeFromChannel(_ channel: NotificationChannel) {
        installation.remove(channel.rawValue, forKey: channelsKey)
        installation.saveInBackground()
    }
    
    func isSubscribedToChannel(_ channel: NotificationChannel) -> Bool {
        if let channels = installation.channels as? [String] {
            return channels.contains(channel.rawValue)
        }
        return false
    }
    
    func subscribedChannels() -> [NotificationChannel] {
        var channelArray = [NotificationChannel]()
        if let channels = installation.channels {
            for installationChannel in channels {
                if let channel = installationChannel as? String {
                    if let notification = NotificationChannel(rawValue:channel) {
                        channelArray.append(notification)
                    }
                }
            }
        }
        return channelArray
    }
    
    func badgeValueWithBlock(_ block: @escaping (Int) -> ()) {
        installation.fetchInBackground { (install, error) -> Void in
            if error != nil {
                log.error("fetch Installation : \(error?.localizedDescription)")
            } else if let install = install as? AVInstallation {
                block(install.badge)
            }
        }
    }
    
    func resetBadge() {
        installation.badge = 0
        installation.saveInBackground()
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    static func isChannelGlobal(_ channel:NotificationChannel) -> Bool {
        switch channel {
        case .appGeneral, .appEvent, .pushRecommendationToUser:
            return true
        case .appStatusChange, .likeOnMyRecommendation, .commentOnMyRecommendation, .recommendationInVenueIRecommended, .promotedRecommendation, .newFollower, .replyToComment:
            return false
        }
    }
    
    static func redirectToTarget(_ notification: Notification, fromViewController viewController: UIViewController) {
        if let channel = NotificationChannel(rawValue: notification.channel!) {

            switch channel {
            case .likeOnMyRecommendation,
                .commentOnMyRecommendation,
                .recommendationInVenueIRecommended,
                .replyToComment,
                .pushRecommendationToUser:
                if notification.targetType == Recommendation.parseClassName() {
                    if let id = notification.targetId {
                        DataQueryProvider.recommendationForObjectId(id).executeInBackground({ (object:Any?, error) -> () in
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            if error != nil {
                                log.error(error?.localizedDescription)
                            } else if let recommendation = object as? Recommendation {
                                Router.isFromNotification = true
                                Router.redirectToRecommendation(recommendation, fromViewController: viewController)
                            }
                        })
                    }
                    let recommendation = Recommendation(outDataWithObjectId: notification.targetId!)
                        
                        recommendation.fetchIfNeededInBackground({ (fetchedObject, error) -> Void in
                        
                        })
                }
                
            case .newFollower:
                if notification.targetType == "User" {
                    let user = User(outDataWithObjectId: notification.targetId!)
                    user.fetchInBackground({ (fetchedObject, error) -> Void in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else if let user = fetchedObject as? User {
                            Router.redirectToUser(user, fromViewController: viewController)
                        }
                    })
                }
            case .appGeneral, .appEvent:

                if let targetType = notification.targetType {



                    switch targetType {
                    case Recommendation.parseClassName():
                        let recommendation = Recommendation(outDataWithObjectId: notification.targetId!)
                        recommendation.fetchIfNeededInBackground({ (fetchedObject, error) -> Void in
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            if error != nil {
                                log.error(error?.localizedDescription)
                            } else if let recommendation = fetchedObject as? Recommendation {
                                Router.redirectToRecommendation(recommendation, fromViewController: viewController)
                            }
                        })
                    case User.parseClassName().replacingOccurrences(of: "_", with: ""):
                        let user = User(outDataWithObjectId: notification.targetId!)
                        user.fetchInBackground({ (fetchedObject, error) -> Void in
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            if error != nil {
                                log.error(error?.localizedDescription)
                            } else if let user = fetchedObject as? User {
                                Router.redirectToUser(user, fromViewController: viewController)
                            }
                        })
                    case Venue.parseClassName():
                            let venue = Venue(outDataWithObjectId: notification.targetId!)
                            venue.fetchInBackground({ (fetchedObject, error) -> Void in
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                if error != nil {
                                    log.error(error?.localizedDescription)
                                } else if let venue = fetchedObject as? Venue {
                                    Router.redirectToVenue(venue, fromViewController: viewController)
                                }
                            })
                        
//                    case Tag.parseClassName():
//                        if let tag = Tag(withoutDataWithObjectId: notification.targetId) {
//                            tag.fetchInBackgroundWithBlock({ (fetchedObject, error) -> Void in
//                                if error != nil {
//                                    log.error(error?.localizedDescription)
//                                } else if let tag = fetchedObject as? Tag {
//                                    Router.redirectToTag(tag, fromViewController: viewController)
//                                }
//                            })
//                        }
                    default:
                        return
                    }
                }
            case .appStatusChange: break
                
            case .promotedRecommendation: break
            }
        }
    }
    

}
