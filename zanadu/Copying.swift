//
//  Copying.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/29/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}
