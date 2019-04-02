//
//  RecommendationViewCell.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/7/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation

class RecommendationViewCell: UITableViewCell {

    
    //Mark: - Properties
    
    var recommendation: Recommendation?
    var delegate: RecommendationSelectionProtocol?
    var loadingV = LoadingView()
    var tapOverlayEnabled: Bool = false {
        didSet {
            tapOverlay.isHidden = !tapOverlayEnabled
        }
    }
    
    
    //MARK: - Gesture Recognizers
    var coverTap: UITapGestureRecognizer?
    var overlayTap: UITapGestureRecognizer?
    var authorTap: UITapGestureRecognizer?

    //MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var authorImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tapOverlay: UIView!
    
    @IBOutlet weak var effectCover: UIImageView!
    
    //userProfilePage
    
    @IBOutlet weak var likeAndCommentView: UIView!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var commentCountLabel: UILabel!
    //MARK: - Actions
    
    func onAuthorImageTapped() {

        if delegate != nil {
            delegate?.onAuthorSelected!(self.recommendation!.author!)
        }
    }

    func onRecommendationCellTapped() {

        if delegate != nil {
            delegate?.onRecommendationSelected(self.recommendation!)
        }
    }

    func onRecommendationCellOverlayTapped() {

        if delegate != nil {
            delegate?.onRecommendationSelected(self.recommendation!)
        }
    }


    //MARK: - Initializers


    //MARK: - Methods

    func setupCoverWithImage(_ image: UIImage) {
        coverImage.image = image
        coverImage.layer.cornerRadius = 5//coverImage.frame.width / 60
                coverImage.clipsToBounds = true
        effectCover.layer.cornerRadius = 5//coverImage.frame.width / 60
        effectCover.clipsToBounds = true
        coverImage.isHidden = false
    }
    
    func addTapListeners() {
        coverTap = UITapGestureRecognizer(target: self, action: #selector(RecommendationViewCell.onRecommendationCellTapped))
        self.addGestureRecognizer(coverTap!)

        overlayTap = UITapGestureRecognizer(target: self, action: #selector(RecommendationViewCell.onRecommendationCellOverlayTapped))
        tapOverlay.addGestureRecognizer(overlayTap!)

        authorTap = UITapGestureRecognizer(target: self, action: #selector(RecommendationViewCell.onAuthorImageTapped))
        authorImage.addGestureRecognizer(authorTap!)
    }

    func removeTapListeners() {
        if let coverTap = coverTap {
            self.removeGestureRecognizer(coverTap)
            for gestureRecognizer in self.gestureRecognizers! {
                self.removeGestureRecognizer(gestureRecognizer)
            }
        }
        if let overlayTap = overlayTap {
            tapOverlay.removeGestureRecognizer(overlayTap)
            for gestureRecognizer in tapOverlay.gestureRecognizers! {
                tapOverlay.removeGestureRecognizer(gestureRecognizer)
            }
        }
        if let authorTap = authorTap {
            authorImage.removeGestureRecognizer(authorTap)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addLoadingView()
        selectionStyle = UITableViewCellSelectionStyle.none
        if(self.coverImage.isHidden == false){
            self.loadingV.isHidden = true
            if loadingV.spinner.isAnimating {
                loadingV.spinner.stopAnimating()
                loadingV.spinner.startAnimating()
            }
        }else{
            self.loadingV.isHidden = false
            if loadingV.spinner.isAnimating {
                loadingV.spinner.stopAnimating()
                loadingV.spinner.startAnimating()
            }
        }
    }
    
    func addLoadingView(){
        self.loadingV.isBackImageViewHidden = true
        self.loadingV.isWhereImageViewHidden = true
        self.loadingV.isUserLittleBgImage = true
        self.loadingV.isFromRecommendationCell = true
        let loadingSpinnerWidthHeight:CGFloat = 50
        let margin:CGFloat = 14
        self.loadingV.frame = CGRect(x: self.frame.size.width - loadingSpinnerWidthHeight - margin, y: self.frame.size.height - loadingSpinnerWidthHeight - margin, width: loadingSpinnerWidthHeight, height: loadingSpinnerWidthHeight)
        self.loadingV.isHidden = false
        self.contentView.addSubview(self.loadingV)
    }
    
//    func removeTheLoadingView(){
//        self.loadingV.removeFromSuperview()
//        self.loadingV.hidden
//    }

    //MARK: - View Lifecycle


}
