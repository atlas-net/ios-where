//
//  BaseRecommendationTableView.swift
//  Atlas
//
//  Created by yingyang on 16/6/8.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import MJRefresh

class BaseRecommendationTableViewController: UITableViewController {
    
    var recommendations = [Recommendation]()
    let cellIdentifier = "recommendationCell"
    var emptyStreamMessage: String = NSLocalizedString("No result", comment:"无结果")
    fileprivate var emptyStreamLabel: UILabel!

    override func viewDidLoad() {
        self.tableView.register(UINib(nibName: "RecommendationViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.allowsSelection = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    func showEmptyStreamLabel() {
        if emptyStreamLabel == nil {
            emptyStreamLabel = UILabel(frame: CGRect(x: self.tableView.frame.size.width / 2 - 50, y: self.tableView.frame.size.height / 2 - 15, width: 100, height: 30))
            emptyStreamLabel.text = emptyStreamMessage
            emptyStreamLabel.textColor = Config.Colors.SecondTitleColor
            emptyStreamLabel.textAlignment = NSTextAlignment.center
            emptyStreamLabel.font = UIFont.systemFont(ofSize: 20)
            emptyStreamLabel.sizeToFit()
            self.tableView.addSubview(emptyStreamLabel)
        }
        emptyStreamLabel.isHidden = false
    }
    
    func hideEmptyStreamLabel() {
        if let emptyStreamLabel = emptyStreamLabel {
            emptyStreamLabel.isHidden = true
        }
    }
    
    @available(iOS 9.0, *)
    lazy var previewDelegate : RecommendationTableViewPreviewDelegate = {
        let previewDelegate = RecommendationTableViewPreviewDelegate(viewController: self, tableview: self.tableView, recommendationGetBlock: { (indexPath) -> Recommendation? in
            if (indexPath as NSIndexPath).row < 0 || (indexPath as NSIndexPath).row >= self.recommendations.count{
                return nil
            }
            return self.recommendations[(indexPath as NSIndexPath).row]
        })
        return previewDelegate
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: previewDelegate, sourceView: view)
            }
        }
    }
    
    func configureCell(_ cell: RecommendationViewCell, forRowAtIndexPath index: IndexPath) {
        let recommendation = self.recommendations[(index as NSIndexPath).row]
        cell.recommendation = recommendation
        cell.coverImage.isHidden = true
        cell.locationButton.isHidden = true
        cell.titleLabel.text = recommendation.title
        if let venue = recommendation.venue {
            if let customName = venue.customName {
                cell.locationButton.isHidden = false
                cell.locationButton.setTitle(" \(customName) ", for: UIControlState())
            }
        }
        if let cover = recommendation.cover {
            let recommentId = recommendation.objectId
            if let coverFile = cover.file {
                cell.coverImage.image = nil
                coverFile.getImageWithBlock(withBlock: { (image, error) -> Void in
                    if recommentId != cell.recommendation?.objectId{
                        return
                    }
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        cell.setupCoverWithImage(image!)
                        cell.layoutSubviews()
                    }
                })
            }
        }
        
        cell.nameLabel.text = recommendation.author?.nickname
        if let author = recommendation.author {
            cell.authorImage.setupForAvatarWithUser(author)
        }
        
    }
    
    func showBasicAlertWithTitle(_ title:String){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: title, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //to override
    func fetchData(){}
    func fetchDataWithLatestDate(_ latestDate:Date){}
    func fetchDataWithOldestDate(_ oldestDate:Date){}

}

extension BaseRecommendationTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecommendationViewCell
        
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recommendation = self.recommendations[(indexPath as NSIndexPath).row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
        
    }
}


