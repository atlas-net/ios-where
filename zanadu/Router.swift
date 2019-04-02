//
//  Navigation.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/13/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Manage navigation between UIViewControllers
*/
class Router {
    
    //MARK: - Properties
    static var Storyboard: UIStoryboard!
    
    static var isFromNotification = false

    //MARK: - Methods
    
    static func redirectToRecommendation(_ recommendation: Recommendation, fromViewController viewController: UIViewController) {
        let previewViewController = viewController.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        if isFromNotification {
            let vcs = viewController.navigationController?.viewControllers
            if (vcs?.count)! > 2{
                return
            }
        }
        viewController.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    static func redirectToUser(_ user: User, fromViewController viewController: UIViewController) {

        if user == User.current() && viewController.tabBarController != nil {
            let vc: UserProfileViewController? = viewController.tabBarController!.viewControllers?.last as? UserProfileViewController
            //        var upvc = vc as? UserProfileViewController
            vc!.user = user
            viewController.tabBarController?.selectedIndex = 4
        } else {
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            vc.user = user
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    static func redirectToVenue(_ venue: Venue, fromViewController viewController: UIViewController) {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "VenueHomeListingViewController") as! VenueHomeListingViewController
        vc.venue = venue
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func redirectToTag(_ tag: Tag, fromViewController viewController: UIViewController) {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "TagHomeListingViewController") as! TagHomeListingViewController
        vc.tag = tag
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func redirectToNotificationsFromViewController(_ viewController: UIViewController) {
        if viewController.tabBarController != nil {
            viewController.tabBarController?.selectedIndex = 3
        } else {
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
            vc.selectedIndex = 3
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    static func redirectToSettingsMain(fromViewcontroller viewController: UIViewController) {
        let settingsMainViewController = SettingsMainViewController()
        viewController.navigationController?.pushViewController(settingsMainViewController, animated: true)
    }
    static func redirectToNotification(fromViewcontroller viewController: UIViewController) {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func redirectToSharingMethod(_ recommendation: Recommendation, fromCreationProcess: Bool, fromViewController viewController: UIViewController,WithSharingImage image:UIImage ) {
        let sharingViewController = viewController.storyboard?.instantiateViewController(withIdentifier: "CreationSharingViewController") as! CreationSharingViewController
        sharingViewController.recommendation = recommendation
        sharingViewController.coverImage = image
        viewController.navigationController?.pushViewController(sharingViewController, animated: true)
    }
    
    static func redirectToWelcomeViewController(fromViewController viewController: UIViewController, fromLogout: Bool = false) {
        let welcomeViewController = Router.Storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            viewController.present(welcomeViewController, animated: true, completion: nil)
    }
    
    static func redirectToLoginViewController(fromViewController viewController: UIViewController) {
            let welcomeViewController = Router.Storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.navigationController?.pushViewController(welcomeViewController, animated: true)
    }
    static func redirectToPhotoLibraryController(_ target: PhotoLibraryTarget, fromViewController viewController: UIViewController) {
        let photoLibraryController = Router.Storyboard.instantiateViewController(withIdentifier: "PhotoLibraryController") as! PhotoLibraryController
        photoLibraryController.target = target
        viewController.navigationController?.pushViewController(photoLibraryController, animated: true)
    }
    
    static func redirectToDiscoverViewController(fromViewController viewController: UIViewController) {
        if viewController.tabBarController != nil {
            viewController.tabBarController?.selectedIndex = 0
        } else {
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
            vc.selectedIndex = 0
            guard let navigationController = viewController.navigationController else {
                viewController.present(vc, animated: true, completion: nil)
                return
            }
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    static func redirectToNavigationController(fromViewController viewController: UIViewController) {
        let vc = Router.Storyboard.instantiateViewController(withIdentifier: "NavigationController")
        viewController.present(vc, animated: false, completion: nil)
    }   
}
