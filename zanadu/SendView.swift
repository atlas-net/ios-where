//
//  SendView.swift
//  Atlas
//
//  Created by Atlas on 15/12/29.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
class SendView:UIView {
    
    var coverImgV = UIImageView()
    var uploadLabel = UILabel()
    var progressView = UIProgressView()
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        
        coverImgV.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.addSubview(coverImgV)
        
        uploadLabel.frame = CGRect(x: 40, y: 2, width: 100, height: 30)
        uploadLabel.text = "正在上传中......"
        uploadLabel.textColor = Config.Colors.SecondTitleColor
        self.addSubview(uploadLabel)
        
        progressView.frame = CGRect(x: 0, y: self.frame.size.height - 4, width: self.frame.size.width, height: 4)
        progressView.progressTintColor = Config.Colors.ButtonLightPink
        progressView.trackTintColor = Config.Colors.GrayBackGroundWithAlpha
        self.addSubview(progressView)
    }
    
    func startProgeess() {
        progressView.progress = 0
    }
    
    func updateProgress(_ percent:Float) {

        progressView.progress = percent
    }
    
    func endProgress() {
        progressView.progress = 1
    }
}
