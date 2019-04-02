//
//  Photo.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/20/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import Photos

/**
Photo
*/
class Photo: AVObject, AVSubclassing {

    @NSManaged
    var file: AVFile?
    
    // MARK: - Photo Variables

    @NSManaged
    var caption: String?
    @NSManaged
    var cropData: NSDictionary? // {"x":<int>, "y":<int>, "width":<int>, "height":<int>}
    @NSManaged
    var sort: NSNumber?
    
    
    // MARK: - Spatiotemporal Data Variables
    
    @NSManaged
    var location: AVGeoPoint?
    @NSManaged
    var date: Date?
    @NSManaged
    var direction: NSNumber?
    @NSManaged
    var rsort: NSNumber?

    var imageData: Data?
    @NSManaged
    var fileName: String?
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(file:AVFile) {
        super.init()
        self.file = file
    }
    
    init(asset: PHAsset, caption: String? = nil, completion: ((Photo) -> ())? = nil) {
        super.init()
        
        let imageManager = PHImageManager.default()
        
        if let location = asset.location {
            self.location = AVGeoPoint(location: location)
            self.direction = location.course as NSNumber?
        }
        
        if let date = asset.creationDate {
            self.date = date
        }
        let dataRequestOptions = PHImageRequestOptions()
        dataRequestOptions.isNetworkAccessAllowed = false
        dataRequestOptions.isSynchronous = true

        imageManager.requestImageData(for: asset, options: dataRequestOptions, resultHandler: { (data, info, orientation, objs) in
            if (info == "com.compuserve.gif"){
                self.file = AVFile(name: asset.localIdentifier, data: data!)
                self.imageData = data
                self.fileName = asset.localIdentifier
                
                if let caption = caption {
                    self.caption = caption
                }
                
                if let completion = completion {
                    completion(self)
                }
            }else{
                let requestOptions = PHImageRequestOptions()
                requestOptions.isNetworkAccessAllowed = false
                requestOptions.isSynchronous = true
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                
                imageManager.requestImage(for: asset, targetSize: CGSize(width: Config.AppConf.PhotoMaxResolution, height: Config.AppConf.PhotoMaxResolution), contentMode: .aspectFit, options: requestOptions) { (image, info) in
                    if let image = image {
                        let compressedData = UIImageJPEGRepresentation(image, Config.AppConf.PhotoCompressionFactor)
                        self.file = AVFile(name: asset.localIdentifier, data: compressedData!)
                        self.imageData = compressedData
                        self.fileName = asset.localIdentifier
                        if let caption = caption {
                            self.caption = caption
                        }
                        
                        if let completion = completion {
                            completion(self)
                        }
                    }
                }
            }

        })

        

    }
    
    init(image: UIImage, caption: String? = nil, completion: ((Photo) -> ())? = nil) {
        super.init()
        
        let imgName = "img\(image.hash)"
        let compressedData = UIImageJPEGRepresentation(image, Config.AppConf.PhotoCompressionFactor)
        self.file = AVFile(name: imgName, data: compressedData!)
        
        if let caption = caption {
            self.caption = caption
        }
        
        if let completion = completion {
            completion(self)
        }
    }
    
    func getCropRect() -> CGRect? {
        if let cropData = cropData {
            let rect = CGRect(x: cropData["x"] as! CGFloat, y: cropData["y"] as! CGFloat, width: cropData["width"] as! CGFloat, height: cropData["height"] as! CGFloat)
            return rect
        }
        return nil
    }
    
    func setCropRect(_ rect: CGRect) {
        let dict: NSDictionary = ["x": NSNumber(value: Float(rect.origin.x) as Float), "y": NSNumber(value: Float(rect.origin.y) as Float), "width": NSNumber(value: Float(rect.width) as Float), "height": NSNumber(value: Float(rect.height) as Float)]
        self.cropData = dict
    }
    
    
    func saveInBackgroundWithProgressBlock(_ progress:@escaping (Float)->(),completion:@escaping (Bool)->()) {

        self.file?.saveInBackground({ (success, error) -> Void in
            if error != nil {
                log.error("Photo file save error: \(error)")
                completion(false)
            } else if success {

                self.saveInBackground({ (success, error) -> Void in
                    if error != nil {
                        log.error("Photo save error: \(error)")
                        completion(false)
                    } else if success {

                        completion(true)
                    }
                })
            }
            }, progressBlock: { (percent) -> Void in
                progress(Float(percent)/100.0)
        })
    }
    
    override func save() -> Bool {
        self.file?.save()
        return super.save()
    }

    // MARK: - AVSublassing Methods
    
    class func parseClassName() -> String! {
        return "Photo"
        
    }
}
