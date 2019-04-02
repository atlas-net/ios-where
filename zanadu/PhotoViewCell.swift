//
//  PhotoViewCell.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/3/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Photos
import CoreLocation


class PhotoViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    var delegate: PhotoViewCellSelectionDelegate?
//    var asset: PHAsset?
    
    var assetIdentifier: String?
    var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = thumbnailImage
        }
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var aroundButton: UIButton!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func onButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.onCellButtonTapped(self)
        }
    }

    @IBAction func onAroundButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.onAroundCellButtonTapped(self)
        }
    }
    
    func onThumbnailTapped(_ sender: AnyObject) {
        if let delegate = delegate {
            delegate.onCellThumbnailButtonTapped(self)
        }
    }
    
//    func setupWithAsset(asset: PHAsset) {
//        self.asset = asset
//        self.thumbnailImageView.image = nil
//       // self.thumbnailImageView.image = UIImage(named: "littleLoadingBg")
//       // self.thumbnailImageView.contentMode = .ScaleAspectFill
//        
//        Shared.imageCache.fetch(key: asset.localIdentifier, failure: { (error) -> () in
//            let imageManager = PHImageManager.defaultManager()
//            let requestOptions = PHImageRequestOptions()
//            requestOptions.synchronous = false
//            imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: .AspectFill, options: requestOptions) { (image, _) -> Void in
//                Shared.imageCache.set(value: image!, key: asset.localIdentifier)
//                self.thumbnailImageView.image = image
//            }
//        }) { (image) -> () in
//            self.thumbnailImageView.image = image
//            //
//        }
//    }
    
    func selectButton() {
//        if button.layer.borderWidth == 0 {
//            return
//        }
//        
        button.backgroundColor = Config.Colors.ZanaduCerisePink
        button.layer.borderWidth = 0

        if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
            self.layer.borderWidth = 2
        } else {
            self.layer.borderWidth = 3
        }

        self.layer.borderColor = Config.Colors.ZanaduCerisePink.cgColor
    }
    
    func deselectButton() {
//        if button.layer.borderWidth == 1 {
//            return
//        }
        button.backgroundColor = UIColor(white: 0, alpha: 0.4)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        self.layer.borderWidth = 0
    }
    
    func addTapListener() {
        let thumbnailTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewCell.onThumbnailTapped(_:)))
        thumbnailImageView.addGestureRecognizer(thumbnailTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.cornerRadius = button.frame.height / 2
    }
    
}
