//
//  SearchRecommendationTableView.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/6/3.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import UIKit
import MJRefresh

@objc protocol SearchRecommendationTableViewDelegate : NSObjectProtocol{
    @objc optional func SearchRecommendationTableViewRefreshCallBack()
}

@objc protocol SearchRecommendationCount : NSObjectProtocol{
    @objc optional func searchRecommendationCountCallBack(_ count:Int)
}
class SearchRecommendationTableView: UITableView ,UITableViewDataSource,UITableViewDelegate{
    enum RecommendationRefreshType {
        case allCate,titleMatch,cityCate,cityInput
    }
    
    var recommendations = [Recommendation]()

    var emptyStreamLabel: UILabel!
    var refreshCtrl: UIRefreshControl!
    let cellIdentifier = "recommendationCell"
    let cellHeight: CGFloat = 200
    var isAuthorInfoHidden = false
    weak var searchDelegate: SearchRecommendationTableViewDelegate!
    var titleRecommendationId = [String]()
    var selectionDelegate: RecommendationSelectionProtocol?
    var countDelegate: SearchRecommendationCount?
    
    var recommendationRefreshType: RecommendationRefreshType = .allCate
    var scrollDelegate: RecommendationStreamViewDelegate?
    var isFromGlobalSearch = false

    var emptyStreamMessage: String = NSLocalizedString("No result", comment:"无结果") {
        didSet {
            if let emptyStreamLabel = emptyStreamLabel {
                emptyStreamLabel.text = emptyStreamMessage
            }
        }
    }
    
