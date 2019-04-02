//
//  SectionedUserStream.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/21/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



@objc protocol SectionedUserStreamViewDelegate {
    @objc optional func onDataFetched(_ users: [String:[User]])
    @objc optional func onDataFetchedNew(_ users: [User])

}

/**
 User stream where users are divided into sections
 
 */
class SectionedUserStreamView : StreamView {
    
    //MARK: - Properties
    
    fileprivate var users = [String:[User]]()
    fileprivate var sectionTitles = [String]()
    fileprivate var customSection = false
    fileprivate var newUsers = [User]()
    fileprivate var recommendUsers = [User]()

    var fullsize = false
    let cellIdentifier = "userCell"
    let sectionHeaderCellIdentifier = "SectionHeaderViewCell"
    var selectionDelegate: UserSelectionProtocol?
    var sectionedUserStreamViewDelegate: SectionedUserStreamViewDelegate?
    var loginDelegate: LoginDelegate?
    var tapDelegate : UserViewCellTapDelegate?
    var sectionedFollowDelegate: FollowProtocol?

    var isFromFriends = false
    
    //MARK: - Initializers
    
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
    
    fileprivate func commonInit() {
        if self.dataSource != nil && self.delegate != nil {
            return
        }
        
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.register(UINib(nibName: sectionHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: sectionHeaderCellIdentifier)
        
        refreshCtrl = UIRefreshControl()
        refreshCtrl.tintColor = Config.Colors.ZanaduCerisePink
        refreshCtrl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        addSubview(refreshCtrl)
        
        backgroundColor = UIColor.clear
        separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    
    //MARK: - Methods
    
    override func removeAll() {
       if customSection {
               users = [String:[User]]()
           } else {
                users.removeAll(keepingCapacity: true)
            }
    }
    
    var pullToRefresh: Bool? {
        didSet {
            switch pullToRefresh! {
            case false:
                refreshCtrl.removeTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
                refreshCtrl.removeFromSuperview()
            default:
                refreshCtrl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
                addSubview(refreshCtrl)
            }
        }
    }
    
    
    internal override func handleQueryForObjects(_ objects: [AnyObject]) {
        let userArray = objects as! [User]
        newUsers.removeAll()
        recommendUsers.removeAll()
        if customSection {
            if isFromFriends {
                newUsers = userArray
                if let appUser = User.current(){
                    if newUsers.contains(appUser as! User) {
                        var removeIndex = 0
                        for (index , user) in newUsers.enumerated() {
                            if user.objectId == appUser.objectId {
                                removeIndex = index
                                break;
                            }
                        }
                        newUsers.remove(at: removeIndex)
                    }
                }
                
                if newUsers.count > 2 {
                    let halfCount = UInt32(newUsers.count/2)
                    
                    let temp1  = Int(arc4random_uniform(halfCount))
                    let temp2  = temp1 + 1

                    recommendUsers.append(newUsers[temp1])
                    recommendUsers.append(newUsers[temp2])
                }else{
                    recommendUsers = newUsers
                }

            }else{
                sectionTitles = Array(users.keys)
                
                let sortedArray = userArray.sorted(by: { user1, user2 in
                    return user1.nickname!.lowercased() < user2.nickname!.lowercased()
                })
                
                users = [sectionTitles[0]: sortedArray]
            }
        } else {
            (users, sectionTitles) = sectionedDataFromUserArray(userArray)
        }
        
            if let delegate = self.sectionedUserStreamViewDelegate {
                delegate.onDataFetchedNew?(recommendUsers)
            }
            if let delegate = self.sectionedUserStreamViewDelegate {
                delegate.onDataFetched?(self.users)
            }
       
        self.reloadData()
        self.refreshCtrl.endRefreshing()
    }
    
    
    func configureCell(_ cell: UserViewCell, forRowAtIndexPath index: IndexPath) {
        cell.backgroundColor = Config.Colors.TagFieldBackground
        cell.layer.borderColor = Config.Colors.TagViewBackground.cgColor
        cell.layer.borderWidth = 2        
        cell.isFromFriends = isFromFriends
        var  user = recommendUsers[(index as NSIndexPath).row]
        if let delegate = self.sectionedFollowDelegate{
            cell.followDelegate = delegate
        }
        if isFromFriends {
            user = recommendUsers[(index as NSIndexPath).row]
            cell.backgroundColor = Config.Colors.RecommendFriendsBackColor
            cell.layer.borderColor = Config.Colors.RecommendFriendsBackColor.cgColor
            cell.layer.borderWidth = 0

        }
        else {
            user = users[sectionTitles[(index as NSIndexPath).section]]![(index as NSIndexPath).row]
        }
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
    
    func setCustomSectionWithName(_ name: String) {
        customSection = true
        users[name] = [User]()
    }
    
    func removeCustomSession() {
        customSection = false
        users.removeAll(keepingCapacity: true)
    }
}

extension SectionedUserStreamView: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionHeaderCellIdentifier) as! SectionHeaderViewCell
        cell.contentView.backgroundColor = Config.Colors.TagViewBackground
        cell.titleLabel.textColor = Config.Colors.FirstTitleColor

        if isFromFriends {
            cell.titleLabel.text = NSLocalizedString("Recommended", comment:"好友推荐")
            cell.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = Config.Colors.RecommendFriendsBackColor


        }else{
            cell.titleLabel.text = sectionTitles[section]  
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFromFriends {
            return 1
        }
        return sectionTitles.count
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFromFriends {
            return NSLocalizedString("Recommended", comment:"好友推荐")
        }
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromFriends {
            
            if recommendUsers.count > 2 {
                return 2
            }else{
                return recommendUsers.count
            }
        }
        return users[sectionTitles[section]]!.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserViewCell {
            configureCell(cell, forRowAtIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}

extension SectionedUserStreamView {
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if SizeClass.horizontalClass == UIUserInterfaceSizeClass.compact {
            return 72
        } else {
            return 88
        }
    }
}

extension SectionedUserStreamView {
    
    func sectionedDataFromUserArray(_ array:[User]) -> ([String:[User]], [String]) {
        var dictionary = [String:[User]]()
        
        
        let sortedArray = array.sorted(by: { user1, user2 in
            return user1.nickname!.lowercased() < user2.nickname!.lowercased()
        })
        
        for user in sortedArray {

            if let name = user.nickname {
                let strIndex = name.characters.index(name.startIndex, offsetBy: 1)
                let firstLetter = name.substring(to: strIndex).capitalized
                
                // section exists
                if dictionary.index(forKey: firstLetter) != nil {
                    dictionary[firstLetter]!.append(user)
                    
                    // section needs to be created
                } else {
                    dictionary[firstLetter] = [user]
                }
            }
        }
        
        let sectionTitleArray = dictionary.keys.sorted()

        
        return (dictionary, sectionTitleArray)
    }
    
}
