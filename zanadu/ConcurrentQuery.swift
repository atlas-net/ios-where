//
//  ConcurrentQuery.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 10/30/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



/**
Concurrent Query

Allow to launch multiple queries in // and just get the result from the last one
*/
class ConcurrentSimpleQuery {
    
    //MARK: - Properties
    
    var queries = [SimpleQuery]()
    
    
    //MARK: - Initializers
    
    init(query: AVQuery) {
        add(query)
    }
    
    init(query: SimpleQuery) {
        add(query)
    }

    init(query: Query) {
        add(query)
    }
    
    
    //MARK: - Methods
    
    func add(_ query: AVQuery) {
        queries.append(SimpleQuery(query: query))
    }

    func add(_ query: SimpleQuery) {
        queries.append(query)
    }
    
    func add(_ query: Query) {
        if query is SimpleQuery {
            queries.append(query as! SimpleQuery)
        }
    }
    
    func clean() {
        let count = queries.count
        if count > 1 {
            let range = CountableRange<Int>(0...count - 1)
            queries.removeSubrange(range)
        }
    }
    
}
extension ConcurrentSimpleQuery : Query {
    //MARK: - Methods
    
    func setLimit(_ limit: Int) {
        if queries.count > 0 {

            queries.last!.setLimit(limit)
        }
    }
    
    func setCurrentPage(_ page: Int) {
        if queries.count > 0 {

            queries.last!.setCurrentPage(page)
        }
    }
    
    func executeInBackground(_ completion: @escaping ([Any]?, Error?) -> Void) {
        if queries.count > 0 {
            let query = queries.last!
            query.executeInBackground({ (objects: [Any]?, error) -> Void in
                if query == self.queries.last {
                    completion(objects, error)
                }
            })
        }
    }
    
    func executeInBackground(_ completion: @escaping (Any?, Error?) -> Void) {
        if queries.count > 0 {
            let query = queries.last!
            query.executeInBackground({ (object: Any?, error) -> Void in
                if query == self.queries.last {
                    completion(object, error)
                }
            })
        }
    }
    
    func countObjectsInBackgroundWithBlock(_ completion: @escaping (Int, Error?) -> Void) {
        if queries.count > 0 {
            let query = queries.last!
            query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                if query == self.queries.last {
                    completion(count, error)
                }
            })
        }
    }
    
    func cancel() {
        if queries.count > 0 {
            queries.last!.cancel()
        }
    }
    
    //MARK: - ViewController's Lifecycle
}
