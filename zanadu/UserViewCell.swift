//
//  UserViewCell.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 6/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


protocol LoginDelegate {
    func needLogin()
}
protocol UserViewCellTapDelegate {
    func userViewCellUnfollowWithCell(_ cell:UserViewCell)
}

@objc protocol FollowProtocol: class {
    func followCallBack()
}
class UserViewCell: UITableViewCell {
    
    
    //Mark: - Properties
    
    var user: User?
    var state: FollowRelationState?
    var delegate: UserSelectionProtocol?
    var loginDelegate: LoginDelegate?
    var tapDelegate:UserViewCellTapDelegate?
    var followDelegate:FollowProtocol?
    var isFromFriends = false

    static let images: [FollowRelationState: UIImage] = [
        .following:     UIImage(named: "Followed")!.withRenderingMode(.alwaysTemplate),
        .followed:      UIImage(named: "Follow")!.withRenderingMode(.alwaysTemplate),
        .bothFollowing: UIImage(named: "Mutual_Followed")!.withRenderingMode(.alwaysTemplate),
        .noRelations:   UIImage(named: "Follow")!.withRenderingMode(.alwaysTemplate),
    ]

    
    //MARK: - Outlets
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var followButtonImage: UIImageView!
    @IBOutlet weak var followButtonIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var userImageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lineViewHeightConstraint: NSLayoutConstraint!
    //MARK: - Actions
    
    func onFollowButtonTapped() {

        if state == nil { return }

        disableFollowButton()
        
        if state == .noRelations || state == .followed {
            if User.current() == nil {
                if let loginDelegate = loginDelegate {
                    loginDelegate.needLogin()
                }
            } else {
                follow()
            }
        } else {
            if let delegate = self.tapDelegate{
                delegate.userViewCellUnfollowWithCell(self)
            }
        }
    }
    
    func onImageTapped() {

        if let delegate = delegate {
            delegate.onUserSelected(self.user!)
        }
    }

    
    //MARK: - Methods
    
    func setup() {
        selectionStyle = UITableViewCellSelectionStyle.none
        lineViewHeightConstraint.constant = 0.5
        disableFollowButton()
        setupFollowButton()
        addTapListeners()
    }
    
    func disableFollowButton() {
        followButtonImage.isHidden = true
        followButtonIndicator.startAnimating()
    }
    
    func enableFollowButton() {
        followButtonIndicator.stopAnimating()
        followButtonImage.isHidden = false
    }
    
    
    func follow() {
        User.current()?.follow((user?.objectId)!, andCallback: { (success, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
                self.enableFollowButton()
            } else {


                if self.state == .noRelations {
                    self.state = .following
                } else if self.state == .followed {
                    self.state = .bothFollowing
                }
                
                self.followButtonImage.image = UserViewCell.images[self.state!]
                self.followButtonImage.tintColor = Config.Colors.ButtonDarkPink
                self.enableFollowButton()
                if let followDelegate = self.followDelegate {
                    followDelegate.followCallBack()
                }
            }
        })
    }
    
    func unfollow() {
        User.current()?.unfollow((user?.objectId)!, andCallback: { (success, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
                self.enableFollowButton()
            } else {

                
                if self.state == .following {
                    self.state = .noRelations
                } else if self.state == .bothFollowing {
                    self.state = .followed
                }
                
                self.followButtonImage.image = UserViewCell.images[self.state!]
                self.enableFollowButton()
            }
        })
    }
    
    func setupFollowButton() {
        guard let user = self.user else {
            return
        }
        if User.current() == nil {
            followButtonIndicator.stopAnimating()
            self.state = .noRelations
            self.followButtonImage.image = UserViewCell.images[state!]
            self.enableFollowButton()
            return
        } else if user == User.current() {
            followButtonIndicator.stopAnimating()
            return
        }
        
        (User.current() as! User).followStateForUser(user) { (state, error) -> () in
            if error != nil {
                log.error(error!.localizedDescription)
            } else {
                self.state = state
                self.followButtonImage.image = UserViewCell.images[state!]
                self.enableFollowButton()
            }
        }
    }
    
    func addTapListeners() {
        let followButtonImageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserViewCell.onFollowButtonTapped))
        followButtonImage.addGestureRecognizer(followButtonImageTap)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(UserViewCell.onImageTapped))
        userImage.addGestureRecognizer(imageTap)
    }
    
    override func layoutSubviews() {
        if isFromFriends {
            let leftView = UILabel()
            leftView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5)
            leftView.backgroundColor = UIColor.white
            contentView.addSubview(leftView)
        }
    }

}
