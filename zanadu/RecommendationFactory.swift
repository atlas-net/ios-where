//
//  RecommendationFactory.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/8/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Photos

enum RecommendationSaveStatus {
    case waiting
    case saving
    case failed
    case saved
}

class RecommendationFactory {

    static let sharedInstance = RecommendationFactory()
    
    var recommendationSaveStatus = RecommendationSaveStatus.waiting

    var recommendation: Recommendation?
    var photoAssets = [PHAsset]()
    var photos = [Photo]()
    var photosCenter: CLLocation?
    var venue:Venue?
    var usingSavedVenue = false
    var tags: [Tag]?
    var categorys: [Category]?
    
    var draftArray = [AnyObject]()
    
    //MARK: - Initializers
    static func created() -> Bool {
        return sharedInstance.recommendation != nil ? true : false
    }
    
    
    //MARK: - Methods
    
    static func createEmpty() {
        sharedInstance.recommendation = Recommendation()
        sharedInstance.photos.removeAll()
        if var _ = sharedInstance.tags{
        sharedInstance.tags?.removeAll()
        }
        if var _ = sharedInstance.categorys{
            sharedInstance.categorys?.removeAll()
        }
    }
    
    static func delete() {
        sharedInstance.recommendation = nil
    }
    
    static func saveStepOne(_ title: String, text: String, tags: [Tag]) {
        sharedInstance.recommendation!.title = title
        sharedInstance.recommendation!.text = text
        sharedInstance.recommendation!.author = User.current() as! User?
        sharedInstance.tags = tags
    }

    static func saveStepTwo(_ coverCropRect: CGRect, captions: [String]) {
        for (index, photo) in sharedInstance.photos.enumerated() {
            if index == 0 {
                photo.setCropRect(coverCropRect)
            } else {
                photo.rsort = index as NSNumber?
                photo.caption = captions[index - 1]
            }
        }
    }
    
    // MARK: Storage
    
    /**
     saveRecommendationWithProgress: create a new recommendation or update given recommendation
     
     Store all non trivial Recommendation components and then save the recommendation itself
     
     - parameter recommendation: the recommendation to update, if nil it will be created
     - parameter progress: the callback giving the progress status: 0 < progress < 1
     - parameter completion: the completion callback
     */

    static func saveStepThree(_ progress:@escaping (Float)->(), completion:@escaping (Bool)->()) {

        guard let recommendation = sharedInstance.recommendation,
              let _ = sharedInstance.tags,
              let venue = sharedInstance.venue,let categoryArr  = sharedInstance.categorys else {
                log.error("saveStepThree init error")
                completion(false)
            return
        }
        log.error("\(categoryArr)")

        let photosCount = sharedInstance.photos.count
        let expectedSuccess = 4 // Tags / Venue / Photos /Categorys
        var currentSuccess = 0
        
        var currentPercent:Float = 0
        var currentPhotoPercent:Float = 0

        saveCategorys { (success) -> () in
            if success {
                sharedInstance.recommendation!.addCategorys(sharedInstance.categorys!)
                currentSuccess += 1
                if currentSuccess == expectedSuccess {


                    saveRecommendation({ (success) -> () in
                        if !success{
                            completion(false)
                            deletePhotosInbackGround()
                        }
                       else{
                           completion(success)
                         }
                    })
                } else {

                    currentPercent += 1.0 / Float(expectedSuccess - 1 + photosCount)
                    progress(currentPercent + currentPhotoPercent)
                }
            } else {
                log.error("save categorys error")
                if sharedInstance.recommendationSaveStatus != .failed {
                    completion(false)
                    sharedInstance.recommendationSaveStatus = .failed
                }
            }

        }
        
        saveTags { (success) -> () in
            if success {
                sharedInstance.recommendation!.addTags(sharedInstance.tags!)
                currentSuccess += 1
                if currentSuccess == expectedSuccess {


                    saveRecommendation({ (success) -> () in
                        if !success{
                            completion(false)
                            deletePhotosInbackGround()
                        }else{
                        completion(success)
                        }

                    })
                } else {

                    currentPercent += 1.0 / Float(expectedSuccess - 1 + photosCount)
                    progress(currentPercent + currentPhotoPercent)
                }
            } else {
                log.error("save tag error")
                if sharedInstance.recommendationSaveStatus != .failed {
                    completion(false)
                    sharedInstance.recommendationSaveStatus = .failed
                }
            }
        }

        saveVenue { (success) -> () in
            if success {
                recommendation.venue = venue
                currentSuccess += 1
                if currentSuccess == expectedSuccess {


                    saveRecommendation({ (success) -> () in
                        if !success{
                            completion(false)
                            deletePhotosInbackGround()
                        }else{
                        completion(success)
                        }
                    })
                } else {

                    currentPercent += 1.0 / Float(expectedSuccess - 1 + photosCount)
                    progress(currentPercent + currentPhotoPercent)
                }
            } else {
                log.error("save venue error")
                if sharedInstance.recommendationSaveStatus != .failed {
                    completion(false)
                    sharedInstance.recommendationSaveStatus = .failed
                }
            }
        }
        
        savePhotos({ (percent) -> () in
            currentPhotoPercent = percent * Float(photosCount) / Float(expectedSuccess - 1 + photosCount)
            progress(currentPercent + currentPhotoPercent)
        }) { (success) -> () in
            if success {

                recommendation.cover = sharedInstance.photos.first
                recommendation.addPhotos(Array(sharedInstance.photos.dropFirst()))
                currentSuccess += 1
                if currentSuccess == expectedSuccess {


                    saveRecommendation({ (success) -> () in
                        if !success{
                        completion(false)
                        deletePhotosInbackGround()
                        }else{
                        completion(success)
                        }
                    })
                }
            } else {
                log.error("save photos error")
                if sharedInstance.recommendationSaveStatus != .failed {
                    completion(false)
                    sharedInstance.recommendationSaveStatus = .failed
                }
            }
        }
        
    }
    
