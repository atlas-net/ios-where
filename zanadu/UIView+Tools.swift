//
//  UIView+CornerRadius.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/13/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIView {
    func circularBorder(_ color:CGColor, withWidth width: CGFloat) {
        layer.cornerRadius = layer.frame.height / 2
        clipsToBounds = true
        layer.borderColor = color
        layer.borderWidth = width
    }
    func screenViewShots() -> UIImage{
        let rect = self.frame
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
