//
//  FormTextField.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/30/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit

@IBDesignable
class FormTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
