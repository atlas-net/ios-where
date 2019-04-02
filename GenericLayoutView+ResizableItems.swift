//
//  ResizableLayoutItem.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/24/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

public protocol ResizableLayoutItemContainer {
    func onHeightUpdated(_ height: CGFloat, forItem item: UIView)
}

extension GenericLayoutView : ResizableLayoutItemContainer {
    public func onHeightUpdated(_ height: CGFloat, forItem item: UIView) {
        updateLayoutCellsWithHeight(height, forItem:item)
    }
}
