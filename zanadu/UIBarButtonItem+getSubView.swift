//
//  UIBarButtonItem+getSubView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/9/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension UIBarButtonItem {
    func getSubView() -> UIView? {
        return self.value(forKey: "view") as? UIView
    }
}

