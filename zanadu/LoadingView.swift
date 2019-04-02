//
//  LoadingView.swift
//  Atlas
//
//  Created by Atlas on 15/11/4.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
class LoadingView: UIView {
    //MARK: - Properties
    
    var isBackImageViewHidden = false
    
    var isWhereImageViewHidden = false
    
    var isUserLittleBgImage = false
    
    var isFromRecommendationCell = false
    
    var backImageView = UIImageView()
    
    var spinner: SARMaterialDesignSpinner = SARMaterialDesignSpinner()
    
    var whereImageView = UIImageView()
    
    var featherImageView = UIImageView()
    
    
    //MARK: - View Initializers
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //bggroundImage
        if !self.isBackImageViewHidden{
        self.backImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height);
            var img = UIImage()
            if self.isUserLittleBgImage{
                img = UIImage(named: "littleLoadingBg")!
            }else{
               img = UIImage(named: "loadingBg")!
            }
        self.backImageView.image = img
        self.addSubview(self.backImageView)
        }
        
       //spinner
        if !isFromRecommendationCell{
        self.spinner = SARMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        }else{
        self.spinner = SARMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        self.spinner.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        self.spinner.lineWidth = 1.5
        self.spinner.strokeColor = Config.Colors.ZanaduCerisePink
        self.spinner.enableGoogleMultiColoredSpinner = false
        self.addSubview(self.spinner)
        self.spinner.startAnimating()
        
       //whereImage
        if !self.isWhereImageViewHidden{
        self.whereImageView.frame = CGRect(x: self.whereImageView.frame.origin.x, y: self.whereImageView.frame.origin.y,width: 52, height: 15)
        self.whereImageView.center = CGPoint(x: self.backImageView.center.x, y: self.backImageView.center.y + 60)
        let whereImg = UIImage(named: "where")?.withRenderingMode(.alwaysTemplate)
        self.whereImageView.image = whereImg
            self.whereImageView.tintColor = Config.Colors.ZanaduCerisePink
        self.addSubview(self.whereImageView)
        }
        
        
        //featherImage
        if !isFromRecommendationCell{
        self.featherImageView.frame = CGRect(x: self.featherImageView.frame.origin.x, y: self.featherImageView.frame.origin.y,width: 27, height: 50)
        }else{
        self.featherImageView.frame = CGRect(x: self.featherImageView.frame.origin.x, y: self.featherImageView.frame.origin.y,width: 18, height: 34)
        }
        self.featherImageView.center = CGPoint(x: self.spinner.center.x, y: self.spinner.center.y )
        let featherImage = UIImage(named: "feather")?.withRenderingMode(.alwaysTemplate)
        self.featherImageView.image = featherImage
        self.featherImageView.tintColor = Config.Colors.ZanaduCerisePink
        self.addSubview(self.featherImageView)
        
        
    }
    
   
    
}
