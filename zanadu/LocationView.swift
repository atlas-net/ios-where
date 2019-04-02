//
//  LocationView.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/5/20.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class LocationView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var titleLabel = UILabel()
    internal func create(){
        let imageRect = CGRect(x: -5, y: 21, width: 15, height: 20)
        let imageView = UIImageView(image: UIImage(named: "icon_location")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = Config.Colors.ZanaduCerisePink
        imageView.frame = imageRect
        self.addSubview(imageView)
        
        let titleLabelFrame = CGRect(x: 15, y: 21, width: 80, height: 20)
        titleLabel.frame = titleLabelFrame
        self.addSubview(titleLabel)
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = Config.Colors.SecondTitleColor
    }
    
    internal func settitle(_ title : String){
        titleLabel.text = title
        var  stringLength = CGFloat(title.characters.count*20)
        let maxWidth : CGFloat = 72
        if stringLength > maxWidth {
            stringLength = maxWidth
        }
        let rect = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: stringLength, height: titleLabel.frame.size.height)
        titleLabel.frame = rect
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: stringLength + 20, height: self.frame.size.height)
    }

}
