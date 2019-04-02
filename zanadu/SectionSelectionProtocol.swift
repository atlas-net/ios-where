//
//  SectionSelectionProtocol.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/28/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Protocol that receive section selection events

You should implement the protocol's methods to handle section view events
*/
@objc protocol SectionSelectionProtocol: class {
    
    /**
    Receive section's button selection event
    
    - parameter section: the Section object corresponding to the selected sections
    */
    func onSectionButtonSelected(_ section: Section)
    
    /**
    Receive section's map button selection event
    
    - parameter section: the Section object corresponding to the selected sections
    */
    @objc optional func onSectionItemButtonSelected(_ section: Section)
}
