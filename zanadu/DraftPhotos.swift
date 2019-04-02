//
//  DraftPhotos.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/6/30.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class DraftPhotos:NSObject,NSCoding {
    //photo
    var photoCaption: String
    var photoCropData: CGRect // {"x":<int>, "y":<int>, "width":<int>, "height":<int>}
    var photoSort: String
    var photoLocation: CGPoint
    var photoDirection: String
    var photoAVFileName: String

    override init() {
        photoCaption = ""
        photoCropData = CGRect.zero
        photoSort = "0"
        photoLocation = CGPoint.zero
        photoDirection = ""
        photoAVFileName = ""
        super.init()
    }
    
    required init  (coder aDecoder: NSCoder){
        
        photoCaption=aDecoder.decodeObject(forKey: "photoCaption") as! String
        photoCropData=aDecoder.decodeCGRect(forKey: "photoCropData")
        photoSort=aDecoder.decodeObject(forKey: "photoSort") as! String
        photoLocation=aDecoder.decodeCGPoint(forKey: "photoLocation")
        photoDirection=aDecoder.decodeObject(forKey: "photoDirection") as! String
        photoAVFileName=aDecoder.decodeObject(forKey: "photoAVFileName") as! String

        super.init()
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(photoCaption, forKey: "photoCaption")
        aCoder.encode(photoCropData, forKey: "photoCropData")
        
        aCoder.encode(photoSort, forKey: "photoSort")
        aCoder.encode(photoLocation, forKey: "photoLocation")
        aCoder.encode(photoDirection, forKey: "photoDirection")
        aCoder.encode(photoAVFileName, forKey: "photoAVFileName")

    }
    
    func createPhotoInfoFrom(_ photo : Photo){
        var locationPoint = CGPoint.zero
        if let location = photo.location  {
            locationPoint = CGPoint(x: CGFloat(location.latitude), y: CGFloat(location.longitude))
        }
        
        var cropDataRect = CGRect.zero
        if let cropdata = photo.cropData{
            cropDataRect = CGRect(x: cropdata["x"] as! CGFloat, y: cropdata["y"] as! CGFloat, width: cropdata["width"] as! CGFloat, height: cropdata["height"] as! CGFloat)
        }
        
        var captionString = ""
        if let caption = photo.caption{
            captionString = caption
        }
        
        var photoStr = ""
        if let sortString = photo.sort{
            photoStr = String(describing: sortString)
        }
        
        var direction = ""
        if let directionString = photo.direction{
            direction = String(describing: directionString)
        }

        photoCaption = captionString
        photoCropData = cropDataRect
        photoSort = photoStr
        photoLocation = locationPoint
        photoDirection = direction
        if let fileName = photo.fileName{
            photoAVFileName =  String(fileName)
        }
        
    }
  
}
