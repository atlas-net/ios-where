//
//  UIImagePickerController#prefersStatusBarHidden.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/9/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension UIImagePickerController {
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    override open var childViewControllerForStatusBarHidden : UIViewController? {
        return nil
    }
}

