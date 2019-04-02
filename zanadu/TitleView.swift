//
//  TitleView.swift
//  Atlas
//
//  Created by songbin on 06/03/2018.
//  Copyright © 2018 Atlas. All rights reserved.
//

import UIKit

class TitleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override var intrinsicContentSize: CGSize {

        return CGSize(width: self.frame.width, height: self.frame.height)
    }

}
