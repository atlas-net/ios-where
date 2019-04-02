//
//  RecommendationStreamDataSource.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/27/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
Encapsulate models data retrieving
*/

//enum RecommendationDataProviderRequestType {
//    case Last
//    case Custom
//}
//
//enum RecommendationDataProviderRequestOrder {
//    case All
//    case Custom
//}


class DataQueryProvider {
    
    //MARK: - Properties
    
    static let defaultCachePolicy = AVCachePolicy.networkElseCache


    //MARK: - Utils
    
    fileprivate static func searchRegexForString(_ string: String) -> String {

        return "\(string)"
    }
    
    fileprivate static func basicRecommendationAVQuery() -> AVQuery {
        let query = AVQuery(className:Recommendation.parseClassName())
        query.whereKeyExists("title")
        query.whereKeyExists("cover")
        query.whereKeyExists("author")
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.includeKey("venue")
        query.includeKey("cover")
        query.order(byDescending: "createdAt")
        query.whereKey("status", greaterThan: 0)
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return query
    }
    fileprivate static func basicRecommendationAVOrQueryWithSubQueries(_ queries: [AnyObject]!) -> AVQuery {
        let query = AVQuery.orQuery(withSubqueries: queries)
        query.whereKeyExists("title")
        query.whereKeyExists("cover")
        query.whereKeyExists("author")
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.includeKey("venue")
        query.includeKey("cover")
        query.order(byDescending: "createdAt")
        query.whereKey("status", greaterThan: 0)
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return query
    }
    
    fileprivate static func basicUserAVQuery() -> AVQuery {
        let query = AVQuery(className:User.parseClassName())
        query.order(byAscending: "nickname")
        query.includeKey("avatar")
        query.includeKey("cover")
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return query
    }
}


//MARK: - Public methods

extension DataQueryProvider {

    //MARK: - User Queries

    static func queryForLastUsers() -> Query {
        let query = DataQueryProvider.basicUserAVQuery()
        return SimpleQuery(query: query)
    }
    
    static func queryForUsersMatchingString(_ string: String) -> Query {
        let nicknameQuery = AVQuery(className: User.parseClassName())
        nicknameQuery.whereKey("nickname", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue)
        nicknameQuery.whereKeyExists("nickname")
        
        let cityQuery = AVQuery(className: User.parseClassName())
        cityQuery.whereKey("city", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue)
        cityQuery.whereKeyExists("city")
        
        let provinceQuery = AVQuery(className: User.parseClassName())
        provinceQuery.whereKey("province", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue)
        provinceQuery.whereKeyExists("province")
        
        
        let orQuery = AVQuery.orQuery(withSubqueries: [nicknameQuery, cityQuery, provinceQuery])
        
        orQuery.includeKey("avatar")
        orQuery.includeKey("cover")
        orQuery.cachePolicy = defaultCachePolicy
        orQuery.maxCacheAge = 60 * 300
        
        orQuery.order(byAscending: "nickname")
        
        return SimpleQuery(query: orQuery)
    }

    static func queryForUserNickNameMatchString(_ nickName : String) -> AVQuery {
        let nicknameQuery = AVQuery(className: User.parseClassName())
        nicknameQuery.whereKey("nickname", matchesRegex: searchRegexForString(nickName), modifiers: RegexModifier.CaseIncensitive.rawValue)
        nicknameQuery.limit = 20
        nicknameQuery.whereKeyExists("nickname")
        nicknameQuery.includeKey("avatar")
        nicknameQuery.includeKey("cover")
        nicknameQuery.cachePolicy = defaultCachePolicy
        nicknameQuery.maxCacheAge = 60 * 300
        
        nicknameQuery.order(byAscending: "nickname")
        return nicknameQuery
    }

    static func queryForUserCityMatchString(_ cityName : String)  -> AVQuery  {
        let cityQuery = AVQuery(className: User.parseClassName())
        cityQuery.whereKey("city", matchesRegex: searchRegexForString(cityName), modifiers: RegexModifier.CaseIncensitive.rawValue)
        cityQuery.limit = 20

        cityQuery.whereKeyExists("city")
        cityQuery.includeKey("avatar")
        cityQuery.includeKey("cover")
        cityQuery.cachePolicy = defaultCachePolicy
        cityQuery.maxCacheAge = 60 * 300
        
        cityQuery.order(byAscending: "nickname")
        return cityQuery

    }

