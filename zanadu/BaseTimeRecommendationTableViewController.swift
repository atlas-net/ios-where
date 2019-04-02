//
//  BaseTimeRecommendationTableViewController.swift
//  Atlas
//
//  Created by yingyang on 16/6/21.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
import MJRefresh

class BaseTimeRecommendationTableViewController: BaseRecommendationTableViewController {
    var lastestDate:Date?
    var oldestDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefresh()
        
    }
    
     func setupRefresh() {
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            if let latestD = self.lastestDate{
                self.fetchDataWithLatestDate(latestD)
            }else{
                self.fetchData()
            }
        })
        self.tableView.mj_header.isAutomaticallyChangeAlpha = true
        if let header = tableView.mj_header as? MJRefreshNormalHeader{
            header.stateLabel.textColor = Config.Colors.SecondTitleColor
            header.lastUpdatedTimeLabel.textColor = Config.Colors.SecondTitleColor
            header.activityIndicatorViewStyle = .gray
            header.arrowView.image = UIImage(named:"refreshArrow")?.withRenderingMode(.alwaysTemplate)
            header.arrowView.tintColor = Config.Colors.SecondTitleColor
            
        }
        
        self.tableView.mj_footer  =  MJRefreshAutoNormalFooter.init(refreshingBlock: {
            if let oldestD = self.oldestDate{
                self.fetchDataWithOldestDate(oldestD)
            }else{
                self.fetchData()
            }
        })
        self.tableView.mj_footer.isAutomaticallyChangeAlpha = true
        if let footer = tableView.mj_footer as? MJRefreshAutoNormalFooter{
            footer.stateLabel.textColor = Config.Colors.SecondTitleColor
            footer.activityIndicatorViewStyle = .gray
            
        }
    }

}
