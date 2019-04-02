//
//  AVFile.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 9/19/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import Foundation

import SDWebImage

extension AVFile {
    
    
    func getImageWithBlock(_ option:SDWebImageOptions? = nil, withBlock block: @escaping (UIImage?, Error?) -> Void) {
        let thumbnailUrl = getThumbnailURLWithScale(toFit: true, width: 1080 , height: 1080)
        ImageCacheManager.recommendationImageWithURL(thumbnailUrl!) { (image, error, cachetype, finished, url) in
            if image == nil {
                block(UIImage(named:"where_logo"),error)
                return
            }
            block(image, error)
        }
    }

}
