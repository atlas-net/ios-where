//
//  CreatPhotoTableView.swift
//  Atlas
//
//  Created by Atlas on 15/11/23.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
import SDWebImage
protocol PhotoTableViewDelegate {
    func onLayoutHeightCalculated(_ height: CGFloat,index:IndexPath)
    func onCellTouched(_ photo : Photo)
}

class PhotoTableView: UITableView, UITableViewDataSource, UITableViewDelegate, PhotoTableViewCellTapDelegate {
    
    //MARK: - Properties
    let cellIdentifier = "CreationPhotoCell"
    var photos = [Photo]()
    var photoImages = [UIImage]()
    var sortPhotoImages = [UIImage]()
    var totalHeight:CGFloat = 0
    var photoTableViewDelegate: PhotoTableViewDelegate?
    var isCellEditable = false
    var isShowCellDelete = false
    var photoDescriptionMargin:CGFloat = 8
    //MARK:- init
    //MARK: - Initializers
    var isFromDraft = false
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        self.backgroundColor = UIColor.red
        self.register(PhotoTableViewCell.self, forCellReuseIdentifier:cellIdentifier)
        self.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.red
        self.register(PhotoTableViewCell.self, forCellReuseIdentifier:cellIdentifier)
        self.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    //MARK: - Methods
    
    func dataQuery(){
        self.totalHeight = 0
        if self.photos.count == 0{
            self.dataSource = self
            self.delegate = self
            let defaultIndex = IndexPath.init(item: 0, section: 1)
            if let photoDelegate = self.photoTableViewDelegate {
                photoDelegate.onLayoutHeightCalculated(self.totalHeight,index: defaultIndex)
            }
        }
        for _ in self.photos{
            let image = UIImage()
            self.sortPhotoImages.append(image)
        }
        
        for (index,photo) in self.photos.enumerated() {
            if isFromDraft {
                var image = UIImage()
                
                if let file = RecommendationFactory.sharedInstance.photos[index + 1].file{
                    image = UIImage(data: file.getData()!)!
                }
                dataQueryCaculateTotalHeight(photo: photo, image: image,index: index)
                
                if self.photoImages.count == self.photos.count{
                    //代理
                    let defaultIndex = IndexPath.init(item: 0, section: 1)
                    if let photoDelegate = self.photoTableViewDelegate {
                        photoDelegate.onLayoutHeightCalculated(totalHeight, index: defaultIndex)
                    }
                    self.photoImages = self.sortPhotoImages
                    self.dataSource = self
                    self.delegate = self
                    self.reloadData()
                }
            }
            else if let file = photo.file {
                if file.isDirty{
                    if let image = UIImage(data: file.getData()!) {
                        dataQueryCaculateTotalHeight(photo: photo, image: image,index: index)
                    }
                    if self.photoImages.count == self.photos.count{
                        //代理
                        let defaultIndex = IndexPath.init(item: 0, section: 1)
                        if let photoDelegate = self.photoTableViewDelegate {
                            photoDelegate.onLayoutHeightCalculated(totalHeight, index: defaultIndex)
                        }
                        self.photoImages = self.sortPhotoImages
                        self.dataSource = self
                        self.delegate = self
                        self.reloadData()
                    }
                }else{
                    var option = index == 0 ? SDWebImageOptions.highPriority : SDWebImageOptions.avoidAutoSetImage
                    option = index > 2 ? SDWebImageOptions.lowPriority : SDWebImageOptions.avoidAutoSetImage

                    file.getImageWithBlock(option, withBlock: { (image, error) -> Void in
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else {
                            self.dataQueryCaculateTotalHeight(photo: photo, image: image!,index: index)
                        }
                        let defaultIndex = IndexPath.init(item: 0, section: 1)
                        if let photoDelegate = self.photoTableViewDelegate {
                            photoDelegate.onLayoutHeightCalculated(self.totalHeight, index: defaultIndex)
                        }
                        self.photoImages = self.sortPhotoImages
                        self.dataSource = self
                        self.delegate = self
                        self.reloadData()
                    })
                }
                

            }
        }
    }
    
