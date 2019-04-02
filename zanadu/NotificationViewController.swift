//
//  NotificationViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Display a list of notifications

Notifications can be tapped or deleted by a swipe to left gesture
*/
class NotificationViewController : BaseViewController {
    
    
    //MARK: - Properties
    var lastBadgeValue = 0
    
    //MARK: - Outlets

    weak var notificationStream: NotificationStreamView!
    
    
    //MARK: - Methods
    
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.title = NSLocalizedString("Notice", comment:"通知")
        notificationStream.contentInset = UIEdgeInsetsMake(Config.AppConf.navigationBarAndStatuesBarHeight, 0, 0, 0);
        notificationStream.backgroundColor = UIColor.clear
        notificationStream.selectionDelegate = self
        notificationStream.addLoadingView()
        let subscribedChannels = ZanNotificationCenter.sharedCenter.subscribedChannels()
        notificationStream.dataQuery = DataQueryProvider.lastNotificationsForChannels(subscribedChannels, andRecipient: User.current() as! User)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if User.current() == nil {
            return
        }
        
        let notificationCenter = ZanNotificationCenter.sharedCenter

        notificationCenter.badgeValueWithBlock { (value) -> () in
            self.lastBadgeValue = value
            notificationCenter.resetBadge()
            if let rootVc =  self.navigationController?.viewControllers.first as? MainTabBarController{
            let tabBar = rootVc.tabBar
            let item = tabBar.items![4]
            item.badgeValue = nil
            }

        }
    }
}

extension NotificationViewController: NotificationSelectionDelegate {

    func onNotificationSelected(_ notification: Notification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ZanNotificationCenter.redirectToTarget(notification, fromViewController:self)
    }
    
    func onAuthorSelected(_ author: User) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            vc.user = author
            navigationController?.pushViewController(vc, animated: true)
    }
}



