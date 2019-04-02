//
//  Story.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/20/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import CoreLocation

enum RecommendationContentType: Int {
    case recommendation = 1
    case list = 2
}


/**
Recommendation
*/
class Recommendation: AVObject, AVSubclassing {

    // MARK: - Properties

    @NSManaged
    var author: User?
    @NSManaged
    var title: String?
    @NSManaged
    var text: String?
    @NSManaged
    var cover: Photo?
    @NSManaged
    var photos: AVRelation?
    @NSManaged
    var tags: AVRelation?
    @NSManaged
    var comments: AVRelation?
    @NSManaged
    var likes: NSNumber?
    @NSManaged
    var venue: Venue?
    @NSManaged
    var type: NSNumber?
    @NSManaged
    var shortId: String?
    @NSManaged
    var status: NSNumber?
    @NSManaged
    var categorys: AVRelation?
    @NSManaged
    var isHot: NSNumber?
    @NSManaged
    var isNew: NSNumber?

    //MARK: - Methods
    
    func getTagsWithBlock(_ completion:@escaping ([Tag]?)->()) {
        if tags == nil {
            tags = relation(forKey: Config.AVOSCloud.RecommendationTagsAVRelation)
        }
        tags!.query().findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects as? [Tag] {
                completion(objects)
            } else {
                completion(nil)
            }
        }
    }
    
    func getCategorysWithBlock(_ completion:@escaping ([Category]?)->()) {
        if categorys == nil {
            categorys = relation(forKey: Config.AVOSCloud.RecommendationCategoryAVRelation)
        }
        categorys!.query().findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects as? [Category] {
                completion(objects)
            } else {
                completion(nil)
            }
        }
    }

    // disable the recommendation
    func  disableTheRecommendationWithBlock(_ completion:@escaping (Bool)->()){
        self.status = 0
        self.saveInBackground { (success,error) -> Void in
            if success{
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    
    func addTag(_ tag: Tag) {
        if tags == nil {
            tags = relation(forKey: Config.AVOSCloud.RecommendationTagsAVRelation)
        }
        tags!.add(tag)
    }

    func addTags(_ tagArray: [Tag]) {
        for tag in tagArray {
            addTag(tag)
        }
    }

    func addCategory(_ category: Category) {
        if categorys == nil {
            categorys = relation(forKey: Config.AVOSCloud.RecommendationCategoryAVRelation)
        }
        categorys!.add(category)
    }
    
    func addCategorys(_ categoryArray: [Category]) {
        for category in categoryArray {
            addCategory(category)
        }
    }
    
    func removeCategory(_ category: Category) {
        if categorys == nil {
            categorys = relation(forKey: Config.AVOSCloud.RecommendationCategoryAVRelation)
        }
        categorys!.remove(category)
    }

    func getPhotosWithBlock(_ completion:@escaping ([Photo]?)->()) {
        if photos == nil {
            photos = relation(forKey: Config.AVOSCloud.RecommendationPhotosAVRelation)
        }
        photos!.query().findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects as? [Photo] {
                completion(objects)
            } else {
                completion(nil)
            }
        }
    }
    
    func addPhotos(_ photoArray: [Photo]) {
        for photo in photoArray {
            addPhoto(photo)
        }
    }
    
    func addPhoto(_ photo: Photo) {
        if photos == nil {
            photos = relation(forKey: Config.AVOSCloud.RecommendationPhotosAVRelation)
        }
        photos!.add(photo)
    }
    
    func removePhoto(_ photo: Photo) {
        if photos == nil {
            photos = relation(forKey: Config.AVOSCloud.RecommendationPhotosAVRelation)
        }
        photos!.remove(photo)
    }
    
    
    //MARK: - AVSublassing Methods
    class func parseClassName() -> String! {
        return "Recommendation"
    }
    
    
    /**
    Get the recommendation's distance to a given point
    
    Returns the distance in kilometers. If an error appened the returned distance will be < 0 (-1 if request error, -2 if Venue nil, -3 if Venue coordinate nil)
    
    - parameter location:   the point used to calculate distance
    - parameter completion: the completion callback having the distance as parameter
    */
    func distanceToLocation(_ location: CLLocation, completion: @escaping (Double) -> ()) {
        if let venue = venue {
            if venue.isDataAvailable() {
                if let coordinate = venue.coordinate {
                    let distance: Double = coordinate.distanceInKilometers(to: AVGeoPoint(location: location))
                    completion(distance)
                } else {
                    completion(-3)
                }
            } else {
                venue.fetchIfNeededInBackground({ (object, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                        completion(-1)
                    } else if object == nil {
                        completion(-2)
                    } else {
                        guard let coordinate = (object as! Venue).coordinate else {
                            completion(-3)
                            return
                        }
                        let distance: Double = coordinate.distanceInKilometers(to: AVGeoPoint(location: location))
                        completion(distance)
                    }
                })
            }
        } else {
            completion(-2)
        }
    }
    
}
