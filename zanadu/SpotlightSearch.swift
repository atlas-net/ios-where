//
//  SpotlightSearch.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 9/17/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices

/**
SpotlightSearch

Wrapper class for new iOS9 Spotlight API
*/
@available(iOS 9.0, *)
open class SpotlightSearch {

    //MARK: - Properties
    
    //MARK: - Outlets
    
    //MARK: - Initializers
    
    //MARK: - Actions
    
    //MARK: - Methods
    
    open static func setupSearchableItemWithImage(_ image: UIImage, uniqueId: String, domainId: String, title: String, description: String) {
        // Create an attribute set to describe an item.
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeData as String)
        // Add metadata that supplies details about the item.
        attributeSet.title = title
        attributeSet.contentDescription = description
        attributeSet.thumbnailData = UIImageJPEGRepresentation(image, Config.AppConf.PhotoCompressionFactor)
        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: uniqueId, domainIdentifier: domainId, attributeSet: attributeSet)
        // Add the item to the on-device index.
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                log.error(error?.localizedDescription)
            }
            else {

            }
        }
    }
}