    static func queryForUserProvinceMatchString(_ province : String)  -> AVQuery  {
        let provinceQuery = AVQuery(className: User.parseClassName())
        provinceQuery.whereKey("province", matchesRegex: searchRegexForString(province), modifiers: RegexModifier.CaseIncensitive.rawValue)
        provinceQuery.limit = 20

        provinceQuery.whereKeyExists("province")
        provinceQuery.includeKey("avatar")
        provinceQuery.includeKey("cover")
        provinceQuery.cachePolicy = defaultCachePolicy
        provinceQuery.maxCacheAge = 60 * 300
        provinceQuery.order(byAscending: "nickname")
        return provinceQuery

    }
    
    static func userFollowersAndFollowees(_ user: User) -> Query {
        // query all followers
        let followerQuery = AVQuery(className:"_Follower")
        followerQuery.whereKey("user", equalTo: User.current())
        
        // query all followees
        let followeeQuery = AVQuery(className:"_Followee")
        followeeQuery.whereKey("user", equalTo: User.current())

        let followerUserQuery = DataQueryProvider.basicUserAVQuery()
        followerUserQuery.whereKey("objectId", matchesKey: "follower.objectId", in: followerQuery)

        let followeeUserQuery = DataQueryProvider.basicUserAVQuery()
        followeeUserQuery.whereKey("objectId", matchesKey: "followee.objectId", in: followeeQuery)

        let orQuery = AVQuery.orQuery(withSubqueries: [followeeUserQuery, followeeUserQuery])

        orQuery.includeKey("avatar")
        orQuery.includeKey("cover")
        orQuery.cachePolicy = defaultCachePolicy
        orQuery.maxCacheAge = 60 * 300
        
        orQuery.order(byAscending: "nickname")
        
        return SimpleQuery(query: orQuery)
    }

    static func userFollowers(_ user: User) -> Query {
        // query all followers
        let followerQuery = AVQuery(className:"_Follower")
        followerQuery.whereKey("user", equalTo: user)
        followerQuery.limit = 1000
        // query all user where author in followeeQuery
        let query = DataQueryProvider.basicUserAVQuery()
        query.whereKey("objectId", matchesKey: "follower.objectId", in: followerQuery)
        query.limit = 1000
        return SimpleQuery(query: query)
    }
    
    static func userFollowees(_ user: User) -> Query {
        // query all followees
        let followeeQuery = AVQuery(className:"_Followee")
        followeeQuery.whereKey("user", equalTo: user)
        
        // query all user where author in followeeQuery
        let query = DataQueryProvider.basicUserAVQuery()
        query.whereKey("objectId", matchesKey: "followee.objectId", in: followeeQuery)
        
        return SimpleQuery(query: query)
    }
    
    static func usersFeatured() -> Query {
        let query = DataQueryProvider.basicUserAVQuery()
        query.whereKey("featured", equalTo: true)
        return SimpleQuery(query: query)
    }

    static func usersUnFollow(_ user: User) -> Query {
        let userQuery = AVQuery(className:User.parseClassName())
        userQuery.whereKey("isRecommend", greaterThan: 0)

        userQuery.order(byDescending: "updatedAt")
        
        let followeeQuery = AVQuery(className:"_Followee")
        followeeQuery.whereKey("user", equalTo: user)
        
        userQuery.whereKey("objectId", doesNotMatch: followeeQuery)
        userQuery.limit = 20

        return SimpleQuery(query: userQuery)
    }
    //MARK: - Recommendation Queries
    
