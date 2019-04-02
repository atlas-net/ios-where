////
////  NotificationViewCell.swift
////  Atlas
////
////  Created by Benjamin Lefebvre on 7/10/15.
////  Copyright (c) 2015 Atlas. All rights reserved.
////

class NotificationViewCell: UITableViewCell {
    
    //Mark: - Properties

    var delegate: NotificationSelectionDelegate?
    var notification: Notification?
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBOutlet weak var notificationimage: UIImageView!
    @IBOutlet weak var bottomLineHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Actions
    
    func onAuthorImageTapped() {

        if delegate != nil {
            delegate?.onAuthorSelected!(self.notification!.author!)
        }
    }
    
    func onNotificationCellTapped() {

        if delegate != nil {
            delegate?.onNotificationSelected(self.notification!)
        }
    }
    
    func onTitleLabelTapped() {

        if delegate != nil {
            delegate?.onNotificationSelected(self.notification!)
        }
    }

    func onBodyLabelTapped() {

        if delegate != nil {
            delegate?.onNotificationSelected(self.notification!)
        }
    }

    
    //MARK: - Methods
    
    func addTapListeners() {
        bottomLineHeightConstraint.constant = 0.5
        let cellTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationViewCell.onNotificationCellTapped))
        self.addGestureRecognizer(cellTap)
        
        let titleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationViewCell.onTitleLabelTapped))
        titleLabel.addGestureRecognizer(titleTap)

        let bodyTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationViewCell.onBodyLabelTapped))
        bodyLabel.addGestureRecognizer(bodyTap)
        
        let authorTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationViewCell.onAuthorImageTapped))
        authorImageView.addGestureRecognizer(authorTap)
    }
}
