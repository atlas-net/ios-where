//
//  RecommendationStreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/12/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



 enum  RecommendationStreamType:Int  {
    case friendViewRecommendationStreamType
    case defaultViewRecommendationStreamType
    
    };

protocol RecommendationStreamViewDelegate : NSObjectProtocol{
     func recommendationViewDidScroll()
     func recommendationDidEndDecelerating()
     func recommendationscrollViewDidEndDragging()
}
class RecommendationStreamView : StreamView, UITableViewDataSource {
    
    //MARK: - Properties
    
    let cellIdentifier = "recommendationCell"
    var recommendations = [Recommendation]()
    fileprivate var fetcher = SearchResultFetcher()
    var fullsize = false
    var selectionDelegate: RecommendationSelectionProtocol?
    var isBiggerCellSize = false
    var loadingV = LoadingView()
    var tribesCache = [String:UIImage]()
    var StreamType = RecommendationStreamType.defaultViewRecommendationStreamType
    var isFromGlobalSearch = false
    var isAuthorInfoHidden = false
    var scrollDelegate: RecommendationStreamViewDelegate?
    
    
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib(nibName: "RecommendationViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        refreshCtrl = UIRefreshControl()
//        refreshControl.tintColor = Config.Colors.ZanaduCerisePink
        refreshCtrl.tintColor = UIColor.red
        refreshCtrl.addTarget(self, action: #selector(pullRefresh), for: UIControlEvents.valueChanged)
        addSubview(refreshCtrl)
        
        backgroundColor = UIColor.clear
        separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    
    //MARK: - Methods
    func addLoadingView(){
        if(self.StreamType == RecommendationStreamType.friendViewRecommendationStreamType){
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.addSubview(self.loadingV)
        }
    }

    
    override func removeAll() {
        recommendations.removeAll()
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
            self.loadingV.removeFromSuperview()
            var count = 0
            fetcher.emptyTmpQueries()
            if !paging || paging && currentPage == 0 {
                self.recommendations = [Recommendation](repeating: Recommendation(), count: objects.count)
            }
            for obj in objects {
                fetcher.fetch(obj as! Recommendation, completion: { (object, error) -> () in
                    if error != nil {
                        log.error("Fetch error : \(error?.localizedDescription)")
                    } else {
                        self.recommendations.append(object!)
                        count += 1
                        
                        if self.fullsize {
                            let height = self.rowHeight
                            self.frame.size.height = height * CGFloat(self.recommendations.count)
                        }
                        if let delegate = self.streamViewDelegate {
                            var height:CGFloat = 0
                            if self.isBiggerCellSize {
                                height = 260
                            } else {
                                height = 200
                            }
                            delegate.onHeightChanged?(self.frame.height)
                            delegate.onDataFetched?(self, objects: self.recommendations)
                            delegate.onHeightChangedWithStream?(self,height: height * CGFloat(self.recommendations.count))
                        }
                        
                        if count == objects.count {

                            self.reloadData()
                        }
                        self.refreshCtrl.endRefreshing()
                    }
                })
            }
        } else {
            self.loadingV.removeFromSuperview()

            if paging && !isResetting {

                self.recommendations += (objects as! [Recommendation])
            } else {

                isResetting = false
                if currentPage == 0 && objects.count == 0 {
                    self.recommendations.removeAll()

                }
                self.recommendations = (objects as! [Recommendation])
                if isFromGlobalSearch{
                // leancloud AVAnalytics
                AVAnalytics.event("搜索动态list页面")
                }
            }
            
            if self.fullsize {
                let height = self.rowHeight
                self.frame.size.height = height * CGFloat(self.recommendations.count)
            }
            
           if let delegate = self.streamViewDelegate {
                var height:CGFloat = 0
                if isBiggerCellSize {
                    height = 260
                } else {
                    height = 200
                }
                delegate.onHeightChanged?(self.frame.height)
                delegate.onDataFetched?(self, objects: self.recommendations)
                delegate.onHeightChangedWithStream?(self,height: height * CGFloat(self.recommendations.count))
            }
            

            self.reloadData()
            self.refreshCtrl.endRefreshing()
        }
    }

    func configureCell(_ cell: RecommendationViewCell, forRowAtIndexPath index: IndexPath) {
        let start = Date()
        let recommendation = self.recommendations[(index as NSIndexPath).row]
        cell.recommendation = recommendation
        cell.delegate = self.selectionDelegate
        
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
                cell.coverImage.image = nil
                coverFile.getImageWithBlock(withBlock: { (image, error) -> Void in
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
            let count = recommendation.likes?.intValue
            cell.likeCountLabel.text = "\(count)"
            
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

        if paging && recommendations.count < totalItems && recommendations.count > 0 {
            return recommendations.count + 1
        }
        return recommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row < recommendations.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecommendationViewCell
            
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
            return cell
        } else if (indexPath as NSIndexPath).row == recommendations.count {

            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellIdentifier, for: indexPath) as! LoadingViewCell
            if cell.spinner == nil {
                cell.spinner = LoadingView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            }
            cell.spinner?.center = CGPoint(x: cell.frame.width / 2, y: cell.frame.height / 2)
            cell.addSubview(cell.spinner!)
            cell.tag = loadingCellTag
            cell.spinner!.isBackImageViewHidden = true
            cell.spinner!.isWhereImageViewHidden = true
            cell.spinner!.backgroundColor = UIColor.clear
            cell.spinner!.spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAtIndexPath indexPath: IndexPath) -> IndexPath? {

        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        if (indexPath as NSIndexPath).row < recommendations.count {
            if self.delegate == nil {
                configureCell(cell as! RecommendationViewCell, forRowAtIndexPath: indexPath)
            }
            (cell as! RecommendationViewCell).addTapListeners()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if let cell = cell as? RecommendationViewCell {
            cell.removeTapListeners()
        }
    }
}

extension RecommendationStreamView {
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if isBiggerCellSize {
            return 260
        } else {
            return 200
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if StreamType == .friendViewRecommendationStreamType{
            if let delegate = self.scrollDelegate{
                delegate.recommendationViewDidScroll()
            }
          }
       }
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if StreamType == .friendViewRecommendationStreamType{
                if let delegate = self.scrollDelegate{
                    delegate.recommendationDidEndDecelerating()
                }
                
            }
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if StreamType == .friendViewRecommendationStreamType{
                if let delegate = self.scrollDelegate{
                    delegate.recommendationscrollViewDidEndDragging()
                }
                
            }
            
        }
        
    
    
}
