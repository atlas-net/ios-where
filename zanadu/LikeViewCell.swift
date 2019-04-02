//
//  LikeViewCell.swift
//  Atlas
//
//  Created by yingyang on 16/3/9.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
class LikeViewCell: UITableViewCell {
    var avatarImageView = UIImageView()
    override func layoutSubviews() {
        avatarImageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        avatarImageView.layer.cornerRadius = 2
        avatarImageView.layer.masksToBounds = true
        self.contentView.addSubview(avatarImageView)
        super.layoutSubviews()
    }
}
