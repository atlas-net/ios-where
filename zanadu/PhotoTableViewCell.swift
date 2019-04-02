//
//  CreatPhotoTableViewCell.swift
//  Atlas
//
//  Created by Atlas on 15/11/23.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation


public protocol PhotoTableViewCellTapDelegate {
    func onDeleteButtonTapped(_ index:IndexPath)
}

class PhotoTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    var photoImage = UIImageView()
    var deleteButton = UIButton()
    var tapDelegate: PhotoTableViewCellTapDelegate?
    var index = IndexPath()
    var coverImage = UIImageView()
    var descriptionField = UITextView()
     let placeHolderLabel = UILabel()
    

    //MARK: - method

    func cellCommentSetup() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
        
        photoImage.contentMode = UIViewContentMode.scaleToFill
        self.addSubview(photoImage)
        
        deleteButton.frame = CGRect(x: self.frame.size.width - 40, y: 15, width: 40, height: 40)
        let img = UIImage(named: "delete")
        deleteButton.setImage(img, for: UIControlState())
        deleteButton.setImage(img, for: UIControlState.highlighted)
        deleteButton.addTarget(self, action:#selector(PhotoTableViewCell.deleteBtnClick), for: UIControlEvents.touchUpInside)
        self.addSubview(deleteButton)
        
        
        descriptionField.backgroundColor = UIColor.clear
        descriptionField.font = UIFont.systemFont(ofSize: 14)
        descriptionField.delegate = self
        descriptionField.textColor = UIColor.white
        
        placeHolderLabel.frame = CGRect(x: 5, y: 0, width: self.contentView.bounds.size.width,height: 40 )
        placeHolderLabel.text = "添加描述"
        placeHolderLabel.textColor = UIColor.lightGray
        placeHolderLabel.font = UIFont.systemFont(ofSize: 14)
        placeHolderLabel.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        descriptionField.addSubview(placeHolderLabel)
        
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: descriptionField, action: #selector(UIResponder.resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        barButton.tintColor = Config.Colors.ZanaduCerisePink
        toolbar.items = [barButton]
        descriptionField.inputAccessoryView = toolbar
        self.addSubview(descriptionField)
    }

    func deleteBtnClick() {
        if let delegate = tapDelegate {
            delegate.onDeleteButtonTapped(self.index)
        }
    }
    
}
extension PhotoTableViewCell : UITextViewDelegate{

 
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil {
           placeHolderLabel.isHidden = true
        }else{
            placeHolderLabel.isHidden = false
  
        }
    }
}
