//
//  Tag.swift
//  TagView
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/24/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import UIKit
public protocol TagControlDelegate {
        func TagControlDelegateDidDeleteTag(_ tag:AnyObject)
}

class TagControl : UIControl {
    
    //MARK: - Public Properties
    //__________________________________________________________________________________
    //
    
    /// retuns title as description
    override var description : String {
        get {
            return title
        }
    }
    ///show delete Btn  or not
    var isShowDeleteBtn = false
    ///tagcontroldelegate
    var tagDelete:TagControlDelegate?
    /// default is ""
    var title = ""
    
    /// default is nil. Any Custom object.
    var object: AnyObject?
    
    /// default is false. If set to true, tag can not be deleted
    var sticky = false
    
    /// Tag Title color
    var tagTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    
    /// Tag background color
    var tagBackgroundColor = Config.Colors.TagViewColor
    
    /// Tag title color in selected state
    var tagTextHighlightedColor: UIColor?
    
    /// Tag backgrould color in selected state
    var tagBackgroundHighlightedColor: UIColor?
    
    /// Tag background color in selected state. It doesn't have effect if 'tagBackgroundHighlightedColor' is set
    var darkRatio: CGFloat = 0.75
    
    /// Tag border width
    var borderWidth: CGFloat = 0.0
    
    ///Tag border color
    var borderColor: UIColor = UIColor.black
    
    /// default is 200. Maximum width of tag. After maximum limit is reached title is truncated at end with '...'
    fileprivate var _maxWidth: CGFloat? = 200
    var maxWidth: CGFloat {
        get{
            return _maxWidth!
        }
        set (newWidth) {
            if (_maxWidth != newWidth) {
                _maxWidth = newWidth
                sizeToFit()
                setNeedsDisplay()
            }
        }
    }
    
    /// returns true if tag is selected
    override var isSelected: Bool {
        didSet (newValue) {
            setNeedsDisplay()
        }
    }
    
    //MARK: - Initializers
    //__________________________________________________________________________________
    //
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(title: "")
    }
    
    convenience init(title: String) {
        self.init(title: title, object: title as AnyObject?);
    }
    
    init(title: String, object: AnyObject?) {
        self.title = title
        self.object = object
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }

    
    //MARK: - Drawing code
    //__________________________________________________________________________________
    //
    override func draw(_ rect: CGRect) {
        var deleteBtnWidth:CGFloat = 0
        if isShowDeleteBtn{
            deleteBtnWidth = 20
            let deleteBtn = UIButton(frame: CGRect(x: self.bounds.size.width - 20,y: 0,width: 15,height: self.bounds.size.height))
            deleteBtn.backgroundColor = UIColor.clear
            let img = UIImage(named: "deleteTag")
            deleteBtn.setImage( img, for: UIControlState())
            deleteBtn.setImage(img, for: UIControlState.highlighted)
            deleteBtn.addTarget(self, action:#selector(TagControl.deleteTag), for: UIControlEvents.touchUpInside)
            self.addSubview(deleteBtn)
        }
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Rectangle Drawing
        
        // fill background
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
        
        var textColor: UIColor
        var backgroundColor: UIColor
        
        if (isSelected) {
            if (tagBackgroundHighlightedColor != nil) {
                backgroundColor = tagBackgroundHighlightedColor!
            } else {
                backgroundColor = tagBackgroundColor.darkendColor(darkRatio)
            }
            
            if (tagTextHighlightedColor != nil) {
                textColor = tagTextHighlightedColor!
            } else {
                textColor = tagTextColor
            }
            
        } else {
            backgroundColor = tagBackgroundColor
            textColor = tagTextColor
        }
        
        backgroundColor.setFill()
        rectanglePath.fill()
        
        var paddingX: CGFloat = 0.0
        var font = UIFont.systemFont(ofSize: 11)
        var tagField: TagField? {
            return superview! as? TagField
        }
        if ((tagField) != nil) {
            paddingX = tagField!.paddingX()!
            font = tagField!.tagFont()!
        }
        
        // Text
        let rectangleTextContent = title
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: rectangleStyle] as [String : Any]
        
        let maxDrawableHeight = max(rect.height , font.lineHeight)
        let textHeight: CGFloat = TagUtils.getRect(rectangleTextContent as NSString, width: rect.width, height: maxDrawableHeight , font: font).size.height
        context?.saveGState()
        context?.clip(to: rect);
        
        let textRect = CGRect(x: rect.minX + paddingX, y: rect.minY + (maxDrawableHeight - textHeight) / 2, width: min(maxWidth, rect.width - deleteBtnWidth) - (paddingX*2), height: maxDrawableHeight)
        
        rectangleTextContent.draw(in: textRect, withAttributes: rectangleFontAttributes)
        context?.restoreGState()
        
        // Border
        if (self.borderWidth > 0.0 && self.borderColor != UIColor.clear) {
            self.borderColor.setStroke()
            rectanglePath.lineWidth = self.borderWidth
            rectanglePath.stroke()
        }
    }
       func deleteTag(){
               self.tagDelete?.TagControlDelegateDidDeleteTag(self)
    }
}
