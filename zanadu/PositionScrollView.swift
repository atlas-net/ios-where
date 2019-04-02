//
//  PositionScrollView.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/5/12.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit
import MJRefresh

@objc protocol positionScrollViewDelegate : NSObjectProtocol{
    
    func didSelectedTag(_ tagControl : TagControl)
    @objc optional func positionScrViewPushCallback()
}

class PositionScrollView: UIScrollView {
    
    var tags = [TagControl]()
    var positionViewDelegate : positionScrollViewDelegate?
    var emptyLabel = UILabel()
    
    var maximumHeight = CGFloat(1)

    func setDefaultCompents(_ rect : CGRect)  {
        
        frame = rect
        maximumHeight = rect.size.height
        isExclusiveTouch = true;
        self.showsVerticalScrollIndicator = true;
        self.showsHorizontalScrollIndicator = false;
        
        emptyLabel.bounds = CGRect(x: 0, y: 0, width: 150, height: 20)
        emptyLabel.center = center
        emptyLabel.textAlignment = .center
        emptyLabel.textColor =  Config.Colors.SecondTitleColor
        emptyLabel.font = UIFont.systemFont(ofSize: 20)
        emptyLabel.backgroundColor = UIColor.clear
        emptyLabel.text = NSLocalizedString("No result", comment:"无结果")
        emptyLabel.isHidden = true
        addSubview(emptyLabel)
        
        let mjFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(PositionScrollView.venuePushRefresh))
        self.mj_footer = mjFooter
        self.mj_footer.isAutomaticallyChangeAlpha = true
        self.mj_footer.isAutomaticallyHidden = true

        
    }
    
    func venuePushRefresh() {
        if let pDelegate = self.positionViewDelegate , self.positionViewDelegate!.responds(to: #selector(positionScrollViewDelegate.positionScrViewPushCallback)){
            pDelegate.positionScrViewPushCallback!()
        }
    }
    //dataSource
    func addTag(_ tag: TagControl) -> TagControl? {
        if tag.title.characters.count == 0 {
            return nil
        }
        if (!tags.contains(tag)) {
            tag.addTarget(self, action: #selector(PositionScrollView.tagTouchUpInside(_:)), for: .touchUpInside)
            tags.append(tag)
            addSubview(tag)
        }
        emptyLabel.isHidden = true

        return tag
    }
    
    
    func tagTouchUpInside(_ tagContr : TagControl){
        
        if let pDelegate = self.positionViewDelegate , self.positionViewDelegate!.responds(to: #selector(positionScrollViewDelegate.didSelectedTag(_:))){
            pDelegate.didSelectedTag(tagContr)
        }
    }
    
    func tagSize() {
        layoutTagsVertical()
    }
    fileprivate func layoutTagsVertical() -> CGPoint {
        let   _marginX:CGFloat = 16
        let   _marginY:CGFloat = 16
        let _paddingY:CGFloat = 8
        let _paddingX:CGFloat = 10
        let _font : CGFloat = 13
        var lineNumber = 1
        let  _minWidthForInput: CGFloat = 50.0

        let tagHeight = _font + _paddingY;
        let leftMargin:CGFloat = 8
        let rightMargin:CGFloat = 8

        let  currentWidth = UIScreen.main.bounds.width
        var tagPosition = CGPoint(x: _marginX*2, y: _marginY)
        
        for tag: TagControl in tags {
            let width = TagUtils.getRect(tag.title as NSString, width: currentWidth, font: UIFont.systemFont(ofSize: _font)).size.width + ceil(_paddingX*2+1)
            let tagWidth = min(width, tag.maxWidth)
            
            // Add tag at specific position
            if ((tag.superview) != nil) {
                if (tagPosition.x + tagWidth + _marginX + leftMargin > currentWidth - rightMargin) {
                    lineNumber += 1
                    tagPosition.x = _marginX
                    tagPosition.y += (tagHeight + _marginY);
                }
                
                tag.frame = CGRect(x: tagPosition.x, y: tagPosition.y, width: tagWidth, height: tagHeight)
                tagPosition.x += tagWidth + _marginX;
            }
        }
        
        // check if next tag can be added in same line or new line
        if ((currentWidth) - (tagPosition.x + _marginX) - leftMargin < _minWidthForInput) {
            lineNumber += 1
            tagPosition.x = _marginX
            tagPosition.y += (tagHeight + _marginY);
        }
        
        var positionY = (lineNumber == 1 && tags.count == 0) ? frame.size.height: (tagPosition.y + tagHeight + _marginY)
        self.contentSize = CGSize(width: self.frame.width, height: positionY + 31)
        if (positionY > maximumHeight) {
            positionY = maximumHeight
        }
        
        self.frame.size = CGSize(width: self.frame.width, height: positionY + 30)
        
        return CGPoint(x: tagPosition.x + leftMargin, y: positionY)

    }
    func scrollViewScrollToEnd() {
        let   bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height)
        self.setContentOffset(bottomOffset, animated: true)
        
    }

    //view
    func deleteAllTags(){
        tags.removeAll()
        for view in self.subviews {
            if view.isKind(of: TagControl.self)  {
                view.removeFromSuperview()
            }
        }
        emptyLabel.isHidden = false
        self.bringSubview(toFront: emptyLabel)
        self.setContentOffset(CGPoint.zero, animated: false)
    }
  
    
   
}
