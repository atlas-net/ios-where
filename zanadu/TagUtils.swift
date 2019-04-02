//
//  TagUtils.swift
//  TagView
//  Atlas
//  Created by Benjamin Lefebvre on 4/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit

let TagTextEmpty = "\u{200B}"

class TagUtils : NSObject {
   
   class func getRect(_ str: NSString, width: CGFloat, height: CGFloat, font: UIFont) -> CGRect {
      let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      rectangleStyle.alignment = NSTextAlignment.center
      let rectangleFontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: rectangleStyle]
      return str.boundingRect(with: CGSize(width: width, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
   }
   
   
   class func getRect(_ str: NSString, width: CGFloat, font: UIFont) -> CGRect {
      let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      rectangleStyle.alignment = NSTextAlignment.center
      let rectangleFontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: rectangleStyle]
      return str.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
   }
   
   class func widthOfString(_ str: String, font: UIFont) -> CGFloat {
      let attrs = [NSFontAttributeName: font]
      let attributedString = NSMutableAttributedString(string:str, attributes:attrs)
      return attributedString.size().width
   }
   
   class func isIpad() -> Bool {
      return UIDevice.current.userInterfaceIdiom == .pad
   }
}

extension UIColor {
   func darkendColor(_ darkRatio: CGFloat) -> UIColor {
      var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
      if (getHue(&h, saturation: &s, brightness: &b, alpha: &a)) {
         return UIColor(hue: h, saturation: s, brightness: b*darkRatio, alpha: a)
      } else {
         return self
      }
   }
}