    static func recommendationForObjectId(_ objectId:String) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("objectId", equalTo: objectId)
        return SimpleQuery(query: query)
    }
    
    static func queryForLastRecommendations() -> Query {
        return SimpleQuery(query: DataQueryProvider.basicRecommendationAVQuery())
    }

    static func queryForUserRecommendations(_ user: User) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("author", equalTo: user)
        return SimpleQuery(query: query)
    }
    
    static func queryForVenueRecommendations(_ venue: Venue) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("venue", equalTo: venue)
        return SimpleQuery(query: query)
    }

    static func queryForVenuesRecommendations(_ venues: [Venue]) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("venue", containedIn: venues)
        query.limit = 1000
        return SimpleQuery(query: query)
    }
    
    static func queryForVenuesRecommendations(_ venues: [Venue], forTag tag: Tag) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("venue", containedIn: venues)
        query.whereKey("tags", equalTo: tag)
        return SimpleQuery(query: query)
    }

    
    static func queryForTagRecommendations(_ tag: Tag) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("tags", equalTo: tag)
//        query.limit = 10
        // query.orderByDescending() //TODO: order by likes
        return SimpleQuery(query: query)
    }
    static func queryForTagMostLikedRecommendation(_ tag: Tag) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("tags", equalTo: tag)
        query.order(byDescending: "likes")
        query.limit = 1
        return SimpleQuery(query: query)
    }
    static func queryForPopularTagRecommendations(_ tag: Tag) -> Query {
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("tags", equalTo: tag)
        // query.orderByDescending() //TODO: order by likes
        return SimpleQuery(query: query)
    }
    
    static func queryForAroundTagRecommendations(_ location: CLLocation ,forTag tag:Tag) -> Query{
        let tagQuery = AVQuery(className:"Venue")
        tagQuery.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: location), withinMiles: 5000.0)
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("tags", equalTo: tag)
        query.whereKey("venue", matchesQuery: tagQuery)
        return SimpleQuery(query: query)
        
    }
    
    static func queryForRecommendationsMatchingString(_ string: String) -> Query {
        let query = AVQuery(className:Recommendation.parseClassName())
        query.whereKeyExists("author")
        query.includeKey("author")
//        query.includeKey("venue")
        query.whereKey("status", greaterThan: 0)
        
        let titleQuery = query
        titleQuery.whereKey("title", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue)
        
        let textQuery = query
        textQuery.whereKey("text", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        
        let orQuery = AVQuery.orQuery(withSubqueries: [titleQuery, textQuery])
        orQuery.includeKey("author")
        orQuery.includeKey("author.avatar")
        orQuery.includeKey("cover")
        
        orQuery.cachePolicy = defaultCachePolicy
        orQuery.maxCacheAge = 60 * 300
        orQuery.order(byDescending: "createdAt")

        return SimpleQuery(query: orQuery)
    }
    
    static func lastRecommendationsFromFriends() -> Query {
        // query all followee
        let followeeQuery = AVQuery(className:"_Followee")
        followeeQuery.whereKey("user", equalTo: User.current())
        // query all recommendations where author in followeeQuery
        let followeePostquery = DataQueryProvider.basicRecommendationAVQuery()
        followeePostquery.whereKey("author", matchesKey: "followee", in: followeeQuery)
        
        let minePostQuery = DataQueryProvider.basicRecommendationAVQuery()
        minePostQuery.whereKey("author", equalTo: User.current())
        let queries = [followeePostquery,minePostQuery]
        let orQuery = DataQueryProvider.basicRecommendationAVOrQueryWithSubQueries(queries)
        
        
        orQuery.order(byDescending: "updatedAt")

        orQuery.limit = 20
        return SimpleQuery(query: orQuery)
    }
    static func lastRecommendationsFromFriendsSecond() -> AVQuery {
        // query all followee
        let followeeQuery = AVQuery(className:"_Followee")
        followeeQuery.whereKey("user", equalTo: User.current()!)
        // query all recommendations where author in followeeQuery
        let followeePostquery = DataQueryProvider.basicRecommendationAVQuery()
        followeePostquery.whereKey("author", matchesKey: "followee", in: followeeQuery)
        
        let minePostQuery = DataQueryProvider.basicRecommendationAVQuery()
        minePostQuery.whereKey("author", equalTo: User.current()!)
        let queries = [followeePostquery,minePostQuery]
        let orQuery = DataQueryProvider.basicRecommendationAVOrQueryWithSubQueries(queries)
        
        
        orQuery.order(byDescending: "updatedAt")
        
        orQuery.limit = 20
        return orQuery
    }

    static func  lastRecommendationsFromFeaturedUsers() -> Query {
        // query three default user
        let defaultUserQuery = basicUserAVQuery()
        defaultUserQuery.whereKey("featured", equalTo: true)
        
        // query all recommendations by defalut three user
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("author", matchesQuery: defaultUserQuery)
        
        return SimpleQuery(query: query)
    }

    
    static func recommendationsLikedByUser(_ user: User) -> Query {
        let likesQuery = AVQuery(className: "Like")
        likesQuery.whereKey("user", equalTo: user)
        
        let query = DataQueryProvider.basicRecommendationAVQuery()
        query.whereKey("objectId", matchesKey: "like.objectId", in: likesQuery)
        
        return SimpleQuery(query: query)
        
        
//        let cqlRequest = "select * from Recommendation where objectId in (select like.objectId from Like where user = ?)"
//        let params = [user]
//        return CQLQuery(query: cqlRequest, withParameters: params)
    }
    static func latestRecommendationForLatestDate(_ latestDate:Date?,oldestDate:Date?) ->Query{
        let query = DataQueryProvider.basicRecommendationAVQuery()
//        query.whereKey("isNew", equalTo: 1)
        query.order(byDescending: "createdAt")
        if let latestD = latestDate{
            query.limit = 20
            query.whereKey("createdAt", greaterThan: latestD)
            return SimpleQuery(query: query)
        }
        if let oldestD = oldestDate{
            query.limit = 20
            query.whereKey("createdAt", lessThan: oldestD)
            return SimpleQuery(query: query)
        }
        query.limit = 20
        return SimpleQuery(query: query)

    }
    static func hotestRecommendationForLatestDate(_ latestDate:Date?,oldestDate:Date?) ->Query{
        let query = DataQueryProvider.basicRecommendationAVQuery()
//        query.whereKey("isHot", equalTo: 1)
        query.order(byDescending: "createdAt")
        if let latestD = latestDate{
            query.limit = 20
            query.whereKey("createdAt", greaterThan: latestD)
            return SimpleQuery(query: query)
        }
        if let oldestD = oldestDate{
            query.limit = 20
            query.whereKey("createdAt", lessThan: oldestD)
            return SimpleQuery(query: query)
        }
        query.limit = 20
        return SimpleQuery(query: query)

    }
    //MARK: - Venue Queries

    static func venuesAround(_ location: CLLocation, withinRadius radius: Int) -> Query {
        let query: AVQuery = AVQuery(className: "Venue")
        query.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: location), withinKilometers: Double(radius / 1000))
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return SimpleQuery(query: query)
    }
    
    static func queryForLocationVenues(_ location: CLLocation) -> Query {
        let query: AVQuery = AVQuery(className: "Venue")
        query.whereKey("coordinate", nearGeoPoint: AVGeoPoint(location: location))
        query.limit =  1000
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return SimpleQuery(query: query)
    }
    
    static func queryForLastVenues() -> Query {
        let query = AVQuery(className: Venue.parseClassName())
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        return SimpleQuery(query: query)
    }
    
    static func queryForVenuesMatchingString(_ string: String) -> AVQuery {
//        let query = AVSearchQuery.searchWithQueryString(searchRegexForString(string))
//        query.className = Venue.parseClassName()
//        query.cachePolicy = defaultCachePolicy
//        query.maxCacheAge = 60 * 300
        //return SearchQuery(query: query)
        
        let customNameQuery = AVQuery(className: Venue.parseClassName())
        customNameQuery.whereKey("customName", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue)
        customNameQuery.whereKeyExists("customName")
        
        let customAddressQuery = AVQuery(className: Venue.parseClassName())
        customAddressQuery.whereKey("customAddress", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        customAddressQuery.whereKeyExists("customName")
        
        let localityQuery = AVQuery(className: Venue.parseClassName())
        localityQuery.whereKey("locality", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        localityQuery.whereKeyExists("customName")
        
        let sublocalityQuery = AVQuery(className: Venue.parseClassName())
        sublocalityQuery.whereKey("sublocality", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        sublocalityQuery.whereKeyExists("customName")
        
        let administrativeAreaQuery = AVQuery(className: Venue.parseClassName())
        administrativeAreaQuery.whereKey("administrativeArea", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        administrativeAreaQuery.whereKeyExists("customName")
        
        let countryNameQuery = AVQuery(className: Venue.parseClassName())
        countryNameQuery.whereKey("countryName", matchesRegex: searchRegexForString(string), modifiers: RegexModifier.CaseIncensitive.rawValue + RegexModifier.Multiline.rawValue)
        countryNameQuery.whereKeyExists("customName")
        
        let orQuery = AVQuery.orQuery(withSubqueries: [customNameQuery, customAddressQuery, localityQuery, sublocalityQuery, administrativeAreaQuery, countryNameQuery])
        
        orQuery.cachePolicy = defaultCachePolicy
        orQuery.maxCacheAge = 60 * 300
        
        return orQuery
    }
    
    
    /**
     Build a query to find Venues within an area and matching the given string
     
     - parameter location: search area center coordinate
     - parameter radius:   search radius in meters
     - parameter string:   search string
     */
    static func queryForVenuesAroundLocation(_ location: CLLocation, withinRadius radius: Int, matchingString string: String) -> Query {
        let stringQuery = DataQueryProvider.queryForVenuesMatchingString(string)
        let locationQuery = DataQueryProvider.venuesAround(location, withinRadius: radius)
        let andQuery = AVQuery.andQuery(withSubqueries: [(locationQuery as! SimpleQuery).query, stringQuery])
        andQuery.cachePolicy = defaultCachePolicy
        andQuery.maxCacheAge = 60 * 300
        
        return SimpleQuery(query: andQuery)
    }
    
    
    //MARK: - Tag Queries
    
    static func tagQueryForName(_ name: String) -> Query {
        let query = AVQuery(className: Tag.parseClassName())
        query.whereKey("name", equalTo: name)
        query.cachePolicy = defaultCachePolicy
        query.maxCacheAge = 60 * 300
        
        return SimpleQuery(query: query)
    }
    //MARK: - Category Queries
    
    static func categoryQuery() -> AVQuery {
        let query = AVQuery(className: Category.parseClassName())
        query.whereKey("status", greaterThan: 0)
        query.selectKeys(["name","status"])
        query.order(byDescending: "updatedAt")
        query.cachePolicy = .cacheThenNetwork
        query.maxCacheAge = 60 * 300
        return query
    }

    static func categoryConditionQuery(_ ids:[String]) -> AVQuery {
        let query = AVQuery(className: Category.parseClassName())
        query.whereKey("objectId", containedIn: ids)
        query.selectKeys(["name","status"])
        query.order(byAscending: "createdAt")
        query.cachePolicy = .cacheElseNetwork
        query.maxCacheAge = 60 * 300
        return query
    }
    //MARK: - Comment Queries
    
    static func commentQueryForRecommendation(_ recommendation: Recommendation) -> Query {
        let query = AVQuery(className:Comment.parseClassName())
        query.whereKey("recommendation", equalTo: recommendation)
        query.whereKey("status", greaterThan: 0)
        query.includeKey("author.avatar")
        query.includeKey("responseAuthor")
        query.findObjectsInBackground { (objs, err) -> Void in
            if err != nil {
                log.error(err?.localizedDescription)
            } else {

            }
        }
      //  query.cachePolicy = defaultCachePolicy
      //  query.maxCacheAge = 60 * 300
      //  query.orderByAscending("createdAt")
        
      //
        return SimpleQuery(query: query)
    }
    
    
    //MARK: - Search Queries
    
    static func lastSearchesForCurrentUser() -> Query? {
        guard let user = User.current() else { return nil }
        
        let query = Search.query()
        query.whereKey("author", equalTo: user)
        query.order(byDescending: "createdAt")
        query.limit = 7
        return SimpleQuery(query: query)
    }
    
    static func searchWithString(_ string: String) -> Query {
        let query = Search.query()
        query.whereKey("string", equalTo: string)
        query.limit = 1
        return SimpleQuery(query: query)
    }
    
    
    //MARK: - SearchPopularity Queries

    static func searchPopularityForString(_ string: String) -> Query {
        let query = SearchPopularity.query()
        query.whereKey("string", equalTo: string)
        query.limit = 1
        return SimpleQuery(query: query)
    }
    
    static func popularSearchPopularity() -> Query {
        let query = SearchPopularity.query()
        query.order(byDescending: "popularity")
        query.limit = 5
        return SimpleQuery(query: query)
    }

    
    //MARK: - Notification Queries
    
    static func lastNotificationsForChannel(_ channel: NotificationChannel) -> Query {
        let query = Notification.query()
        query.whereKey("channel", equalTo: channel.rawValue)
        query.order(byDescending: "updatedAt")
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.limit = 20
        return SimpleQuery(query: query)
    }

    static func lastNotificationsForChannel(_ channel: NotificationChannel, andRecipient recipient: User) -> Query {
        let query = Notification.query()
        query.whereKey("channel", equalTo: channel.rawValue)
        query.whereKey("recipient", equalTo: recipient)
        query.order(byDescending: "updatedAt")
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.limit = 20
        return SimpleQuery(query: query)
    }

    static func lastNotificationsForChannels(_ channels: [NotificationChannel], andRecipient recipient: User) -> Query {

        let subQueries = channels.map({
            ZanNotificationCenter.isChannelGlobal($0) ?
                (lastNotificationsForChannel($0) as! SimpleQuery).query
                : (lastNotificationsForChannel($0, andRecipient: recipient) as! SimpleQuery).query
        })

        let compoundQuery = AVQuery.orQuery(withSubqueries: subQueries)
        compoundQuery.order(byDescending: "createdAt")
        compoundQuery.includeKey("author")
        compoundQuery.includeKey("author.avatar")
        compoundQuery.includeKey("file")
        compoundQuery.limit = 20
        return SimpleQuery(query: compoundQuery)
    }
    //Mark: - InviteCode Queries
    static func getInviteCodeWithCode(_ code:String) -> Query{
        let query = InviteCode.query()
        query.whereKey("code", equalTo: code)
        query.whereKey("isUsed",equalTo: 0)
        return SimpleQuery(query: query)
    }

    
    //MARK: - Section Queries
    static func sectionsWithPage(_ page:NSNumber) -> Query {
        let query = Section.query()
        query.cachePolicy = AVCachePolicy.networkElseCache
        query.order(byAscending: "position")
        if page == 1 {
        query.whereKey("page", equalTo: 1)
        }else{
        query.whereKey("page", notEqualTo: 1)
        }
        return SimpleQuery(query: query)
    }
    
    static func historyRecommendationForSection(_ section:Section,latestDate:Date?,oldestDate:Date?) -> Query{
        let recommendationQuery = AVQuery(className:Recommendation.parseClassName())
        recommendationQuery.whereKey("status", greaterThan: 0)
        recommendationQuery.limit = 20
        let query = SectionItem.query()
         query.whereKey("section", equalTo: section)
        //query.whereKey("recommendation", matchesQuery: recommendationQuery)
         query.order(byDescending: "createdAt")
         query.includeKey("recommendation")
         query.includeKey("recommendation.author")
         query.includeKey("recommendation.author.avatar")
         query.includeKey("recommendation.venue")
         query.includeKey("recommendation.cover")

        
        if let latestD = latestDate{
           query.whereKey("createdAt", greaterThan: latestD)
             return SimpleQuery(query: query)
        }
        if let oldestD = oldestDate{
            query.limit = 20
            query.whereKey("createdAt", lessThan: oldestD)
             return SimpleQuery(query: query)
            
        }
        query.limit = 20
        return SimpleQuery(query: query)
        
       
    }
    
    
    //MARK: - Like Queries
    static func likesForRecommendation(_ recommendation: Recommendation) -> Query {
        let query = Like.query()
        query.whereKey("like", equalTo: recommendation)
        query.includeKey("user.avatar")
        return SimpleQuery(query: query)
    }
    
    
    //MARK - ListItem Queries
    
    static func listItemsForRecommendation(_ recommendation: Recommendation) -> Query {
        let query = ListItem.query()
        query.whereKey("recommendation", equalTo: recommendation)
        query.order(byAscending: "sort")
        query.cachePolicy = .cacheThenNetwork
        return SimpleQuery(query: query)
    }
    
    
    //MARK - Report Queries
    
    static func reportsForUser(_ user: User, andRecommendation recommendation: Recommendation, validOnly: Bool = false) -> Query {
        let query = Report.query()
        query.whereKey("sender", equalTo: user)
        query.whereKey("recommendation", equalTo: recommendation)
        if validOnly {
            query.whereKey("valid", equalTo: 1)
        }
        return SimpleQuery(query: query)
    }
    //MARK: - FousquareId Queries
    
    static func queryRecommendationsByFoursquareId(_ idStringArray : [String]) -> Query {
        let customIdQuery = AVQuery(className: Venue.parseClassName())
        customIdQuery.whereKey("id", containedIn: idStringArray)
        customIdQuery.includeKey("id")

        return SimpleQuery(query: customIdQuery)
    }
    
//    static func cancleCurrentQuery(){
//        AVQuery.cancel(SimpleQuery)
//
//    }
    static func queryRecommendationMatchPhotoCaptionNotIn(_ string : String,objectIds : [String]) -> AVQuery {
        
        let query = AVQuery(className:Recommendation.parseClassName())
        query.whereKeyExists("author")
        query.whereKey("status", greaterThan: 0)
        query.includeKey("author")
        query.includeKey("author.avatar")
        query.includeKey("cover")
        query.whereKeyExists("cover")
        
        let photoQuery = AVQuery(className: Photo.parseClassName())
        photoQuery.whereKey("caption", contains: string)
        query.whereKey("photos", matchesQuery: photoQuery)
        query.limit = 20
        query.whereKey("objectId", notContainedIn: objectIds)

        return query
    }

}

//MARK CQL Query
extension DataQueryProvider{

    static  func queryRecommendationMatchTextNotIn(_ string : String , objectIds :[String]) -> String {
        var recommendationId = ""
        if objectIds.count > 0 {
            for (index,objextId) in objectIds.enumerated() {
                recommendationId += "'\(objextId)',"
                if index ==  objectIds.count - 1{
                    recommendationId += "'\(objextId)'"
                }
            }

        }
        
        let  filterCondation = " and objectId not in (\(recommendationId))"
        let baseRequest = "select include author,include author.avatar,include venue,include cover,* from Recommendation where status > 0"
        var request = baseRequest
        request += filterCondation
        let baseCondition = " and cover is exists and author is exists"
        request += baseCondition
        let string:String = string
        let titleCondition = " and text like '%\(string)%'"
        request += titleCondition
        let  requestOrder = " order by updatedAt desc"
        request += requestOrder
        let limit = " limit 20"
        request += limit
        

        return request

    }
    
    static func queryRecommendationMatchTitleNotIn(_ string : String , objectIds :[String]) -> String{
        var recommendationId = ""
        if objectIds.count > 0{
            for (index,objextId) in objectIds.enumerated() {
                recommendationId += "'\(objextId)',"
                if index ==  objectIds.count - 1{
                    recommendationId += "'\(objextId)'"
                }
            }
        }
        let  filterCondation = " and objectId not in (\(recommendationId))"

        let baseRequest = "select include author,include author.avatar,include venue,include cover,* from Recommendation where status > 0"
        var request = baseRequest
        request += filterCondation
        let baseCondition = " and cover is exists and author is exists"
        request += baseCondition
        let titleCondition = " and title regexp '(?i)\(string)'"
        request += titleCondition
        let  requestOrder = " order by updatedAt desc"
        request += requestOrder
        let limit = " limit 20"
        request += limit
        return request
        
    }
    
}
