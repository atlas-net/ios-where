//
//  LikeView.swift
//  Atlas
//
//  Created by yingyang on 16/3/8.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation


 protocol LikeViewDelegate {
   func likeViewDidTapUser(_ user:User)
   func likeViewHeartImageBtnClick(_ liked: Bool)
   func likeViewHeartImageBtnClickWithoutLogin()
}
class LikeView:UIView {
    
    
    let cellIdentifier = "LikeViewCell"
    var recommendation = Recommendation()
    var likers = [Like]()
    var tableView = UITableView()
    var cellHeight:CGFloat = 28
    var headerLabelHeight:CGFloat = 20
    //    var maxCount:Int = 0
//    var addMoreBtn = UIButton()
    var headerLabel = UILabel()
    var headerLabelTopDistance:CGFloat = 15
    var tableViewTopDistance:CGFloat = 15
    var delegate:LikeViewDelegate?
    var liked = false
    var heartImageBtn = UIButton()
    var dataQuery: Query? {
        didSet {
            fetchData()
        }
    }
    
    func commentInit(){
        self.backgroundColor = UIColor.clear
        self.heartImageBtn.layer.cornerRadius = 2
        //heart image
        self.heartImageBtn.addTarget(self, action: #selector(updateLikeButton), for: UIControlEvents.touchUpInside)
        self.addSubview(heartImageBtn)
        self.heartImageBtn.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(self).inset(headerLabelTopDistance)
            make.width.equalTo(82)
            make.height.equalTo(30)
        }
        self.heartImageBtn.setTitleColor(Config.Colors.SecondTitleColor, for: UIControlState())
        //headerLabel

        self.headerLabel.font = UIFont.systemFont(ofSize: 12)
        self.headerLabel.textColor =  Config.Colors.SecondTitleColor
        headerLabel.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
        headerLabel.layer.cornerRadius = 2
        headerLabel.textAlignment = .center
        self.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { (make) in
            make.right.equalTo(self).inset(50)
            make.top.bottom.equalTo(self.heartImageBtn)
            make.width.equalTo(25)
        }
        //tableview
        let tableViewWidth = UIScreen.main.bounds.width -  203
        tableView.frame = CGRect(x: 0, y: 15, width: 30, height: tableViewWidth)
        tableView.register(LikeViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI / 2.0))
        tableView.frame = CGRect(x: 95, y: 15, width: tableView.frame.size.width, height: tableView.frame.size.height)

        self.addSubview(tableView)
        if let user = User.current() as? User{
            user.isLiking(recommendation) { (liking) -> () in
                self.liked = liking
                if self.liked {
                    self.setUserLike()
                } else {
                    self.setUserUnLike()
                }
            }
        } else {
            self.setUserUnLike()
        }
        
        self.heartImageBtn.titleEdgeInsets = UIEdgeInsetsMake(0,7, 0, 0)
        self.heartImageBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-7, 0, 0)

        self.heartImageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.heartImageBtn.backgroundColor = Config.Colors.GrayBackGroundWithAlpha
    }
    
    func setUserLike()
    {
        self.heartImageBtn.setImage(UIImage(named: "recommendationLike"), for: UIControlState())
        self.heartImageBtn.setTitle(NSLocalizedString("Cancle", comment: "取消"), for: UIControlState())
    }
    
    func setUserUnLike(){
        self.heartImageBtn.setImage(UIImage(named: "recommendationDislike")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        self.heartImageBtn.tintColor = Config.Colors.SecondTitleColor
        self.heartImageBtn.setTitle(NSLocalizedString("Like", comment: "喜欢"), for: UIControlState())
    }
    
    func fetchData(){
        guard let dataQuery = dataQuery else {
            return
        }
        //dataQuery.includeKey("author.avatar")
        dataQuery.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil {
                if count != 0{
                    self.headerLabel.text = count.description
                dataQuery.executeInBackground({ (objects:[Any]?, error) -> () in
                    if error != nil{
                        log.error(error!.localizedDescription)
                    }else{
                        self.likers = objects as! [Like]
                        if self.likers.count != 0{
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                        }else{
                            self.headerLabel.text = count.description
                            self.tableView.isHidden = true
                        }
                    }
                })
                }else{
                    self.headerLabel.text = count.description
                    self.tableView.isHidden = true
                }
                
            }else{
                log.error(error?.localizedDescription)
            }
        }
        
    }
    func updateHeartImage(_ isLike:Bool){
        self.liked = isLike
        if self.liked {
            self.setUserLike()
        } else {
            self.setUserUnLike()
        }
        
    }
    func updateLikeButton() {
         if AVUser.current() == nil{
            if let delegate = self.delegate{
                delegate.likeViewHeartImageBtnClickWithoutLogin()
            }
            return
        }

        if liked {
            (User.current() as! User).unlike(recommendation) { (isUnliked) -> () in
                if isUnliked {
                    self.setUserUnLike()
                    self.liked = false
                    if let delegate = self.delegate{
                        delegate.likeViewHeartImageBtnClick(false)
                    }
                    if Int(self.recommendation.likes!) > 0 {
                        self.recommendation.incrementKey("likes",byAmount:-1)
                    }
                    self.recommendation.saveEventually()
                }
                self.heartImageBtn.isEnabled = true
            }
        } else {
            (User.current() as! User).like(recommendation) { (isLiked) -> () in
                if isLiked {
                    self.setUserLike()
                    self.liked = true
                    if let delegate = self.delegate{
                        delegate.likeViewHeartImageBtnClick(true)
                    }
                    self.recommendation.incrementKey("likes",byAmount:1)
                    self.recommendation.saveEventually()
                }
                self.heartImageBtn.isEnabled = true
            }
        }
    }

}
extension LikeView:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LikeViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor.clear
        let liker = likers[(indexPath as NSIndexPath).row]
        if let user = liker.user{
        cell.avatarImageView.setupForAvatarWithUser(user,circleBorder: false)
        }
        cell.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2));
        return  cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liker = likers[(indexPath as NSIndexPath).row]
        if let user = liker.user{
            self.delegate?.likeViewDidTapUser(user)
        }

        
    }
}
