//
//  BaseViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/11/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit
import MBProgressHUD
enum NavigationBarStste {
    case collapsed
    case expanded
}

class BaseViewController: UIViewController {
    let statusBarHeight : CGFloat = 20.0
    var baseScrollView:UIScrollView?
    var lastContentOffset:CGFloat = 0
    var navigationBarState: NavigationBarStste = .expanded
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    func applicationDidBecomeActive() {
        ZanNotificationCenter.sharedCenter.badgeValueWithBlock { (value) -> () in
            if let tabBarController = self.tabBarController as? MainTabBarController {
                tabBarController.onBadgeValueChanged(value)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Foundation.NotificationCenter.default.removeObserver(self)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    
    func closeView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func showBasicAlertWithTitle(_ title:String){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: title, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showBasicHudWithTitle(_ title:String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.labelText = title
        hud.hide(true, afterDelay: 1.0)
    }
}

extension BaseViewController:UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
