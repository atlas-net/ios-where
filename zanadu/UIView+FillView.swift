//
//  UIView+FillView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/23/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation

extension UIView {
    
    func fillView(_ view: UIView) -> Bool {
        
        // test size
        if self.frame.size.width < view.frame.size.width || self.frame.size.height < view.frame.size.height {
            return false
        }
        return true
    }
    
    func willFillView(_ view: UIView, withScale scale: CGFloat) -> Bool {
        if self.frame.width * scale < view.frame.width || self.frame.height * scale < view.frame.height {
            return false
        }
        return true
    }
}
