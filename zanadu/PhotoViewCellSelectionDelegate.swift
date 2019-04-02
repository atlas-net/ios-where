//
//  PhotoViewCellSelectionDelegate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/17/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


/**
Protocol that receive PhotoViewCell events

You should implement the protocol's methods to handle PhotoViewCell events
*/
@objc protocol PhotoViewCellSelectionDelegate: class {
    
    /**
    Receive CellButton tap event

    - parameter cell: the PhotoViewCell object corresponding to the tapped button
    */
    func onCellButtonTapped(_ cell: PhotoViewCell)

    /**
    Receive AroundCellButton tap event
    
    - parameter cell: the PhotoViewCell object corresponding to the tapped button
    */
    func onAroundCellButtonTapped(_ cell: PhotoViewCell)

    /**
    Receive ThumbnailButton tap event

    - parameter cell: the Recommendation object corresponding to the tapped thumbnail
    */
    func onCellThumbnailButtonTapped(_ cell: PhotoViewCell)
}
