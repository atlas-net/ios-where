//
//  SettingsNotificationsViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/4/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
SettingNotificationViewController

Notification channels subscription
*/
class SettingNotificationViewController : FormViewController {
    
    //MARK: - Properties
    
    lazy var newLikeSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Liked", comment: "获赞"))
        instance.value = notificationCenter.isSubscribedToChannel(.likeOnMyRecommendation)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.likeOnMyRecommendation)
            } else {
                notificationCenter.unsubscribeFromChannel(.likeOnMyRecommendation)
            }
        }
        return instance
        }()

    lazy var newCommentSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Comment", comment: "评论"))
        instance.value = notificationCenter.isSubscribedToChannel(.commentOnMyRecommendation) && notificationCenter.isSubscribedToChannel(.replyToComment)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.commentOnMyRecommendation)
                notificationCenter.subscribeToChannel(.replyToComment)
            } else {
                notificationCenter.unsubscribeFromChannel(.commentOnMyRecommendation)
                notificationCenter.unsubscribeFromChannel(.replyToComment)
            }
        }
        return instance
        }()
    
    lazy var newFollowerSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Attention", comment: "关注"))
        instance.value = notificationCenter.isSubscribedToChannel(.newFollower)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.newFollower)
            } else {
                notificationCenter.unsubscribeFromChannel(.newFollower)
            }
        }
        return instance
        }()
    
    lazy var newRecommendationInVenueSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Location dynamics", comment: "地点动态"))
        instance.value = notificationCenter.isSubscribedToChannel(.recommendationInVenueIRecommended)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.recommendationInVenueIRecommended)
            } else {
                notificationCenter.unsubscribeFromChannel(.recommendationInVenueIRecommended)
            }
        }
        return instance
        }()

    lazy var promotedRecommendationSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Recommend", comment:"推荐"))
        instance.value = notificationCenter.isSubscribedToChannel(.promotedRecommendation)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.promotedRecommendation)
            } else {
                notificationCenter.unsubscribeFromChannel(.promotedRecommendation)
            }
        }
        return instance
        }()

    lazy var appGeneralSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Notice", comment:"通知"))
        instance.value = notificationCenter.isSubscribedToChannel(.appGeneral)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.appGeneral)
            } else {
                notificationCenter.unsubscribeFromChannel(.appGeneral)
            }
        }
        return instance
        }()

    lazy var appEventSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Activity", comment:"活动"))
        instance.value = notificationCenter.isSubscribedToChannel(.appEvent)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.appEvent)
            } else {
                notificationCenter.unsubscribeFromChannel(.appEvent)
            }
        }
        return instance
        }()

    lazy var appStatusSwitch: SwitchFormItem = {
        let notificationCenter = ZanNotificationCenter.sharedCenter
        let instance = SwitchFormItem()
        instance.title(NSLocalizedString("Updated", comment:"更新"))
        instance.value = notificationCenter.isSubscribedToChannel(.appStatusChange)
        instance.onValueChanged = { () in
            if instance.value {
                notificationCenter.subscribeToChannel(.appStatusChange)
            } else {
                notificationCenter.unsubscribeFromChannel(.appStatusChange)
            }
        }
        return instance
        }()

    
    //MARK: - Outlets
    
    //MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = NSLocalizedString("Message notification", comment:"消息提醒")
    }
    //MARK: - Actions
    
    //MARK: - Methods
    
    override internal func populate(_ builder: FormBuilder) {

        builder += SectionHeaderTitleFormItem().title(NSLocalizedString("Message notification", comment:"消息提醒"))
        builder += newLikeSwitch
        builder += newCommentSwitch
        builder += newFollowerSwitch
        builder += newRecommendationInVenueSwitch
        builder += promotedRecommendationSwitch
        builder += appGeneralSwitch
        builder += appEventSwitch
        builder += appStatusSwitch
    }

    
    //MARK: - ViewController's Lifecycle
}
