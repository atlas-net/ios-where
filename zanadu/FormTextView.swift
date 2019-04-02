//
//  FormTextView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/30/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit

@IBDesignable
class FormTextView: UITextView {
    
    @IBInspectable var inset: Float = 8
    @IBInspectable var bottomInset: CGFloat = 25
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let inset = CGFloat(self.inset)
        print("init textView \(inset)", terminator: "")
        textContainerInset = UIEdgeInsetsMake(inset, inset, bottomInset, inset)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        let inset = CGFloat(self.inset)
        print("init textView \(inset)", terminator: "")
        textContainerInset = UIEdgeInsetsMake(inset, inset, bottomInset, inset)
    }
    
}
