//
//  assetPhoto.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
import Photos


class AssetPhoto: NSObject, NYTPhoto {
 
    var asset:PHAsset?
    var tmpImage: UIImage?
    let attributedCaptionTitle: NSAttributedString
    let attributedCaptionSummary = NSAttributedString(string: "summary string", attributes: [NSForegroundColorAttributeName: UIColor.gray])
    let attributedCaptionCredit = NSAttributedString(string: "credit", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])

    var placeholderImage: UIImage {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        var tmpPlaceholder: UIImage!
        
        imageManager.requestImage(for: asset!, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { (image, _) -> Void in
            tmpPlaceholder = image
        }
        return tmpPlaceholder
    }
    
    var image: UIImage {
        if let tmpImage = self.tmpImage {
            return tmpImage
        }
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let rect = UIApplication.shared.keyWindow?.frame
        let size = CGSize(width: rect!.width, height: rect!.height)

        imageManager.requestImage(for: asset!, targetSize: CGSize(width:size.width , height: size.height), contentMode: .aspectFit, options: requestOptions) { (image, info) -> Void in
            if image == nil {
                log.error("\(info)")
            } else {

            }
            self.tmpImage = image
        }
        return tmpImage!
    }
    
    
    init(asset: PHAsset, attributedCaptionTitle: NSAttributedString) {
        self.asset = asset
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
    
    init(asset: PHAsset) {
        self.asset = asset
        self.attributedCaptionTitle = NSAttributedString(string:"")
        super.init()
    }
}
