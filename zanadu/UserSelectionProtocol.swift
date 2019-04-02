//
//  UserSelectionProtocol.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/6/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Protocol that receive user cell events

You should implement the protocol's methods to handle user cell events
*/
@objc protocol UserSelectionProtocol: class {
    
    /**
    Receive user selection event
    
    - parameter user: the User object corresponding to the selected user
    */
    func onUserSelected(_ user: User)
    
}
