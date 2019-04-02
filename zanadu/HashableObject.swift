//
//  HashableObject.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 10/30/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

/**
HashableObject

Object with a unique ID
*/
class HashableObject : Hashable {

    //MARK: - Static
    
    static var nextUid = 1
    static func generateUid() -> Int {
        nextUid += 1
        return nextUid
    }

    
    //MARK: - Properties
    
    let uid: Int
    
    var hashValue: Int {
        return self.uid
    }

    //MARK: - Initializers

    init() {
        uid = HashableObject.generateUid()
    }
}


//MARK: - Equatable protocol

func ==(lhs: HashableObject, rhs: HashableObject) -> Bool {
    return lhs.uid == rhs.uid
}
