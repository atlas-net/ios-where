//
//  RecommendationState.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/28/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

enum RecommendationStateTitle: String {
    case Initial = "Initial"
    case Edit = "Edit"
//    case EditTitle = "EditTitle"
//    case EditText = "EditText"
//    case ChangeCover
//    case AddPhoto
//    case RemovePhoto
//    case AddTag
//    case RemoveTag
}

/**
RecommendationState

Keeps data corresponding to a recommendation's state

*/
class RecommendationState : Copying {
    
    //MARK: - Properties
    
    var title: String
    var data: RecommendationData
    
    
    //MARK: - Initializers
    
    init(title: String, recommendationData: RecommendationData) {
        self.title = title
        self.data = recommendationData
    }
    
    required init(original: RecommendationState) {
        self.title = String(original.title)
        self.data = RecommendationData(original: original.getData())
    }
    
    
    //MARK: - Methods
    
    func getData() -> RecommendationData {
        return data
    }
}
