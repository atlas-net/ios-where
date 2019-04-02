

//
//  SearchPopularity.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
SearchPopularity
*/
class SearchPopularity : AVObject {
    
    //MARK: - Properties
   
    @NSManaged
    var string: String?
    @NSManaged
    var popularity: NSNumber?
    
    
    //MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(string: String, popularity: NSNumber) {
        super.init()
        self.string = string
        self.popularity = popularity
    }
}

extension SearchPopularity: AVSubclassing {
    
    //MARK - Methods
    
    class func parseClassName() -> String! {
        
        return "SearchPopularity"
    }
}

