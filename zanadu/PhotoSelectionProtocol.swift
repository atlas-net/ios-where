//
//  PhotoSelectionProtocol.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


/**
Protocol that receive Photo selection events

You should implement the protocol's methods to handle Photo selection
*/
protocol PhotoSelectionProtocol: class {
    
    /**
    Receive photo selection event
    
    - parameter tribe: the Tribe object corresponding to the selected tribe
    */
    func onPhotoSelected(_ photo: Photo)
}
