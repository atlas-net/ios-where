//
//  IntroPage.swift
//  Atlas
//
//  Created by Atlas on 15/12/28.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
class IntroPage: UIView {
    
//    @IBOutlet weak var bgImage: UIImageView!
//    
//    
//    @IBOutlet weak var titleLabel: UILabel!
//    
//    
//    @IBOutlet weak var pinImageV: UIImageView!
    
    var bgImage = UIImageView()
    var titleLabel = UILabel()
    var titleLabel2 = UILabel()
    var pinImageV = UIImageView()
    var coordinateImageV = UIImageView()
    var animateTimer = Timer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgImage.contentMode = UIViewContentMode.scaleToFill
        self.addSubview(bgImage)
        
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.clear//UIColor(red: 53/255.0, green: 28/255.0, blue: 42/255.0, alpha: 1.0)
//        titleLabel.layer.cornerRadius = titleLabel.frame.size.height / 2
        titleLabel.font = UIFont.systemFont(ofSize: 11)
//        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = NSTextAlignment.left
        self.addSubview(titleLabel)
        
        titleLabel2.textColor = UIColor.white
        titleLabel2.backgroundColor = UIColor.clear//UIColor(red: 53/255.0, green: 28/255.0, blue: 42/255.0, alpha: 1.0)
        //        titleLabel.layer.cornerRadius = titleLabel.frame.size.height / 2
        titleLabel2.font = UIFont.systemFont(ofSize: 11)
        //        titleLabel.layer.masksToBounds = true
        titleLabel2.textAlignment = NSTextAlignment.left
        self.addSubview(titleLabel2)
        
        
        
        
        pinImageV.backgroundColor = UIColor.clear
        pinImageV.image = UIImage(named:"circlePin")
        self.addSubview(pinImageV)
        
        coordinateImageV.backgroundColor = UIColor.clear
        coordinateImageV.image = UIImage(named:"grayPin")
        coordinateImageV.contentMode = UIViewContentMode.center
        self.addSubview(coordinateImageV)
    }
    func loadTopTimer(){
        animateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(IntroPage.animateTimer(_:)), userInfo: nil, repeats: true)
        animateTimer.fire()
    }
    func animateTimer(_ timer:Timer){
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.pinImageV.center = self.pinImageV.center
            self.pinImageV.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            self.pinImageV.alpha = 1
            }, completion: { (success) -> Void in
                UIView.animate(withDuration: 2, animations: { () -> Void in
                    self.pinImageV.center = self.pinImageV.center
                    self.pinImageV.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
                    self.pinImageV.alpha = 0.1
                    }, completion: { (success) -> Void in
                        self.pinImageV.center = self.pinImageV.center
                        self.pinImageV.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                        self.pinImageV.alpha = 1
                })
        }) 
        
    }

    
    
    
}
