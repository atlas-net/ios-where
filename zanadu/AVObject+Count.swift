//
//  AVObject+Count.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/14/15.
//  Copyright © 2015 Atlas. All rights reserved.
//



extension AVObject {

    func countWithValue(_ value: AnyObject, key: String, completion: @escaping (Int) -> ()) {
        let query = AVQuery(className: self.className)
        query.whereKey(key, equalTo: value)
        query.countObjectsInBackground { (count, error) -> Void in
            if error == nil {
                completion(count)
            }
        }
    }
}
