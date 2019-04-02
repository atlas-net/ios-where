//
//  MainTabBarController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Photos
import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MainTabBarController: CenterButtonTabBarController, CenterButtonTabBarControllerDelegate, UITabBarControllerDelegate {

    static let tabBarHeight: CGFloat = 0
    var tabBarOriginalHeight: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBar.layer.borderWidth = 0.5
        //self.tabBar.layer.borderColor = UIColor(bd_hexColor: "f2f2f2").CGColor
        UITabBar.appearance().backgroundImage = UIImage.fromColor(UIColor.clear)
        UITabBar.appearance().shadowImage = UIImage.fromColor(UIColor.clear)
        UITabBar.appearance().tintColor = Config.Colors.ZanaduCerisePink
         //UITabBar.appearance().backgroundImage = UIImage(named: "tabbarBackground")
        Router.Storyboard = storyboard
        centerButtonDelegate = self
        tabBarOriginalHeight = tabBar.frame.height
        delegate = self
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = MainTabBarController.tabBarHeight + tabBarOriginalHeight
        tabFrame.origin.y = self.view.frame.size.height - MainTabBarController.tabBarHeight - tabBarOriginalHeight
        self.tabBar.frame = tabFrame
        self.tabBar.clipsToBounds = false
//        addCenterButtonWithImage(UIImage(named: "navigation_button")!, highlightImage: nil)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == viewControllers![3] {
            if User.current() == nil {
                Router.redirectToLoginViewController(fromViewController: self)
                return false
            }
            else{
                if self.selectedIndex == 3{
                if let vc = viewController as? FriendsViewController {
                     vc.recommendationStream.contentOffset = CGPoint(x: 0, y: -Config.AppConf.navigationBarAndStatuesBarHeight)
                }
                }
            }
        }
        else if viewController == viewControllers![0]{
            if self.selectedIndex == 0{
               if let vc = viewController as? DiscoverViewController {
                   vc.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
            
        }else if viewController == viewControllers![1]{
            
        }else if viewController == viewControllers![4]{
            if self.selectedIndex == 4{
                if let vc = viewController as? UserProfileViewController {
                    vc.mainScrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
            
        }
        return true
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var tabFrame = self.tabBar.frame
        log.error("tabBarHeight: \(tabFrame.height) -- \(self.tabBarOriginalHeight)")
//        tabFrame.size.height = MainTabBarController.tabBarHeight + tabBarOriginalHeight
//        tabFrame.origin.y = self.view.frame.size.height - MainTabBarController.tabBarHeight - tabBarOriginalHeight


        self.tabBar.frame = tabFrame
        addCenterButtonWithImage(UIImage(named: "navigation_button")!, highlightImage: nil)
    }
    
    func onCenterButtonPressed(_ button: UIButton) {
        if User.current() == nil {
            Router.redirectToLoginViewController(fromViewController: self)
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (newStatus) -> Void in
                if newStatus == PHAuthorizationStatus.authorized {
                    self.jumpToDraftEdit()
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let alert = UIAlertView(title: Config.Strings.NoPhotoLibraryAccessAlertTitle, message: Config.Strings.NoPhotoLibraryAccessAlertMessage, delegate: self, cancelButtonTitle: NSLocalizedString("Sure", comment: "确定"))
                        alert.show()
                    })
                }
            })
        } else {
            jumpToDraftEdit()
        }
    }
    
    func  jumpToDraftEdit() {
        if let step = Foundation.UserDefaults.standard.object(forKey: "draftLastStep") as? String{
            if step == "threeStep" {
                let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                let query =  DataQueryProvider.categoryQuery()
                query.findObjectsInBackground { (objects:[Any]?, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if error != nil {
                        log.error(error?.localizedDescription)
                    }else{
                        if let categorys = objects as? [Category]{
                            
                            let vcs = self.navigationController?.viewControllers

                            if vcs?.count > 1{
                                return
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreationFormViewController") as! CreationFormViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                            vc.categoriesArray = categorys
                        }else{

                        }
                    }
                }
                

            }else if step == "forthStep"{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
                self.navigationController?.pushViewController(vc, animated: true)

            }
            
        }else{
//            self.performSegueWithIdentifier("showCreationFirstStep", sender: self)
        
           let pickerVC = storyboard?.instantiateViewController(withIdentifier: "PhotoLibraryController") as! PhotoLibraryController
            let photoGroupVC = PhotoGroupPickerViewController()
            let nav = UINavigationController.init(rootViewController: photoGroupVC)
            nav.pushViewController(pickerVC, animated: false)
            nav.navigationBar.barStyle = .default
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.tintColor = Config.Colors.MainContentColorBlack
            self.present(nav, animated: true,completion: nil)

        }
        
    }
 
}

extension MainTabBarController : NotificationBadgeValueDelegate {
    func onBadgeValueChanged(_ value: Int) {
        viewControllers![4].tabBarItem!.badgeValue = value > 0 ? "\(value)" : nil
    }
}
