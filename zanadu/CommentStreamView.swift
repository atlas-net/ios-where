//
//  CommentsStreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/14/15.
//  Copyright © 2015 Atlas. All rights reserved.
//


protocol CommentsStreamViewDelegate {
    func commentsStreamViewAuthorTapDelegateWithComment(_ comment:Comment)
    func commentsStreamViewDelegateDidSelectWithComment(_ comment:Comment,distance:CGFloat)
}

class CommentStreamView : StreamView, UITableViewDataSource,CommentViewCellDelegate {
    
    
    //MARK: - Properties
    var commentDelegate: CommentsStreamViewDelegate?
    let cellIdentifier = "commentCell"
    fileprivate var comments = [Comment]()
    var headerLabel = UILabel()
    var totalHeight = CGFloat()
    let headerViewHeight : CGFloat = 34
    let lineHeight : CGFloat = 0.5
    let commentLineSpacing : CGFloat = 8

    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.dataSource = self
        self.delegate = self
        self.allowsSelection = true
        self.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        backgroundColor = UIColor.clear
        refreshCtrl = UIRefreshControl()
        refreshCtrl.tintColor = Config.Colors.ZanaduCerisePink
        refreshCtrl.addTarget(self, action: #selector(AVObject.refresh as (AVObject) -> () -> Void), for: UIControlEvents.valueChanged)
        addSubview(refreshCtrl)
    }

    
    //MARK: - Outlets
    
    
    //MARK: - Actions
    
    
    //MARK: - Methods

    override func removeAll() {
        comments.removeAll()
    }
    
    internal override func handleQueryForObjects(_ objects: [AnyObject]) {
        if (objects.count > 0) {
            totalHeight = 0
            self.comments = (objects as! [Comment])
            for (index, _) in self.comments.enumerated(){
                let commentCell  = Bundle.main.loadNibNamed("CommentViewCell", owner: self, options: nil)?[0] as? CommentViewCell
                if let  cell = commentCell{
                let indexPath = IndexPath.init(item: index, section: 0)
                configureCell(cell, forRowAtIndexPath: indexPath)
                    totalHeight += cell.cellHeight
                    caculateHeight((indexPath as NSIndexPath).row + 1)
                }
            }

            self.reloadData()
            self.refreshCtrl.endRefreshing()


        }else{
            self.comments.removeAll()
            totalHeight = 0
            caculateHeight(0)
            self.reloadData()
        }
    }
    
    func caculateHeight(_ num:Int) {
        if num == comments.count {
            if let viewDelegate = self.streamViewDelegate {
                viewDelegate.onHeightChanged?(totalHeight + headerViewHeight)
            }
        }
    }
    
    func configureCell(_ cell: CommentViewCell, forRowAtIndexPath index: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let comment = comments[(index as NSIndexPath).row]
        cell.comment = comment
        cell.myDelegate = self
        
        if let author = comment.author {
            cell.authorImageView.setupForAvatarWithUser(author)
            cell.authorNameLabel.text = author.nickname
        }
     
        cell.timeLabel.text = comment.updatedAt?.formatedElapsedTime()
        
        if let responseAuthor = comment.responseAuthor,
            let nickname = responseAuthor.nickname {
                let str = "@\(nickname):\(comment.text!)"
                let nameColor = Config.Colors.CommentatorsNameColor
                
                let textatrr1 = NSMutableAttributedString(string: str)
                
                let allStringLength = str.characters.count
                let nameLength = nickname.characters.count
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = commentLineSpacing
                
                let attributeDic1 = [NSForegroundColorAttributeName:UIColor.lightGray]
                textatrr1.addAttributes(attributeDic1, range: NSMakeRange(0,1))
                
                let attributeDic2 = [NSForegroundColorAttributeName:nameColor]
                textatrr1.addAttributes(attributeDic2, range: NSMakeRange(1,nameLength))
                
                let attributeDicParagraph = [NSParagraphStyleAttributeName : paragraphStyle]
                textatrr1.addAttributes(attributeDicParagraph, range:  NSMakeRange(0 ,allStringLength))
                
                let attributeDic3 = [NSForegroundColorAttributeName:UIColor.lightGray]
                textatrr1.addAttributes(attributeDic3, range: NSMakeRange(nameLength + 1  ,allStringLength - nameLength - 1))
                
                cell.commentTextView.attributedText = textatrr1
                
                cell.setUpCommentTextViewHeight(str)
        } else {
            cell.commentTextView.text = comment.text
            cell.setUpCommentTextViewHeight(cell.commentTextView.text)
        }
    }


    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        headerLabel.text = "    \(comments.count)人评论"
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CommentViewCell
        

        
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let comment = comments[(indexPath as NSIndexPath).row]
        let cell = tableView.cellForRow(at: indexPath) as! CommentViewCell
        self.commentDelegate?.commentsStreamViewDelegateDidSelectWithComment(comment,distance:cell.frame.origin.y + cell.cellHeight + headerViewHeight)
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CommentViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell.cellHeight
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return headerViewHeight
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            headerLabel.frame = CGRect(x: 0,y: 0,width: self.frame.size.width,height: 14)
            headerLabel.font = UIFont.systemFont(ofSize: 12)
            headerLabel.textColor = Config.Colors.SecondTitleColor
            
            let headerView = UIView()
            headerView.frame = CGRect(x: 0,y: 0,width: self.frame.size.width,height: headerViewHeight)
            headerView.backgroundColor = UIColor.clear
            headerView.addSubview(headerLabel)
            
            let lineView = UIView()
            let screenWidth = UIScreen.main.bounds.size.width
            lineView.frame = CGRect(x: 12,y: headerViewHeight - lineHeight,width: screenWidth - 24,height: lineHeight)
            lineView.backgroundColor = Config.Colors.CommentSeparatorColor
            headerView.addSubview(lineView)
            
            return headerView
        }else
        {
            return nil
        }
    }
    //MARK:CommentViewCellDelegate
    func commentViewCellDelegateDidTapAuthorImageWithComment(_ comment: Comment) {
        self.commentDelegate?.commentsStreamViewAuthorTapDelegateWithComment(comment)
        
    }
}
