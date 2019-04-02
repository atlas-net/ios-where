//
//  TechnicalData.swift
//  Atlas
//
//  Created by Atlas on 15/11/18.
//  Copyright © 2015年 Atlas. All rights reserved.
//

//
//  TechnicalData.swift
//  Atlas
//
//  Created by Yuko on 15/11/18.
//  Copyright © 2015年 Atlas. All rights reserved.
//




/**
TechnicalData
*/
class TechnicalData: AVObject, AVSubclassing {
    
    // MARK: - Properties
    @NSManaged
    var deviceUUID: String?
    @NSManaged
    var iosVersion: String?
    @NSManaged
    var iphoneModel: String?
    @NSManaged
    var appVersion: String?
    
    //MARK: - Methods
    
    
    //MARK: - AVSublassing Methods
    class func parseClassName() -> String! {
        return "TechnicalData"
    }
}
