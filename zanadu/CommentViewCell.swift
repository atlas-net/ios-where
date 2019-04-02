//
//  CommentViewCell.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/14/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

protocol CommentViewCellDelegate {
    func commentViewCellDelegateDidTapAuthorImageWithComment(_ comment:Comment)
}

class CommentViewCell : UITableViewCell {
    
    //MARK: - Properties
    
    var myDelegate: CommentViewCellDelegate?
    var comment:Comment?
    var cellHeight = CGFloat()
    //MARK: - Outlets
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var authorImageCoverButton: UIButton!
    @IBOutlet weak var commentTextViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var authorNameConstraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLine: UILabel!
    @IBOutlet weak var bottomLineHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTextViewConstraintTop: NSLayoutConstraint!
    
    
    //MARK: - Actions
    
    func onViewTapped() {

        if myDelegate != nil {
            myDelegate?.commentViewCellDelegateDidTapAuthorImageWithComment(comment!)
        }
    }
    
    
    //MARK: - Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        commentTextView.isUserInteractionEnabled = false
         commentTextView.textContainerInset = UIEdgeInsetsMake(1.0,1.0,1.0,1.0)
        authorImageCoverButton.addTarget(self, action: #selector(CommentViewCell.onViewTapped), for: UIControlEvents.touchUpInside)
        let lineHeight : CGFloat = 0.5
        bottomLineHeight.constant = lineHeight
        bottomLine.backgroundColor = Config.Colors.CommentSeparatorColor
        timeLabel.textColor = Config.Colors.SecondTitleColor
        authorNameLabel.textColor = Config.Colors.MainContentColorBlack
        commentTextView.textColor = Config.Colors.MainContentColorBlack
    }
    func setUpCommentTextViewHeight(_ commentText:String){
        let commentTextViewSize = commentTextView.sizeThatFits(CGSize(width: commentTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let commentLineSpacing : CGFloat = 8
        let fPadding = (commentTextViewSize.width/commentTextView.frame.width + 1)*commentLineSpacing
        
        commentTextViewConstraintHeight.constant = commentTextViewSize.height + fPadding
        let marginBottom:CGFloat = 5
        cellHeight =  authorNameConstraintTop.constant + authorNameLabel.frame.size.height + commentTextViewConstraintTop.constant + commentTextViewConstraintHeight.constant + marginBottom
    }
}