    static fileprivate func saveTags(_ completion: @escaping (Bool)->()) {
        guard let tags = sharedInstance.tags else {
            completion(false)
            return
        }
        
        let totalCount = tags.count
        var savedCount = 0
        
        if tags.count == 0 {
            completion(true)
            return
        }
                
        for tag in tags {

            tag.saveInBackground({ (success, error) -> Void in
                if success {
                    savedCount += 1
                    if savedCount == totalCount {
                        completion(true)
                        return
                    }
                } else if error?.code == 137 { // already exist
                    DataQueryProvider.tagQueryForName(tag.name).executeInBackground { (object: Any?, error) -> () in
                        if error != nil {
                            completion(false)
                        } else {
                            if let index = tags.index(of: tag) {
                                sharedInstance.tags!.remove(at: index)
                                let addIndex = min(index, tags.count - 1)
                                if let fetchedTag = object as? Tag {
                                    sharedInstance.tags!.insert(fetchedTag, at: addIndex)
                                    savedCount += 1
                                    if savedCount == totalCount {
                                        completion(true)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    static fileprivate func saveVenue(_ completion: @escaping (Bool)->()) {
        guard let venue = sharedInstance.venue else {
            completion(false)
            return
        }
        

        venue.addObjects(from: sharedInstance.categorys!, forKey: "category")
        venue.saveInBackground { (success, error) -> Void in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static fileprivate func saveCategorys(_ completion: (Bool)->()) {


        guard let categorys  = sharedInstance.categorys else {
            completion(false)
            return
        }
        
        if categorys.count == 0 {
            completion(false)
            return
        }
        
        sharedInstance.recommendation?.addObjects(from: categorys, forKey: "category")
        completion(true)
    }
    
    static fileprivate func savePhotos(_ progress: @escaping (Float)->(), completion: @escaping (Bool)->()) {
        guard let _ = sharedInstance.recommendation else {
            completion(false)
            return
        }
        savePhotosFromIndex(0, progress: progress, completion: completion)
    }

    static fileprivate func savePhotosFromIndex(_ index:Int, progress: @escaping (Float)->(), completion:@escaping (Bool)->()) {

        
        if sharedInstance.photos[index].objectId != nil {

            progress((Float(index + 1)) / Float(sharedInstance.photos.count))
            if index >= sharedInstance.photos.count - 1 {
                completion(true)
            } else {
                savePhotosFromIndex(index + 1, progress: progress, completion: completion)
            }
        } else {

            sharedInstance.photos[index].saveInBackgroundWithProgressBlock({ (percent) -> () in
//
                progress((Float(index) + percent) / Float(sharedInstance.photos.count))
                }) { (success) -> () in
                    if success {

                        if index >= sharedInstance.photos.count - 1 {
                            completion(true)
                        } else {
                            savePhotosFromIndex(index + 1, progress: progress, completion: completion)
                        }
                    } else {



//                        sharedInstance.photos[index] = Photo(asset: sharedInstance.photoAssets[index], caption: sharedInstance.photos[index].caption)
                        completion(false)
                    }
            }
        }
    }

    static fileprivate func saveRecommendation(_ completion: @escaping (Bool)->()) {
        guard let recommendation = sharedInstance.recommendation else {
            completion(false)
            return
        }
        saveRecommendation(recommendation) { (success) -> () in
            completion(success)
        }
    }
    
    static func saveRecommendation(_ recommendation: Recommendation, completion: @escaping (Bool)->()) {
        recommendation.fetchWhenSave = true
        recommendation.saveInBackground { (success, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    static fileprivate func deletePhotosInbackGround(){


        for photo in sharedInstance.photos {
            photo.deleteEventually()
        }


    }
}
