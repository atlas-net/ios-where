//
//  ImageCropViewTappedProtocol.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Protocol that receive ImageCropView tap events

You should implement the protocol's methods to handle ImageCropView tap
*/
public protocol ImageCropViewTapProtocol: class {
    
    /**
    Receive ImageCropView tap event
    
    - parameter imageCropView: the ImageCropView object corresponding to the tapped imageCropView
    */
    func onImageCropViewTapped(_ imageCropView: ImageCropView)
}
