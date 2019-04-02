//
//  CQLQuery.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
CQLQuery

CQLQuery wrapper
*/
class CQLQuery {
    
    //MARK: - Properties
    
    var cqlQuery: String
    var parameters: [AnyObject]?
    
    //MARK: - Initializers
    
    init(query: String, withParameters parameters: [AnyObject]? = nil) {
        self.cqlQuery = query
        self.parameters = parameters
    }
    
    
    //MARK: - Methods
    
}

extension CQLQuery : Query {
    
    func setLimit(_ limit: Int){
        log.warning("Cannot set limit on CloudQuery")
    }
    
    func setCurrentPage(_ page: Int) {
        log.warning("Cannot set current page on AVSearchQuery")
    }
    
    func executeInBackground(_ completion: @escaping ([Any]?, Error?) -> Void) {
        if let params = parameters {
            AVQuery.doCloudQueryInBackground(withCQL: cqlQuery, pvalues: params, callback: { (result, error) -> Void in
                let res = result?.results
                log.error("res \(res)")
                completion(res as [AnyObject]?, error as NSError?)
            })
        } else {
            AVQuery.doCloudQueryInBackground(withCQL: cqlQuery, callback: { (result, error) -> Void in
                completion(result?.results, error)
            })
        }
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
