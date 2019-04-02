//
//  RecommendationSelectionProtocol.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/13/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Protocol that receive recommendation cell events

You should implement the protocol's methods to handle recommendation cell events
*/
@objc protocol RecommendationSelectionProtocol: class {
    
    /**
    Receive recommendation selection event
    
    - parameter recommendation: the Recommendation object corresponding to the selected recommendation
    */
    func onRecommendationSelected(_ recommendation: Recommendation)
    
    /**
    Receive tribe's author selection event
    
    - parameter author: the User object corresponding to the selected recommendation
    */
    @objc optional func onAuthorSelected(_ author: User)
}
