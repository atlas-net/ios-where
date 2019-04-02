
//
//  User+Follow.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 2/4/16.
//  Copyright © 2016 Atlas. All rights reserved.
//


enum FollowRelationState {
    case following
    case followed
    case bothFollowing
    case noRelations
}

/**
 Provide helper methods for the Follower/Followee relation
 */
extension User {

    /**
     Give the state of the relation between current User and a target User
     
     - parameter target:     the target User
     - parameter completion: the completion block giving back the relation state
     */
    func followStateForUser(_ target:User, withBlock completion:@escaping (FollowRelationState?, NSError?)->()) {
        let followeeQuery = self.followeeQuery()
        followeeQuery.whereKey("followee", equalTo: target)
        followeeQuery.countObjectsInBackground { (count, error) -> Void in
            if error != nil {
                completion(nil, error as NSError?)
            } else if count > 0 {
                let followerQuery = self.followerQuery()
                followerQuery.whereKey("follower", equalTo: target)
                followerQuery.countObjectsInBackground { (count, error) -> Void in
                    if error != nil {
                        completion(nil, error as NSError?)
                    } else if count > 0 {

                        completion(.bothFollowing, nil)
                    } else {

                        completion(.following, nil)
                    }
                }
            } else {
                let followerQuery = self.followerQuery()
                followerQuery.whereKey("follower", equalTo: target)
                followerQuery.countObjectsInBackground { (count, error) -> Void in
                    if error != nil {
                        completion(nil, error as NSError?)
                    } else if count > 0 {

                        completion(.followed, nil)
                    } else {

                        completion(.noRelations, nil)
                    }
                }
            }
        }
    }
}
