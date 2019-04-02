//
//  CategoryCatalogCell.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/3/15.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CategoryCatalogCell: UITableViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLineHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectIconImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        self.backgroundColor = Config.Colors.CateCellBackgroudColor
        titleLabel.textColor = Config.Colors.CateCellTextColor
          bottomLineHeightConstraint.constant = 0.5

        }
    func labelTapTapped(){
        titleLabel.textColor = Config.Colors.CateCellHighliedTextColor
    }
    func configCellWithIndexPath(_ array: [SubCategory] , indexPath : IndexPath) -> CategoryCatalogCell {
        let imageNameArray = ["icon_ententainment","icon_bar","icon_hotel","icon_hotel","icon_shopping","icon_ententainment","icon_eles"]
        let index = (indexPath as NSIndexPath).row
        let category = array[index]

        titleLabel.text = category.name
        categoryImage.image = UIImage(named: imageNameArray[index])
        
        if RecommendationFactory.sharedInstance.categorys?.count > 0 {
            for cate in RecommendationFactory.sharedInstance.categorys!{
                if cate.name == category.name{
                    category.isSelected = true
                    break
                }
                
            }
        }
        var  selectImageName = ""
        if category.isSelected! {
            selectImageName = "selectedIcon"
        }else{
            selectImageName = "normalIcon"

        }
        selectIconImgView.image = UIImage(named: selectImageName)

        return self
    }
}
