//
//  Query.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
SimpleQuery

AVQuery wrapper
*/
class SimpleQuery : HashableObject {
    
    //MARK: - Properties

    var query: AVQuery
    
    
    //MARK: - Initializers
    
    init(query: AVQuery) {
        self.query = query
    }
    
    //MARK: - Methods
    
    
}

extension SimpleQuery : Query {

    func setLimit(_ limit: Int) {
        query.limit = limit
    }
    
    func setCurrentPage(_ page: Int) {
        query.skip = query.limit * page
    }
    
    func executeInBackground(_ completion: @escaping ([Any]?, Error?) -> Void) {
        self.query.findObjectsInBackground(completion)
    }
    
    func executeInBackground(_ completion: @escaping (Any?, Error?) -> ()) {
        self.query.getFirstObjectInBackground(completion)
    }
    
    func countObjectsInBackgroundWithBlock(_ completion: @escaping (Int, Error?) -> Void) {
        self.query.countObjectsInBackground(completion)
    }

    func cancel() {
        query.cancel()
    }
}
