//
//  GenericLayout.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

typealias GenericLayoutTemplate = [(GenericLayoutCellWidth, GenericLayoutCellHeight)]

@objc
public protocol GenericLayoutDelegate {
    func onLayoutHeightCalculated(_ height: CGFloat)
    @objc optional func customItemSetup(_ item: UIView)
}

public enum GenericLayoutName {
    case `default`
    case halfWidthOneRow
    case halfWidthTwoRows
    case fullWidthOneRow
    case fullWidthTwoRows
}

public enum GenericLayoutCellWidth {
    case fullWidth
    case halfWidth
}

public enum GenericLayoutCellHeight {
    case oneRow
    case twoRows
}

public enum GenericLayoutPosition {
    case left
    case topRight
    case bottomRight
}


/**
GenericLayoutView displays a list of views in "cells" using a GenericLayoutTemplate

If the inner views may change height they should implement the VariableHeightLayoutItem protocol
*/
open class GenericLayoutView<T: UIView>: UIView {

    //MARK: - Properties
    
    var items = [T]()
    fileprivate var delegate: GenericLayoutDelegate?

    //MARK: - Inspectables
    
    @IBInspectable open var padding: CGFloat = 0
    @IBInspectable open var cellPadding: CGFloat = 0
    @IBInspectable open var cellBorderColor: UIColor = UIColor.clear
    @IBInspectable open var cellBorderWidth: Int = 0
    
    //MARK: - Initializers
    
    public init() {
        super.init(frame:CGRect.null)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }


    //MARK: - Actions
    
    
    //MARK: - Methods
    
    open func getItems() -> [T] {
        return items
    }

    open func setup(_ items: [T], template name: GenericLayoutName = .default, delegate: GenericLayoutDelegate? = nil) {
        if items.count < 1 {
            return
        }

        self.items = items
        self.delegate = delegate
        
        let padding = CGFloat(self.padding)
        let innerPadding = CGFloat(self.cellPadding)
        //let borderWidth = CGFloat(cellBorderWidth)

        let contentFrame = CGRect(x: padding, y: padding, width: self.frame.width - padding * 2, height: self.frame.height - padding * 2)
        
        var currentY: CGFloat = contentFrame.origin.y
        var addY = false
        
        var layoutIndex: Int = 0
        for (itemIndex, item) in  items.enumerated() {
            
            if layoutIndex >= LayoutTemplates[name]!.count {
                layoutIndex = 0
            }
            
            let currentLayoutCell = LayoutTemplates[name]![layoutIndex]
            
            var cellFrame = CGRect.zero
            
            switch currentLayoutCell.0 {
            case .fullWidth:
                cellFrame.origin.x = contentFrame.origin.x
                cellFrame.origin.y = currentY
                cellFrame.size.width = contentFrame.width
                addY = true
            case .halfWidth:
                switch self.shouldBeOnWhichPosition(name, itemIndex: itemIndex, layoutIndex: layoutIndex) {
                case .left:
                    if itemIndex == items.count - 1 {
                        cellFrame.origin.x = contentFrame.origin.x
                        cellFrame.origin.y = currentY
                        cellFrame.size.width = contentFrame.width
                        addY = true
                    } else {
                        cellFrame.origin.x = contentFrame.origin.x
                        cellFrame.origin.y = currentY
                        cellFrame.size.width = contentFrame.width / 2
                    }
                case .topRight:
                    cellFrame.origin.x = contentFrame.origin.x + contentFrame.width / 2
                    cellFrame.origin.y = currentY
                    cellFrame.size.width = contentFrame.width / 2
                    addY = true
                case .bottomRight:
                    cellFrame.origin.x = contentFrame.origin.x + contentFrame.width / 2
                    cellFrame.origin.y = currentY
                    cellFrame.size.width = contentFrame.width / 2
                    addY = true
                }
            }
            
            switch currentLayoutCell.1 {
            case .oneRow:
                cellFrame.size.height = contentFrame.width / 2
            case .twoRows:
                cellFrame.size.height = contentFrame.width
            }
            
            
            
            let cellView = UIView(frame: cellFrame)
            item.frame = CGRect(x: innerPadding, y: innerPadding, width: cellFrame.width - innerPadding * 2, height: cellFrame.height - innerPadding * 2)
            let innerView = item
            
            cellView.backgroundColor = UIColor.clear
            //innerView.backgroundColor = cellView.backgroundColor
            
            innerView.layer.borderColor = self.cellBorderColor.cgColor
            innerView.layer.borderWidth = CGFloat(self.cellBorderWidth)
            cellView.addSubview(innerView)
            self.addSubview(cellView)
            
            if addY || itemIndex >= items.count - 1 {
                currentY += cellFrame.size.height
                addY = false
            }

            if let delegate = delegate {
                delegate.customItemSetup?(innerView)
                
                self.frame.size.height = currentY + padding
                delegate.onLayoutHeightCalculated(currentY + padding)
            }
        }
    }

