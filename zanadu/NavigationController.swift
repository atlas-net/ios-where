//
//  NavigationController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/11/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//
import UIKit

class NavigationController: UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController? {

        
        return super.popViewController(animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navigationController = self
        
    }
}
