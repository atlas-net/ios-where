//
//  SearchResultFetcher.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/3/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
Fetch full AVObjects from partial AVObjects returned by an AVSearchQuery.

Allows to stop old queries (useful for autocompletion requests to avoid results corresponding to the previous typing state)
*/
class SearchResultFetcher : NSObject {
    
    //MARK: - Properties
    var tmpQueries = [AVQuery]()

    //MARK: - Outlets
    
    //MARK: - Actions
    
    //MARK: - Methods
    
    func emptyTmpQueries() {
        for query in tmpQueries {
            query.cancel()
        }
        tmpQueries.removeAll(keepingCapacity: true)
    }
    
    func fetch<T:AVObject>(_ partial:T, completion: @escaping (T?, NSError?)->()) {
        let query = T.query()
        query.whereKey("objectId", equalTo: partial.objectId)
        tmpQueries.append(query)
        query.findObjectsInBackground { (objects, error) -> Void in
            if objects != nil && (objects?.count)! > 0 {
                completion(objects?.first as?  T, error as NSError?)
            } else {
                completion(nil, error as NSError?)
            }
        }
    }
}