    lazy  var loadingV: LoadingView = {
        return LoadingView()
    }()

    
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib(nibName: "RecommendationViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        if isFromGlobalSearch{
            let mjFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(SearchRecommendationTableView.RecommendationPushRefresh))
            self.mj_footer = mjFooter
            self.mj_footer.isAutomaticallyChangeAlpha = true
            self.mj_footer.isAutomaticallyHidden = true
            if let footer  = self.mj_footer as? MJRefreshAutoNormalFooter{
                footer.stateLabel.textColor = Config.Colors.SecondTitleColor
                footer.activityIndicatorViewStyle = .gray
                
            }
        }
        
        backgroundColor = UIColor.clear
        separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    func commonInit() {
        if isFromGlobalSearch{
            let mjFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(SearchRecommendationTableView.RecommendationPushRefresh))
            self.mj_footer = mjFooter
            self.mj_footer.isAutomaticallyChangeAlpha = true
            self.mj_footer.isAutomaticallyHidden = true
            if let footer  = self.mj_footer as? MJRefreshAutoNormalFooter{
                footer.stateLabel.textColor = Config.Colors.SecondTitleColor
                footer.activityIndicatorViewStyle = .gray
                
            }
        }
    }
    func RecommendationPushRefresh() {
        if let delegate = searchDelegate {
            delegate.SearchRecommendationTableViewRefreshCallBack!()
        }
    }
    

    //MARK: PushFunc
    func showEmptyStreamLabel() {
        
        if emptyStreamLabel == nil {
            emptyStreamLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            emptyStreamLabel.text = emptyStreamMessage
            emptyStreamLabel.textColor = Config.Colors.SecondTitleColor
            emptyStreamLabel.textAlignment = NSTextAlignment.center
            emptyStreamLabel.font = UIFont.systemFont(ofSize: 20)
            emptyStreamLabel.sizeToFit()
            backgroundView = emptyStreamLabel
        }
        
        emptyStreamLabel.isHidden = false
    }
    
    func hideEmptyStreamLabel() {
        if let emptyStreamLabel = emptyStreamLabel {
            emptyStreamLabel.isHidden = true
        }
    }

    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if recommendations.count == 0 {
            showEmptyStreamLabel()
        } else {
            hideEmptyStreamLabel()
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecommendationViewCell
        
        if self.recommendations.count > 0{
            
            let recommendation = self.recommendations[(indexPath as NSIndexPath).row]
            
            if cell.recommendation != recommendation {
                cell.coverImage.isHidden = true
                cell.authorImage.isHidden = true
                cell.locationButton.isHidden = true
            }
            if self.delegate != nil {
                configureCell(cell, forRowAtIndexPath: indexPath)
                cell.addTapListeners()
            }
        cell.delegate = self.selectionDelegate
        }

            return cell
    }

    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return cellHeight
    }
    
    
    func configureCell(_ cell: RecommendationViewCell, forRowAtIndexPath index: IndexPath) {
        let start = Date()
        let recommendation = self.recommendations[(index as NSIndexPath).row]
        cell.recommendation = recommendation
        
        cell.coverImage.isHidden = true
        cell.authorImage.isHidden = true
        cell.locationButton.isHidden = true
        
        cell.tapOverlayEnabled = true
        
        cell.titleLabel.text = recommendation.title
        if let venue = recommendation.venue {
            if let customName = venue.customName {
                cell.locationButton.isHidden = false
                cell.locationButton.setTitle(" \(customName) ", for: UIControlState())
            }
        }
        if let cover = recommendation.cover {
            if let coverFile = cover.file {
                let objectId = recommendation.objectId
                cell.coverImage.image = nil
                coverFile.getImageWithBlock(withBlock: { (image, error) -> Void in
                    if cell.recommendation?.objectId != objectId{
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
        if isAuthorInfoHidden {
            cell.likeAndCommentView.isHidden = false
            
            let likeQuery = DataQueryProvider.likesForRecommendation(recommendation)
            likeQuery.countObjectsInBackgroundWithBlock({ (count, error) in
                if error == nil{
                    cell.likeCountLabel.text = "\(count)"
                }
            })
            
            let commentQuery = DataQueryProvider.commentQueryForRecommendation(recommendation)
            commentQuery.countObjectsInBackgroundWithBlock({ (count, error) in
                if error == nil{
                    cell.commentCountLabel.text = "\(count)"
                }
            })
            return
        }
        
        cell.nameLabel.text = recommendation.author?.nickname
        if let author = recommendation.author {
            cell.authorImage.setupForAvatarWithUser(author)
        }
        
        let end = Date()
        
        let timeInterval: Double = end.timeIntervalSince(start)

        

    }
    func removeAll() {
        recommendations.removeAll()
        titleRecommendationId.removeAll()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = self.scrollDelegate{
            delegate.recommendationViewDidScroll()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegate = self.scrollDelegate{
            delegate.recommendationDidEndDecelerating()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let delegate = self.scrollDelegate{
            delegate.recommendationscrollViewDidEndDragging()
        }
    }
    
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: 190,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 298)
        self.addSubview(self.loadingV)
        for  subViews in self.loadingV.subviews{
            if let lodingV = subViews as? SARMaterialDesignSpinner {
                if lodingV.isAnimating {
                    lodingV.stopAnimating()
                    lodingV.startAnimating()
                }
            }
        }

    }
    func removeLoadingView() {
        self.loadingV.removeFromSuperview()
    }

}

extension SearchRecommendationTableView{
    func handleQuery(_ query : AVQuery , currentPage : Int) {

        query.findObjectsInBackground { (objects:[Any]?, error) -> () in
            self.isScrollEnabled = true
            for  subViews in (self.superview?.subviews)!{
                if let lodingV = subViews as? LoadingView {
                    lodingV.removeFromSuperview()
                }
            }
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                if currentPage == 0 {
                    self.recommendations.removeAll()
                }
                //
                if let recommendations = objects as? [Recommendation]{
                    self.recommendations += recommendations
                    self.reloadData()
                    self.removeLoadingView()
                    if let header = self.mj_header{
                        header.endRefreshing()
                    }
                    if let footer = self.mj_footer{
                        footer.endRefreshing()
                    }
                }
                if objects?.count == 0{
                    if let footer = self.mj_footer{
                        footer.endRefreshingWithNoMoreData()
                    }
                }
            }
        }
    }
    
    func handleSimpleQuery(_ query : Query)  {
        query.executeInBackground({ (objects:[Any]?, error) -> () in
            self.isScrollEnabled = true

            for  subViews in (self.superview?.subviews)!{
                if let lodingV = subViews as? LoadingView {
                    lodingV.removeFromSuperview()
                }
            }
            if error != nil {
                log.error(error!.localizedDescription)
            } else {
                //
                if let recommendations = objects as? [Recommendation]{
                    self.recommendations = recommendations
                    self.reloadData()
                    self.removeLoadingView()
                    if let header = self.mj_header{
                        header.endRefreshing()
                    }
                    if let footer = self.mj_footer{
                        footer.endRefreshing()
                    }
                    if let countDelegate = self.countDelegate{
                        countDelegate.searchRecommendationCountCallBack!(recommendations.count)
                    }
                }
                
                
            }
 
            
        })
    }
}
