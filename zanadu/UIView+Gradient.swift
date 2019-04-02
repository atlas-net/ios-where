//
//  UIView+Gradient.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/16/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

let sublayerName = "gradient_C35E8B43"

extension UIView {
    /**
    Add a vertical linear gradient to the UIView
    
    - parameter colors: The colors used for generating the gradient
    */
    func addGradientWithColors(_ colors:[AnyObject]) {

        if layer.sublayers != nil {
            for sublayer in layer.sublayers! {
                if sublayer is CAGradientLayer {
                    if sublayer.name == sublayerName {
                        return
                    }
                }
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.origin = CGPoint.zero
        gradientLayer.frame.size = layer.frame.size
        gradientLayer.colors = colors
        gradientLayer.name = sublayerName
        gradientLayer.cornerRadius = layer.cornerRadius
        //clipsToBounds = true
        removeGradient()
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /**
    Remove the gradient from the UIView
    */
    func removeGradient() {
        if layer.sublayers == nil {
            return
        }
        
        let array = NSArray(array: layer.sublayers!)
        
        for sublayer in array {

            if sublayer is CAGradientLayer {
                if (sublayer as AnyObject).name == sublayerName {
                    (sublayer as AnyObject).removeFromSuperlayer()
                    break;
                }
            }
        }
    }
}

/**
Fix image not displaying bug in UIButton class
*/
extension UIButton {
    override func addGradientWithColors(_ colors: [AnyObject]) {
        super.addGradientWithColors(colors)
        bringSubview(toFront: imageView!)
    }
}
