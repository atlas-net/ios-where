//
//  NotificationStreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


/**
Handle display of a notification list
*/
protocol NotificationStreamViewDelegate : NSObjectProtocol{
    func notificationViewDidScroll()
    func notificationDidEndDecelerating()
    func notificationScrollViewDidEndDragging()
}
class NotificationStreamView : StreamView, UITableViewDataSource {

    //MARK: - Properties
    
    let cellIdentifier = "notificationCell"
    fileprivate var notifications = [Notification]()
    var selectionDelegate: NotificationSelectionDelegate?
    var scrollDelegate: NotificationStreamViewDelegate?
    var highlightedCount = 0
    
    var bodyLabelWidth: CGFloat = 0
    var loadingV = LoadingView()
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib(nibName: "NotificationViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        refreshCtrl = UIRefreshControl()
        refreshCtrl.tintColor = Config.Colors.ZanaduCerisePink
        refreshCtrl.addTarget(self, action: #selector(StreamView.refresh), for: UIControlEvents.valueChanged)
        addSubview(refreshCtrl)
    }
    
    //MARK: - Methods
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.addSubview(self.loadingV)
    }
    
    func refreshWithHighlightCount(_ count: Int) {
        highlightedCount = count
        fetchData()
    }
    
    override func refresh() {
        highlightedCount = 0
        fetchData()
    }

    override func removeAll() {
        notifications.removeAll()
    }

    internal override func handleQueryForObjects(_ objects: [AnyObject]) {
        loadingV.removeFromSuperview()


        if (objects.count > 0) {
            for notif in (objects as! [Notification]) {
                insertUniqueOrdered(&self.notifications, elem: notif)
            }

            
            // if self.fullsize {
            let height = self.rowHeight
            let frameHeight = height * CGFloat(self.notifications.count) - 2
            
            if let viewDelegate = self.streamViewDelegate {
                viewDelegate.onHeightChanged?(frameHeight)
            }
            

            self.reloadData()
            self.refreshCtrl.endRefreshing()


            
            if let delegate = self.streamViewDelegate {
                delegate.onDataFetched?(self, objects: self.notifications)
            }
        }
    }
    
    func configureCell(_ cell: NotificationViewCell, forRowAtIndexPath index: IndexPath) {
        

        
        
        let notification = notifications[(index as NSIndexPath).row]
        
        if let author = notification.author {
            cell.authorImageView.setupForAvatarWithUser(author)
        }
        if let file = notification.file {
            cell.notificationimage.contentMode = UIViewContentMode.scaleAspectFill
            cell.notificationimage.layer.masksToBounds = true
            cell.notificationimage.setupForNotificationImage(file)
        }else{
            cell.notificationimage.contentMode = UIViewContentMode.scaleAspectFit
            cell.notificationimage.layer.masksToBounds = true
            cell.notificationimage.image = UIImage(named:"Followed")?.withRenderingMode(.alwaysTemplate)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let str = dateFormatter.string(from: notification.createdAt!)
        cell.timeLabel.text = str
        
        let bodyString = notification.body?.replacingOccurrences(of: "\\n", with: "\n")
        cell.bodyLabel.text = bodyString
        

        bodyLabelWidth = cell.bodyLabel.frame.width
        
        
        cell.titleLabel.text = notification.title
//        if index.row < highlightedCount {
//            cell.titleLabel.textColor = Config.Colors.LightBlueTextColor
//            cell.bodyLabel.textColor = Config.Colors.LightGreyTextColor
//            cell.timeLabel.textColor = Config.Colors.LightGreyTextColor
//            cell.timeIconImageView.alpha = 1
//        } else {
//            cell.titleLabel.textColor = Config.Colors.LightGreyTextColor
//            cell.bodyLabel.textColor = Config.Colors.DarkGreyTextColor
//            cell.timeLabel.textColor = Config.Colors.DarkGreyTextColor
//            cell.timeIconImageView.alpha = 0.6 
//        }
        
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.clear.cgColor
        
        cell.notification = notification
        
        if let selectionDelegate = selectionDelegate {
            cell.delegate = selectionDelegate
        }
        cell.addTapListeners()
    }
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationViewCell
        


        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
}

extension NotificationStreamView {
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {

//        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(14)]
//        let oneLineText:NSString = "oneLineText"
//
//        let bodyText:NSAttributedString
//        
//        if indexPath.row < notifications.count {
//            if let body = notifications[indexPath.row].body {
//                bodyText = NSAttributedString(string: body.stringByReplacingOccurrencesOfString("\\n", withString: "\n"), attributes: attributes)
//            } else {
//                bodyText = NSAttributedString(string: "")
//            }
//        } else {
//            bodyText = NSAttributedString(string: "")
//        }
//
//        let oneLineSize = oneLineText.sizeWithAttributes(attributes)
//        let labelSize = bodyText.boundingRectWithSize(CGSizeMake(bodyLabelWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
//
//        return 96 + labelSize.height - oneLineSize.height
       return self.rowHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let delegate = self.scrollDelegate{
                delegate.notificationViewDidScroll()
            }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if let delegate = self.scrollDelegate{
                delegate.notificationDidEndDecelerating()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
               if let delegate = self.scrollDelegate{
                delegate.notificationScrollViewDidEndDragging()
            }
        
    }

}
