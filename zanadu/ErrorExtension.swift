//
//  ErrorExtension.swift
//  Atlas
//
//  Created by liudeng on 2016/10/14.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation

extension Error{
    var code: Int{
        return (self as NSError).code
    }
}
