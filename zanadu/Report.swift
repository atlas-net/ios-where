//
//  Report.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/12/16.
//  Copyright © 2016 Atlas. All rights reserved.
//




/**
Report
*/
class Report: AVObject {
    
    // MARK: - Variables
    
    @NSManaged
    var sender: User?
    
    @NSManaged
    var recommendation: Recommendation?
    
    @NSManaged
    var reason: String?
    
    @NSManaged
    var valid: NSNumber?

    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(sender: User, recommendation: Recommendation, reason: String) {
        super.init()
        self.sender = sender
        self.recommendation = recommendation
        self.reason = reason
    }
}

extension Report: AVSubclassing {
    class func parseClassName() -> String! {
        return "Report"
    }
}
