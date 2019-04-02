//
//  UserStreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



import MJRefresh

@objc protocol UserStreamRefreshViewDelegate : NSObjectProtocol{
    
    @objc optional func UserStreamViewPushCallback()
}
enum GlobalRefreshType {
    case nickName,city,province
}
class UserStreamView : StreamView, UITableViewDataSource {
    
    
    //MARK: - Properties
    
    let cellIdentifier = "userCell"
    fileprivate var users = [User]()
    fileprivate var fetcher = SearchResultFetcher()
    var fullsize = false
    var selectionDelegate: UserSelectionProtocol?
    var isFromGlobalSearch = false
    var loginDelegate: LoginDelegate?
    var tapDelegate:UserViewCellTapDelegate?
    var refreshDelegate:UserStreamRefreshViewDelegate?
    var globalRefreshType : GlobalRefreshType?
    var currentUsersPage: Int = 0
    var exsitsUserIds = [String]()
    var existsUsers = [User]()
    
    //MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
     func commonInit() {
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        
        if isFromGlobalSearch {
            globalRefreshType = .nickName
            let mjFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(UserStreamView.UsersPushRefresh))
            self.mj_footer = mjFooter
            self.mj_footer.isAutomaticallyChangeAlpha = true
            self.mj_footer.isAutomaticallyHidden = true
            if let footer  = self.mj_footer as? MJRefreshAutoNormalFooter{
                footer.stateLabel.textColor = Config.Colors.SecondTitleColor
                footer.activityIndicatorViewStyle = .gray
            }
        }else{
            refreshCtrl = UIRefreshControl()
            refreshCtrl.tintColor = Config.Colors.ZanaduCerisePink
            refreshCtrl.addTarget(self, action: #selector(AVObject.refresh as (AVObject) -> () -> Void), for: UIControlEvents.valueChanged)
            addSubview(refreshCtrl)
        }
        
        
        backgroundColor = UIColor.clear
        separatorStyle = UITableViewCellSeparatorStyle.none
       
    }

    //MARK: - Methods
    
    override func removeAll() {
        users.removeAll()
    }
    
    func UsersPushRefresh() {
        if let delegate = refreshDelegate{
            delegate.UserStreamViewPushCallback!()
        }
    }
    var pullToRefresh: Bool? {
        didSet {
            switch pullToRefresh! {
            case false:
                refreshCtrl.removeTarget(self, action: #selector(AVObject.refresh as (AVObject) -> () -> Void), for: UIControlEvents.valueChanged)
                refreshCtrl.removeFromSuperview()
            default:
                refreshCtrl.addTarget(self, action: #selector(AVObject.refresh as (AVObject) -> () -> Void), for: UIControlEvents.valueChanged)
                addSubview(refreshCtrl)
            }
        }
    }
    
    
    internal override func handleQueryForObjects(_ objects: [AnyObject]) {
        if (objects.count > 0 && objects[0].value(forKey: "_deeplink") != nil) {
            var count = 0
            fetcher.emptyTmpQueries()
            self.users = [User](repeating: User(), count: objects.count)
            for (i, obj) in objects.enumerated() {
                fetcher.fetch(obj as! User, completion: { (object, error) -> () in
                    if error != nil {
                        log.error("Fetch error : \(error?.localizedDescription)")
                    } else {
                        if i < self.users.count {
                            self.users[i] = object!
                            count += 1
                        }
                        
                        if self.fullsize {
                            let height = self.rowHeight
                            self.frame.size.height = height * CGFloat(self.users.count)
                        }
                        
                        if let delegate = self.streamViewDelegate {
                            var height:CGFloat = 0
                            if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
                                height =  88
                            } else {
                                height =  88
                            }
                            delegate.onHeightChanged?(self.frame.height)
                            delegate.onDataFetched?(self, objects: self.users)
                            delegate.onHeightChangedWithStream?(self,height: height * CGFloat(self.users.count))
                        }
                        
                        if count == objects.count {

                            self.reloadData()
                        }
                        self.refreshCtrl.endRefreshing()
                    }
                })
            }
        } else {
            self.users = (objects as! [User])
            if self.users.count != 0{
                if isFromGlobalSearch{
                // leancloud AVAnalytics
                AVAnalytics.event("搜索用户list页面")
                }
            }
            if self.fullsize {
                let height = self.rowHeight
                self.frame.size.height = height * CGFloat(self.users.count)
            }
            
            if let delegate = self.streamViewDelegate {
                var height:CGFloat = 0
                if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
                    height =  88
                } else {
                    height =  88
                }
                delegate.onHeightChanged?(self.frame.height)
                delegate.onDataFetched?(self, objects: self.users)
                delegate.onHeightChangedWithStream?(self,height: height * CGFloat(self.users.count))
            }

            

            self.reloadData()
            self.refreshCtrl.endRefreshing()
        }
    }

    
    func configureCell(_ cell: UserViewCell, forRowAtIndexPath index: IndexPath) {
        if (index as NSIndexPath).row < users.count {
            let user = users[(index as NSIndexPath).row]
            cell.user = user
            cell.setup()
            
            if let selectionDelegate = selectionDelegate {
                cell.delegate = selectionDelegate
            }
            
            cell.loginDelegate = loginDelegate
            cell.tapDelegate = tapDelegate

            cell.addTapListeners()
            
            cell.nicknameLabel.text = user.nickname
            cell.messageLabel.text = user.message
            
            if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
                cell.userImageWidthConstraint.constant = 46
                cell.userImage.frame.size.width = 46
                cell.userImage.frame.size.height = 46
            }

            cell.userImage.setupForAvatarWithUser(user)
        }
    }
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if users.count == 0 {
            showEmptyStreamLabel()
        } else {
            hideEmptyStreamLabel()
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
}

extension UserStreamView {
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
            return 72
        } else {
            return 88
        }
    }
}
