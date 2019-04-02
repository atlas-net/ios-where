//
//  UISearchBar+TextField.swift
//  zanadu
//
//  Created by Benjamin Lefebvre on 11/12/15.
//  Copyright © 2015 zanadu. All rights reserved.
//

import Foundation

extension UISearchBar {
    var textField : UITextField! {
        for view in self.subviews {
            if view is UITextField {
                return view as? UITextField
            }
        }
        return nil
    }
}