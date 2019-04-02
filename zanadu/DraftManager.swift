//
//  DraftManager.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/7/1.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit

class DraftManager: NSObject {
    
    static  func saveDraftToSandBox(_ array : [AnyObject]){
        let path = self.savePath()
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: path)
        let data = NSKeyedArchiver.archivedData(withRootObject: array)
        if (!exists) {
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
        let flag =  (try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        
        if !flag {

        }
        
        
    }
    
    static func refreshSandboxData(){
        let  objects = RecommendationFactory.sharedInstance.draftArray
        
        if objects.count > 0 {
            if objects.count == 1{
                let draftRecommendationVenue = [DraftRecommendationVenue]()
                
                RecommendationFactory.sharedInstance.draftArray.append(draftRecommendationVenue as AnyObject)
                
            }
            if objects.count == 2{
                let draftCategorys = [DraftCategorys]()
                
                RecommendationFactory.sharedInstance.draftArray.append(draftCategorys as AnyObject)
                
                let draftTags = [DraftTags]()
                
                RecommendationFactory.sharedInstance.draftArray.append(draftTags as AnyObject)
            }
            
            let  photos = objects[0] as?[DraftPhotos]
            for photo in photos! {

            }
            RecommendationFactory.sharedInstance.draftArray.remove(at: 0)
            RecommendationFactory.sharedInstance.draftArray.insert(photos! as AnyObject, at: 0)
            
            let recommendationVenue = objects[1] as? DraftRecommendationVenue
            
            if let title = RecommendationFactory.sharedInstance.recommendation?.title {
                
                recommendationVenue?.recommendationTitle = title
            }
            if let text  = RecommendationFactory.sharedInstance.recommendation?.text {
                recommendationVenue?.recommendationText = text
            }

            
            
            //category
            if let categorys = RecommendationFactory.sharedInstance.categorys {
                var draftCategorys = [DraftCategorys]()
                
                for category in categorys {
                    let draftCategory = DraftCategorys()
                    draftCategory.createCategoryInfo(category)
                    draftCategorys.append(draftCategory)
                }
                RecommendationFactory.sharedInstance.draftArray.remove(at: 2)
                RecommendationFactory.sharedInstance.draftArray.insert(draftCategorys as AnyObject, at: 2)

            }
            
            //tags
            
            if let tags = RecommendationFactory.sharedInstance.tags {
                var draftTags = [DraftTags]()
                
                for tag in tags {
                    let draftTag = DraftTags()
                    draftTag.createTagInfo(tag)
                    draftTags.append(draftTag)
                }
                RecommendationFactory.sharedInstance.draftArray.remove(at: 3)
                RecommendationFactory.sharedInstance.draftArray.insert(draftTags as AnyObject, at: 3)

            }
            
        }else{

            
        }
        
    }
    
    static  func savePath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        let destinationPath = documentsPath + "/draft.plist"
        return destinationPath
    }
    
    static func removeDraftFromSandBox(){
        let path = self.savePath()
        let imageDiroctoryPath = self.createImageFilePath()
        
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: path)
        
        if exists {
            do {
                try   fileManager.removeItem(atPath: path)
            }
            catch{

            }
        }
        let exists1 = fileManager.fileExists(atPath: imageDiroctoryPath)
        
