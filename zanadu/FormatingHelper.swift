//
//  Formating.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/28/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**


*/
class FormatingHelper {
    
    //MARK: - Properties
    
    //MARK: - Methods
    
    static func distanceFormater(_ kilometers: Double) -> String {
        var returnStr = ""
        
        if kilometers <= 0 {
            returnStr = "0m"
        } else {
            let integerPart = Int(kilometers)
            
            if integerPart > 0 {
                returnStr = "\(integerPart)km"
            } else {
                let decimalPart = Int(kilometers * 1000)
                returnStr = "\(decimalPart)m"
            }
        }
        return returnStr
    }
}
