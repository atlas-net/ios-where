//
//  Validate.swift
//  Atlas
//
//  Created by yingyang on 16/5/4.
//  Copyright © 2016年 Atlas. All rights reserved.
//

class Validate {
    
     func validateEmailFormatWithString(_ string:String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
      let a =  string.range(of: emailRegex, options: NSString.CompareOptions.regularExpression)
        if a != nil {
            return true
        }else{
            return false
        }
    }
    
    
}
