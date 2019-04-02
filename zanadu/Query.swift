//
//  Query.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation

/**
Query Wrapping Protocol

Allows to use all the types of Queries (AVQuery, AVSearchQuery, CQL Queries...)

*/
protocol Query : AnyObject {
    
    //MARK: - Required Methods
    
    /**
    Set limit of objects fetched per query
    
    - parameter limit: the limit
    */
    func setLimit(_ limit: Int)

    /**
    Set the current page in order to let the query know how many objects it should skip
    
    - parameter page: the current page number (starts at 0)
    */
    func setCurrentPage(_ page: Int)
    
    func executeInBackground(_ completion: @escaping ([Any]?, Error?) -> ())
    
    
    //MARK: - Optional Methods
    
    // can't be optional in Swift(for now?), it would require an @objc protocol
    // that implies a conflict between the 2 executeInBackground methods
    /**
    Should be optional, if it returns nothing it's "Normal" the class
    following this protocol have to implement it (even if empty)
    */
    func executeInBackground(_ completion: @escaping (Any?, Error?) -> ())

    func countObjectsInBackgroundWithBlock(_ completion: @escaping (Int, Error?) -> Void)

    func cancel()
}
