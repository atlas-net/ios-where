//
//  NSndexSet+IndexPathsFromIndex.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/6/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

import Foundation

extension IndexSet {
    
    func indexPathsFromIndexesWithSection(_ section:Int) -> [IndexPath] {
        return self.map { (element) -> IndexPath in
            return IndexPath(item: element, section: section)
        }
        
    }
    
}
