//
//  UIView+Updatable.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/28/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension UIView: Updatable {
    func update() {
        for subview in subviews {
            subview.update()
        }
    }
}