        if exists1 {
            do {
                try   fileManager.removeItem(atPath: imageDiroctoryPath)
            }
            catch{

            }
        }

        Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
        
        
    }
    
    static  func readDraftFromeSandBox() -> [AnyObject]{
        let path = self.savePath()
        if  let objects = NSKeyedUnarchiver.unarchiveObject(withFile: path){

            return objects as! [AnyObject]

        }
        return ["error" as AnyObject]
    }

    static func buildFactoryAndDraftArray(){
        let isCreated = RecommendationFactory.created()
        if !isCreated {
            RecommendationFactory.createEmpty()
        }
        var  objects = RecommendationFactory.sharedInstance.draftArray
        
        if objects.count <= 0 {
        let path = self.savePath()
        if  let objectS = NSKeyedUnarchiver.unarchiveObject(withFile: path){

            objects = (objectS as? [AnyObject])!
            RecommendationFactory.sharedInstance.draftArray = objects
            
        }

        }
    }
    
    static func reSetRecommendationFactory(){
        
        var  objects = RecommendationFactory.sharedInstance.draftArray
        
        if objects.count > 0 {
            
        var photos = [DraftPhotos]()
        var recommendationVenue = DraftRecommendationVenue()
        var currentDraftCategorys = [DraftCategorys]()
        var currentTags = [DraftTags]()

        if objects.count == 2 {
            photos = (objects[0] as?[DraftPhotos])!
            recommendationVenue = (objects[1] as? DraftRecommendationVenue)!
        }else if objects.count == 3 {
            photos = (objects[0] as?[DraftPhotos])!
            recommendationVenue = (objects[1] as? DraftRecommendationVenue)!
            currentDraftCategorys = (objects[2] as? [DraftCategorys])!
        }else if objects.count == 4 {
            photos = (objects[0] as?[DraftPhotos])!
            recommendationVenue = (objects[1] as? DraftRecommendationVenue)!
            currentDraftCategorys = (objects[2] as? [DraftCategorys])!
            currentTags = (objects[3] as? [DraftTags])!
        }else if objects.count > 4{
            for (index,_) in objects.enumerated() {
                if index > 3 {
                    objects.remove(at: index)
                }
            }
            photos = (objects[0] as?[DraftPhotos])!
            recommendationVenue = (objects[1] as? DraftRecommendationVenue)!
            currentDraftCategorys = (objects[2] as? [DraftCategorys])!
            currentTags = (objects[3] as? [DraftTags])!

        }
        
        RecommendationFactory.sharedInstance.photos.removeAll(keepingCapacity: true)
        
        if photos.count > 0 {
            for (index,draftPhoto) in photos.enumerated() {
                let basePath = DraftManager.createImageFilePath() + "/image"
                let dataPath = basePath + String(index + 1)
                var imageData = Data()
                let fileManager = FileManager.default
                
                if  let object = fileManager.contents(atPath: dataPath){
                    imageData = object
                }
                
                let key = dataPath
                let imageName = Foundation.UserDefaults.standard.object(forKey: key)
                let file : AVFile!
                if let imgName = imageName {
                     file = AVFile.init(name: imgName as! String, data: imageData)
                }else{
                    file = AVFile.init(name: draftPhoto.photoAVFileName, data: imageData)
                }

                let photo = Photo.init(file: file)
                photo.caption = draftPhoto.photoCaption
                photo.setCropRect(draftPhoto.photoCropData)
                RecommendationFactory.sharedInstance.photos.append(photo)
                
            }
        }


        
        //venue
        let venue = Venue()
        venue.customName = recommendationVenue.venueCustomName
        venue.coordinate = AVGeoPoint.init(latitude: Double((recommendationVenue.venueCoordinate.x)), longitude: Double((recommendationVenue.venueCoordinate.y)))
        venue.administrativeArea = recommendationVenue.venueAdministrativeArea
        venue.countryCode = recommendationVenue.venueCountryCode
        venue.countryName = recommendationVenue.venueCountryName
        venue.customAddress = recommendationVenue.venueCustomAddress
        venue.fullAddress = recommendationVenue.venueFullAddress
        venue.locality = recommendationVenue.venueLocality
        venue.sublocality = recommendationVenue.venueSublocality
        venue.phone = recommendationVenue.venuePhone
        venue.placeName = recommendationVenue.venuePlaceName
        venue.popularity = Int(recommendationVenue.venuePopularity)
        venue.subthoroughfare = recommendationVenue.venueSubthoroughfare
        venue.thoroughfare = recommendationVenue.venueThoroughfare
        
        RecommendationFactory.sharedInstance.venue = venue


        
        RecommendationFactory.sharedInstance.recommendation?.title = recommendationVenue.recommendationTitle
        RecommendationFactory.sharedInstance.recommendation?.text = recommendationVenue.recommendationText


        var tags = [Tag]()
        if currentTags.count > 0 {
            for draftTag in currentTags {
               let tag = Tag()
                tag.name = draftTag.tagName
                let string = draftTag.tagPopularity
                tag.popularity = NSNumber(value: Int(string)! as Int)
                tags.append(tag)
            }
        }
        RecommendationFactory.sharedInstance.tags = tags


        
        var categoryIdS = [String]()
        
        if currentDraftCategorys.count > 0 {
            for draftCategory in currentDraftCategorys {
                categoryIdS.append(draftCategory.categoryObjectId)
            }
        }
        let query = DataQueryProvider.categoryConditionQuery(categoryIdS)
        query.findObjectsInBackground { (objects:[Any]?, error) in
            if error != nil {
                log.error(error?.localizedDescription)
            }else{
                if let categorys = objects as? [Category]{
                    
                  RecommendationFactory.sharedInstance.categorys = categorys
                }else{

                }
            }
        }
        
        }else{
           DraftManager.buildFactoryAndDraftArray()
        }
    }

    
    
    static  func saveImagetoSandboxWithPath(_ imageData :Data ,pathExtension : String) {
        let imagePath = DraftManager.createImageFilePath() + "/" + pathExtension
        let fileManager = FileManager.default
        
        let exists = fileManager.fileExists(atPath: imagePath)
        if (!exists) {
            do{
                try fileManager.createDirectory(atPath: DraftManager.createImageFilePath(), withIntermediateDirectories: true, attributes: nil)
            }
            catch{

            }
        }
        
        try? imageData.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
        
    }
    static func createImageFilePath() -> String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        let imagePath = documentsPath + "/" + "images"
        
        return imagePath
    }
    
}

