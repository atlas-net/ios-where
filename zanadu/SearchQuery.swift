//
//  SearchQuery.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
SearchQuery

AVSearchQuery wrapper
*/
class SearchQuery {
    
    //MARK: - Properties
    
    var query: AVSearchQuery
    
    
    //MARK: - Initializers
    
    init(query: AVSearchQuery) {
        self.query = query
    }
    

    //MARK: - Methods
    
    
}

extension SearchQuery : Query {
    
    func setLimit(_ limit: Int){
        query.limit = limit
    }
    
    func setCurrentPage(_ page: Int) {
        log.warning("Cannot set current page on AVSearchQuery")
    }
    
    func executeInBackground(_ completion: @escaping ([Any]?, Error?) -> Void) {
        self.query.find(inBackground: completion)
    }
    
    func executeInBackground(_ completion: @escaping (Any?, Error?) -> ()) {
        completion(nil, NSError(domain: "MethodNotImplemented : please look at the Query protocol", code: -1, userInfo: nil))
    }
    
    func countObjectsInBackgroundWithBlock(_ completion: @escaping (Int, Error?) -> Void) {
        completion(-1, NSError(domain: "MethodNotImplemented : please look at the Query protocol", code: -1, userInfo: nil))
    }
    
    func cancel() {
        log.warning("Cannot cancel an AVSearchQuery")
    }
}