    func shouldBeOnWhichPosition(_ name: GenericLayoutName, itemIndex: Int, layoutIndex: Int) -> GenericLayoutPosition {
        if itemIndex == 0 && layoutIndex == 0 {
            return .left
        }
        
        let lastItemLayoutIndex = layoutIndex  == 0 ? LayoutTemplates[name]!.count - 1 : layoutIndex - 1

        var prelastItemLayoutIndex = 0
        
        if layoutIndex  == 0 {
            prelastItemLayoutIndex = LayoutTemplates[name]!.count - 2
        } else if layoutIndex  == 1 {
            prelastItemLayoutIndex = LayoutTemplates[name]!.count - 1
        } else {
            prelastItemLayoutIndex = layoutIndex - 1
        }
        
        // if n-1 layout is halfWidth and is on the left
        if LayoutTemplates[name]![lastItemLayoutIndex].0 == GenericLayoutCellWidth.halfWidth && shouldBeOnWhichPosition(name, itemIndex: itemIndex - 1, layoutIndex: lastItemLayoutIndex) == .left  {
            return .topRight
            // if (n-2 layout is HalfWidth and 2 rows) && (n-1 layout == OneRow)
        } else if prelastItemLayoutIndex >= 0
            && LayoutTemplates[name]![prelastItemLayoutIndex].0 == GenericLayoutCellWidth.halfWidth
            && LayoutTemplates[name]![prelastItemLayoutIndex].1 == GenericLayoutCellHeight.twoRows
            && LayoutTemplates[name]![lastItemLayoutIndex].1 == GenericLayoutCellHeight.oneRow {
                return .bottomRight
        }
        return .left
    }

    func updateLayoutCellsWithHeight(_ height: CGFloat, forItem item: UIView? = nil) {
        let padding = CGFloat(self.padding)
        let innerPadding = CGFloat(self.cellPadding)
        var totalHeight: CGFloat = 0
        
        for cell in subviews {
            if let item = item {
                item.frame.size.height = height
                if cell.subviews.first == item {
                    cell.frame.size.height = item.frame.height - innerPadding * 2
                    
                    if cell.frame.height > item.frame.height {
                        item.frame.size.height = cell.frame.height
                    }
                    
                    cell.frame.origin.y = totalHeight
                    if cell.frame.origin.x == padding {
                        totalHeight += cell.frame.height
                    }
                } else {
                    cell.frame.origin.y = totalHeight
                    if cell.frame.origin.x == padding {
                        totalHeight += cell.frame.height
                    }
                }
            } else {
                for item in items {
                    if cell.subviews.first == item as UIView {
                        cell.frame.size.height = item.frame.height - innerPadding * 2
                        cell.frame.origin.y = totalHeight
                        if cell.frame.origin.x == padding {
                            totalHeight += cell.frame.height
                        }
                    }
                }
            }
        }
        
        if let delegate = delegate {
            self.frame.size.height = totalHeight + padding * 2
            delegate.onLayoutHeightCalculated(totalHeight + padding * 2)
        }
    }
}
