//
//  LatestRecommendationViewController.swift
//  Atlas
//
//  Created by yingyang on 16/6/16.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
class LatestRecommendationViewController: BaseTimeRecommendationTableViewController {
    
    //MARK: - Properties
    var loadingV = LoadingView()
    var segmentHeight:CGFloat = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.tableView.rowHeight = 200
       self.tableView.contentInset = UIEdgeInsetsMake(segmentHeight, 0, 0, 0)
        fetchData()
    }
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0,  y: -39,width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.loadingV)
        
    }
    
    override func fetchData(){
        let recommendationQuery = DataQueryProvider.latestRecommendationForLatestDate(nil, oldestDate: nil)
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
                print(error)
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            }else{
                if let recommendations = objects as? [Recommendation]{
                    self.recommendations = recommendations
                }
                
                if self.recommendations.count > 0{
                    self.hideEmptyStreamLabel()
                    self.lastestDate = self.recommendations.first!.createdAt
                    self.oldestDate = self.recommendations.last!.createdAt
                    self.tableView.reloadData()
                }else{
                    self.showEmptyStreamLabel()
                }
                
            }
        }
    }
    
    
    override func fetchDataWithLatestDate(_ latestDate:Date){
        
        let recommendationQuery = DataQueryProvider.latestRecommendationForLatestDate(latestDate, oldestDate: nil)
        
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            }else{
                var recommendationArray = [Recommendation]()
                for obj in objects! {
                    if let recommendation = obj as? Recommendation{
                        recommendationArray.append(recommendation)
                    }
                }
                if recommendationArray.count > 0{
                    recommendationArray += self.recommendations
                    self.recommendations = recommendationArray
                }
                
                if self.recommendations.count > 0{
                    self.hideEmptyStreamLabel()
                    self.lastestDate = self.recommendations.first!.createdAt
                    self.oldestDate = self.recommendations.last!.createdAt
                    self.tableView.reloadData()
                }else{
                    self.showEmptyStreamLabel()
                }
                
            }
        }
    }
    
    override func fetchDataWithOldestDate(_ oldestDate:Date){
        let recommendationQuery = DataQueryProvider.latestRecommendationForLatestDate(nil, oldestDate: oldestDate)
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            }else{
                for obj in objects! {
                    if let recommendation = obj as? Recommendation{
                        self.recommendations.append(recommendation)
                    }
                }
                if self.recommendations.count > 0{
                    self.hideEmptyStreamLabel()
                    self.lastestDate = self.recommendations.first!.createdAt
                    self.oldestDate = self.recommendations.last!.createdAt
                    self.tableView.reloadData()
                }else{
                    self.showEmptyStreamLabel()
                }
                
            }
        }
    }

    
}
