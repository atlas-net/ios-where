//
//  CameraButtonViewCellDelegate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/17/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


/**
Protocol that receive CameraButtonViewCell events

You should implement the protocol's methods to handle CameraButtonViewCell events
*/
@objc protocol CameraButtonViewCellSelectionDelegate: class {
    
    /**
    Receive CameraButton selection event
    */
    func onCameraButtonTapped()
}
