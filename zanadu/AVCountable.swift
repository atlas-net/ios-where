//
//  AVCountable.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/14/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

protocol AVCountable {
    func countWithValue(_ value: AnyObject, key: String, completion: (Int)->())
}
