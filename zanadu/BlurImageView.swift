//
//  BlurImageView.swift
//  Atlas
//
//  Created by liudeng on 16/6/12.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@IBDesignable
class BlurImageView: UIImageView {
    fileprivate lazy var blurView : UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initAddBlurEffectView()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        initAddBlurEffectView()
    }
    
    
    func initAddBlurEffectView() {
        addSubview(blurView)
        blurView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initAddBlurEffectView()
    }
}
