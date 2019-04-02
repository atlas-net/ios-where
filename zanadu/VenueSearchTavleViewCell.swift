//
//  VenueSearchTavleViewCell.swift
//  Atlas
//
//  Created by Atlas on 15/11/30.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
class VenueSearchTavleViewCell: UITableViewCell {
    
    var addressLabel = UILabel()
    var distanceLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.distanceLabel.frame = CGRect(x: self.frame.size.width - 60, y: (self.frame.size.height - 20) * 0.5, width: 45, height: 20)
        self.distanceLabel.font = UIFont.systemFont(ofSize: 13)
        self.distanceLabel.textColor = Config.Colors.MainContentColorBlack
        self.distanceLabel.textAlignment = NSTextAlignment.right
        self.addSubview(self.distanceLabel)
        
        self.addressLabel.frame = CGRect(x: 20, y: self.frame.size.height - 20, width: self.frame.size.width - 60, height: 20)
        self.addressLabel.font = UIFont.systemFont(ofSize: 13)
        self.addressLabel.textColor = Config.Colors.MainContentColorBlack
        self.addSubview(self.addressLabel)
        
        self.textLabel?.frame = CGRect(x: 20,y: 10, width: self.frame.size.width - 60, height: 30)
    }
}
