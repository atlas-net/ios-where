//
//  AdView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




/**
RecommendationView

Display a recommendation with the following attributes:
- cover picture
- title
- number of likes
*/
class RecommendationView : UIView {
    
    //MARK: - Properties
    var recommendation: Recommendation?
    var container: ResizableLayoutItemContainer?
    var delegate: RecommendationSelectionProtocol?
    
    //MARK: - Outlets
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var coordinateImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    var sectionNum = 0
    var rowNum = 0

    
    //MARK: - Actions
    
    func onRecommendationTitleTapped() {

        if delegate != nil {
            delegate?.onRecommendationSelected(self.recommendation!)
        }
    }
    
    func onRecommendationCoverTapped() {

        if delegate != nil {
            delegate?.onRecommendationSelected(self.recommendation!)
        }
    }
    
    
    //MARK: - Methods
    
    func addTapListeners() {
        let coverTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecommendationView.onRecommendationCoverTapped))
        coverImageView.addGestureRecognizer(coverTap)
        coverImageView.isUserInteractionEnabled = true
        
        
        let titleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecommendationView.onRecommendationTitleTapped))
        titleLabel.addGestureRecognizer(titleTap)
    }
    
    
}
