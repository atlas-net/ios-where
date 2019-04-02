//
//  NoAutoScrollUIScrollView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/8/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation


/**
UIScrollView with switchable autoscroll
*/


class NoAutoScrollUIScrollView : UIScrollView {
    
    //MARK: - Properties
    
    var autoScrollEnabled = true
    
    
    //MARK: - Methods
    
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if autoScrollEnabled {
            super.scrollRectToVisible(rect, animated: animated)
        }
    }
    
//    override func needsUpdateConstraints() -> Bool {
//
//        return false
//    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if autoScrollEnabled {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
//    override func setNeedsDisplay() {
//
//    }
//    
//    override func setNeedsDisplayInRect(rect: CGRect) {
//
//    }
//    
//    override func setNeedsLayout() {
//
//    }
//    
//    override func setNeedsUpdateConstraints() {
//
//    }
//    
    func manuallyScrollRectToVisible(_ rect: CGRect, animated: Bool) {
        super.setContentOffset(CGPoint(x: rect.origin.x, y: rect.origin.y), animated: animated)
    }
    
    func manuallySetContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
    }
    
}