    func getDescriptionTextAttribute(_ font:UIFont) -> [String : AnyObject]? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributes = [NSFontAttributeName:font.withSize(15),NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:Config.Colors.MainContentColorBlack]
        return attributes
    }
    
    func getCaptionHeight(_ caption: String) -> CGFloat {
        var height = (caption as NSString).boundingRect(with: CGSize(width: self.frame.size.width - 50, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: getDescriptionTextAttribute(UIFont.systemFont(ofSize: 15)), context: nil).size.height
        let lineHeight = UIFont.systemFont(ofSize: 15).lineHeight
        let lineCount = Int(ceil(lineHeight / lineHeight))
        height += CGFloat(lineCount+1) * 6 + lineHeight
        
        return height
    }
    
    //MARK: - delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        backgroundColor = UIColor.clear
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PhotoTableViewCell else {return UITableViewCell()}
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let photo = self.photos[(indexPath as NSIndexPath).row]
        
        cell.cellCommentSetup()
        cell.tapDelegate = self
        cell.photoImage.image = nil
        cell.photoImage.image = self.photoImages[(indexPath as NSIndexPath).row]
        cell.index = indexPath
        
        let image = self.photoImages[(indexPath as NSIndexPath).row]
        let scale = image.size.width / (self.frame.size.width - 20)
        var scaleHeight = image.size.height / scale
        if scaleHeight.isNaN || scaleHeight <= 0  {
            scaleHeight = 44
        }
        var descriptionHeight = CGFloat()
        if photo.caption == nil || photo.caption == "" {
            if isCellEditable{
                descriptionHeight = 40
                cell.descriptionField.backgroundColor = Config.Colors.TagViewBackground
            }else{
                descriptionHeight = 0
                cell.descriptionField.backgroundColor = UIColor.clear
            }
            cell.descriptionField.text = photo.caption
            cell.placeHolderLabel.isHidden = false
        }else{
            descriptionHeight  = getCaptionHeight(photo.caption!)
            
            if isCellEditable{
                cell.descriptionField.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
                cell.descriptionField.text = photo.caption
            }else{
                cell.descriptionField.attributedText = NSAttributedString(string: photo.caption!, attributes: getDescriptionTextAttribute(cell.descriptionField.font!))
            }
            cell.placeHolderLabel.isHidden = true
            
        }
        
        cell.photoImage.frame = CGRect(x: 10, y: 5, width: self.bounds.size.width - 20,height: scaleHeight)
        cell.descriptionField.frame = CGRect(x: 10, y: cell.photoImage.frame.maxY + photoDescriptionMargin , width: self.bounds.size.width - 20, height: descriptionHeight)
        if isCellEditable{
            cell.descriptionField.isScrollEnabled = true
            cell.descriptionField.isEditable = true
        }else{
            cell.descriptionField.isScrollEnabled = false
            cell.descriptionField.isEditable = false
        }
        if isShowCellDelete{
            cell.deleteButton.isHidden = false
        }else{
            cell.deleteButton.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoImages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = self.photoImages[(indexPath as NSIndexPath).row]
        let scale = image.size.width / (self.frame.size.width - 20)
        let scaleHeight = image.size.height / scale
        let photo = self.photos[(indexPath as NSIndexPath).row]
        var descriptionHeight = CGFloat()
        if photo.caption == nil || photo.caption == "" {
            if isCellEditable {
                descriptionHeight = 40
            } else {
                descriptionHeight = 0
            }
        } else {
            descriptionHeight  = getCaptionHeight(photo.caption!)
        }
        let height:CGFloat = 5 + scaleHeight + descriptionHeight + 5 + photoDescriptionMargin
        if height.isNaN || height <= 0 {
            return 44
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = self.photos[(indexPath as NSIndexPath).row]
        if let delegate = self.photoTableViewDelegate {
            delegate.onCellTouched(photo)
        }
    }
    
    func onDeleteButtonTapped(_ index: IndexPath) {
        self.photoImages.remove(at: (index as NSIndexPath).row)
        self.photos.remove(at: (index as NSIndexPath).row)
        self.reloadData()
        calculateTotalHeight(index)
    }
    
    func calculateTotalHeight(_ itemIndex: IndexPath) {
        totalHeight = 0
        for (i, photo) in self.photos.enumerated() {
            if i >= photoImages.count{
                break
            }
            let scale = photoImages[i].size.width / (self.frame.size.width - 20)
            let scaleHeight = photoImages[i].size.height / scale
            
            var descriptionHeight = CGFloat()
            if photo.caption == nil || photo.caption == ""{
                if isCellEditable{
                    descriptionHeight = 40
                }else{
                    descriptionHeight = 0
                }
            }else{
                descriptionHeight  = getCaptionHeight(photo.caption!)
            }
            let height = 5 + scaleHeight + descriptionHeight + 5 + photoDescriptionMargin
            totalHeight = totalHeight + height
        }
        if let delegate = self.photoTableViewDelegate {
            delegate.onLayoutHeightCalculated(totalHeight,index: itemIndex)
        }
    }
    
    func dataQueryCaculateTotalHeight(photo:Photo,image:UIImage,index:Int){
        self.photoImages.append(image)
        self.sortPhotoImages[index] = image
        let scale = image.size.width / (self.frame.size.width - 20)
        let scaleHeight = image.size.height / scale
        var descriptionHeight = CGFloat()
        if photo.caption == nil || photo.caption == ""{
            descriptionHeight = 0
        }else{
            descriptionHeight  = getCaptionHeight(photo.caption!)
        }
        let height = 5 + scaleHeight  + descriptionHeight + 5 + photoDescriptionMargin
        totalHeight = totalHeight + height
        
    }
    
    func saveDescription() {
        if self.photos.count <= 0 {
            return
        }
        for index in 0...self.photos.count - 1 {
            let photo = self.photos[index]
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = self.cellForRow(at: indexPath) as? PhotoTableViewCell {
                photo.caption = cell.descriptionField.text
            }
        }
    }
    func getCaptions() -> [String]{
        var captions = [String]()
        if self.photos.count <= 0 {
            return captions
        }
        for index in 0...self.photos.count - 1 {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = self.cellForRow(at: indexPath) as? PhotoTableViewCell {
                captions.append(cell.descriptionField.text)
            }
        }
        return captions
        
    }
    
}
