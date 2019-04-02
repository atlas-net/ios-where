//
//  Search.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
Search history

Store in-app searches performed by the user
*/
class Search : AVObject {
    
    //MARK: - Properties
    
    @NSManaged
    var string: String?
    @NSManaged
    var author: AVUser?
    

    //MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(string: String, author: User) {
        super.init()
        self.string = string
        self.author = author
    }
    
}

extension Search: AVSubclassing {
    
    //MARK - Methods
    
    class func parseClassName() -> String! {
        
        return "Search"
    }
}

extension Search {
    
//    static func saveSearchWithString(string: String, completion: (Bool)->()) {
//        getSearchForString(string) { (search, error) -> Void in
//            if error != nil {
//                log.error("saveSearchWithString : \(error.localizedDescription)")
//            } else  if search != nil {
//                if search.users != nil {
//                    search.users!.addObject(search)
//                } else {
//                    let users = search.relationforKey("users")
//                    users.addObject(search)
//                }
//            }
//        }
//    }
//    
//    private static func getSearchForString(string: String, completion: (Search!, NSError!) -> Void) {
//        DataQueryProvider.searchWithString(string).getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
//            if error != nil {
//                completion(nil, error)
//            } else {
//                completion(object as! Search, error)
//            }
//        }
//
//    }
}
