//
//  UICollectionView+IndexPathsInRect.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/6/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath]? {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        if (allLayoutAttributes.count == 0) { return nil }
        
        var indexPaths = [IndexPath]()
        
        for layoutAttributes in allLayoutAttributes {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        
        return indexPaths;
    }
}
