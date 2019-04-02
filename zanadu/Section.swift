//
//  Section.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/21/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




enum SectionType: Int {
    case normal = 1
    case dynamic = 2
    case aroundMe = 3
}


/**
Section
*/
class Section: AVObject {
    
    // MARK: - Properties

    @NSManaged
    var limit: NSNumber?
    @NSManaged
    var type: NSNumber?
    @NSManaged
    var style: NSNumber?
    @NSManaged
    var page: NSNumber?
    @NSManaged
    var title: String?
    @NSManaged
    var recommendations: AVRelation?
    @NSManaged
    var position: NSNumber?
    @NSManaged
    var conditions: NSArray?
}

extension Section: AVSubclassing {
    class func parseClassName() -> String! {
        return "Section"
    }
}


enum SectionConditionType: String {
    case Distance = "distance"
    case Author = "author"
    case Venue = "venue"
    case Tag = "tag"
//    case Likes = "likes"
}

extension Section {
    
    func isAroundMeSection() -> Bool {
        if let conditions = conditions {
            for condition in conditions {
                if let condition = condition as? Dictionary<String,AnyObject> {
                    if let conditionType = condition["type"] as? String , conditionType == SectionConditionType.Distance.rawValue {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func queryMatchingConditionsWithLatestDate(_ latestDate:Date?,oldestDate:Date?) -> Query {
        
        let baseRequest = "select include author,include author.avatar,include venue,include cover,* from Recommendation  where status > 0 and cover is exists and title is exists and author is exists"
        let andStr = " and "

        let location = Location.shared
        
        var request = baseRequest
        
        if let conditions = conditions {
            for condition in conditions {
                if let condition = condition as? Dictionary<String,AnyObject> {
                    if let conditionType = condition["type"] as? String {
                        var requestCondition: String?

                        switch conditionType {
                        case SectionConditionType.Distance.rawValue:
                            if let radius = condition["radius"] as? String {
                                requestCondition = "venue in (select * from Venue where coordinate near geopoint(\(location.coordinate.longitude), \(location.coordinate.latitude)) max \(radius) km)"
                                
                            }
                        case SectionConditionType.Author.rawValue:
                            if let author = condition["author"] as? String {
                                "author = pointer(\"_User\", \(author))"
                            } else if let authors = condition["author"] as? [String] , authors.count > 0 {
                                
                                var authorStr = ""
                                for (index, author) in authors.enumerated() {
                                    authorStr += "pointer(\"_User\", \"\(author)\""
                                    if index < authors.count - 1 {
                                        authorStr += ", "
                                    }
                                }
                                
                                requestCondition = "authors in (\(authorStr))"
                            }
                        case SectionConditionType.Venue.rawValue:
                            if let venue = condition["venue"] as? String {
                                "venue = pointer(\"Venue\", \"\(venue)\")"
                            } else if let venues = condition["venue"] as? [String] , venues.count > 0 {
                                
                                var venueStr = ""
                                for (index, venue) in venues.enumerated() {
                                    venueStr += "pointer(\"Venue\", \"\(venue)\""
                                    if index < venues.count - 1 {
                                        venueStr += ", "
                                    }
                                }
                                
                                requestCondition = "venues in (\(venueStr))"
                            }
                        case SectionConditionType.Tag.rawValue:
                            if let tag = condition["tag"] as? String {
                                "tags = pointer(\"Tag\", \(tag))"
                            } else if let tags = condition["tag"] as? [String] , tags.count > 0 {
                                
                                var tagStr = ""
                                for (index, tag) in tags.enumerated() {
                                    tagStr += "pointer(\"Tag\", \"\(tag)\")"
                                    if index < tags.count - 1 {
                                        tagStr += ", "
                                    }
                                }
                                
                                requestCondition = "tags in (\(tagStr))"
                            }
                        default:
                            continue
                        }
                        
                        if let requestCondition = requestCondition {
                            request += andStr
                            request += requestCondition
                        }
                    }
                }
            }
        }
        if  let latestDate = latestDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let utcTimeZoneStr = formatter.string(from: latestDate)
            request += andStr
            request += "createdAt > date('\(utcTimeZoneStr)')"
        }
        if let oldestDate = oldestDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let utcTimeZoneStr = formatter.string(from: oldestDate)
            request += andStr
            request += "createdAt < date('\(utcTimeZoneStr)')"

        }
        
        if let limit = limit {
            request += " limit \(limit)"
        }else{
            request += " limit \(20)"
        }
        request += " order by -createdAt"
        

        return CQLQuery(query: request)
    }
}
