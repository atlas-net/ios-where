//
//  CenterButtonTabBarController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
*  Delegate giving access to the CenterButtonTabBarController's center button onPressed event
*/
protocol CenterButtonTabBarControllerDelegate {
    func onCenterButtonPressed(_ button:UIButton)
}

/**
Provides a UITabBarController with a CenterButton (as in Path, Instagram...)

Implement the CenterButtonTabBarControllerDelegate to intercept center button onPressed event
*/
class CenterButtonTabBarController: UITabBarController {

    //MARK: - Properties
    
    var centerButtonDelegate: CenterButtonTabBarControllerDelegate?

    
    //MARK: - Actions
    
    func onButtonPressed(_ sender: UIButton!) {
        if let centerButtonDelegate = centerButtonDelegate {
            centerButtonDelegate.onCenterButtonPressed(sender)
        }
    }

    
    //MARK: - Methods
    
    func viewControllerWithTabTitle(_ title: String, image: UIImage?) -> UIViewController {
        let viewController = UIViewController()
        viewController.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
        
        return viewController
    }
    
    func addCenterButtonWithImage(_ buttonImage: UIImage, highlightImage: UIImage?) {
        
        // button
        let button = UIButton(type: UIButtonType.custom)
        button.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
        button.frame = CGRect(x: 0, y: 0, width: 55 , height: 55)
        button.setImage(buttonImage, for: UIControlState())
        button.setImage(highlightImage, for: .highlighted)
        button.addTarget(self, action: #selector(CenterButtonTabBarController.onButtonPressed(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        //button.layer.cornerRadius = 27.5
        //button.setBackgroundImage(UIImage(named: "navigationMiddleCover"), forState: .Normal)
        

        var center = self.tabBar.center
        if UIScreen.main.bounds.height == 812 {

            center.y = center.y - 22.5

        }else{
             center.y = center.y - 2.5
        }

        button.center = center
        
        view.addSubview(button)
        
       
        
    }
}
