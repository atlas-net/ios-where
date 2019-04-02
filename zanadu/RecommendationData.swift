//
//  RecommendationData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/28/16.
//  Copyright © 2016 Atlas. All rights reserved.
//



/**
RecommendationData

Part of Memento Design Pattern
Data saved
*/
class RecommendationData : Copying {
    
    //MARK: - Properties

    var title: String
    var text: String
    var photos = [Photo]()
    var venue:Venue
    var captions = [String]()
    var tags = [Tag]()
    var categorys = [Category]()

    
    //MARK: - Initializers

    init() {
        self.title = String()
        self.text = String()
        self.venue = Venue()
    }
    
    required init(original: RecommendationData) {
        title = String(original.title)
        text = String(original.text)
        photos = [Photo](original.photos)
        
        var venueDict = [AnyHashable: Any]()
        for (key, value) in original.venue.dictionaryForObject() {
            venueDict[key as! NSObject] = value
        }
        venue = AVObject(dictionary: venueDict) as! Venue
        
        var captionArray = [String]()
        original.captions.forEach { (caption) -> () in
            captionArray.append(String(caption))
        }
        captions = captionArray
        
        var tagArray = [Tag]()
        original.tags.forEach { (tag) -> () in
            var tagDict = [AnyHashable: Any]()
            for (key, value) in tag.dictionaryForObject() {
                tagDict[key as! NSObject] = value
            }
            tagArray.append(AVObject(dictionary: tagDict) as! Tag)
        }
        tags = tagArray
        
        var categoryArray = [Category]()
        original.categorys.forEach { (category) -> () in
            var categorysDict = [AnyHashable: Any]()
            for (key, value) in category.dictionaryForObject() {
                categorysDict[key as! NSObject] = value
            }
            categoryArray.append(AVObject(dictionary: categorysDict) as! Category)
        }
        categorys = categoryArray
    }
    
    
    //MARK: - Methods
    
    /**
    Populate the current RecommendationData object with a given Recommendation
    */
    static func fromRecommendation(_ recommendation: Recommendation, withBlock completion: @escaping (RecommendationData?) -> ()) {
        let data = RecommendationData()
        if let title = recommendation.title {
            data.title = title
        }
        if let text = recommendation.text {
            data.text = text
        }
        
        if let venue = recommendation.venue {
            data.venue = venue
        }
        
        var replies = 0
        let expectedReplies = 3
        
        recommendation.getTagsWithBlock { (tags) -> () in
            if let tags = tags {
                data.tags = tags
            }
            replies += 1
            if replies == expectedReplies {
                completion(data)
            }
        }
        
        recommendation.getPhotosWithBlock { (photos) -> () in
            if let photos = photos {
                data.photos = photos
            }
            replies += 1
            if replies == expectedReplies {
                completion(data)
            }
        }
        
        recommendation.getCategorysWithBlock { (categorys) in
            if let categorys = categorys{
                data.categorys = categorys
            }
            replies += 1
            if replies == expectedReplies {
                completion(data)
            }
        }
    }
    
    /**
     Export RecommendationData to a given Recommendation. If no recommendation passed as argument, it will create a new one
     */
    func toRecommendation(_ recommendation: Recommendation?) -> Recommendation {
        let newRecommendation: Recommendation
        if let recommendation = recommendation {
            newRecommendation = recommendation
        } else {
            newRecommendation = Recommendation()
        }

        newRecommendation.title = self.title
        newRecommendation.text = self.text
        newRecommendation.venue = self.venue

        newRecommendation.addPhotos(photos)
        newRecommendation.addTags(tags)

        return newRecommendation
    }
     func savePhotos( _ completion:@escaping (Bool)->()) {
        let totalCount = self.photos.count
        var savedCount = 0
        if photos.count == 0 {
            completion(true)
            return
        }
        for photo in self.photos{
            photo.saveInBackgroundWithProgressBlock({ (percent) -> () in
            }) { (success) -> () in
                if success {
                    savedCount += 1
                    if savedCount >= totalCount {
                        completion(true)
                    } 
                } else {
                    completion(false)
                }
            }
            
        }
        
    }

}
