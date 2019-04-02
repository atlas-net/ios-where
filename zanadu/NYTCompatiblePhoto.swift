//
//  Photo+NYTPhoto.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

//import NYTPhotoViewer

class NYTCompatiblePhoto: NSObject, NYTPhoto {

    var photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    
    @objc var image: UIImage {
        get {
            //TODO: change to async
            if let file = photo.file {
                if let image = UIImage(data: file.getData()!) {
                    return image
                }
            }
            return UIImage()
        }
    }

    @objc var placeholderImage: UIImage? {
        get {
            return nil
        }
    }

    @objc var attributedCaptionTitle: NSAttributedString {
        if let caption = photo.caption {
            return NSAttributedString(string: caption, attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
        return NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.white])
    }

    @objc var attributedCaptionSummary: NSAttributedString? {
        return NSAttributedString(string: "")
    }
    
    @objc var attributedCaptionCredit: NSAttributedString? {
        return NSAttributedString(string: "")
    }
    
    
    static func arrayFromPhotoArray(_ photos:[Photo]) -> [NYTCompatiblePhoto] {
        return photos.map { (photo) -> NYTCompatiblePhoto in
            return NYTCompatiblePhoto(photo: photo)
        }
    }
    
}
