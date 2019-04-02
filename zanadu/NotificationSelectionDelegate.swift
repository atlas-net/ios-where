//
//  NotificationSelectionDelegate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Protocol that receive Notification Cell events

You should implement the protocol's methods to handle notification cell events
*/
@objc protocol NotificationSelectionDelegate: class {
    
    /**
    Receive notification selection event
    
    - parameter Notification: the Notification object corresponding to the selected notification
    */
    func onNotificationSelected(_ notification: Notification)
    
    /**
    Receive notification Author selection event
    
    - parameter author: the User object corresponding to the event author
    */
    @objc optional func onAuthorSelected(_ author: User)
}
