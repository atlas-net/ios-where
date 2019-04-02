//
//  AroundMeSectionViewController.swift
//  Atlas
//
//  Created by yingyang on 16/6/6.
//  Copyright © 2016年 Atlas. All rights reserved.
//

class AroundMeSectionViewController:BaseTimeRecommendationTableViewController {
    
    
    //MARK: - Properties
    
    var section: Section?
    var loadingV = LoadingView()
    
    
    func onSearchButtonTapped(_ sender:AnyObject) {

        let query =  DataQueryProvider.categoryQuery()
        query.findObjectsInBackground { (objects:[Any]?, error) in
            if error != nil {
                log.error(error!.localizedDescription)
            }else{
                if let categorys = objects as? [Category]{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSearchViewController") as! GlobalSearchViewController
                vc.rootImage = self.view.screenViewShots()
                self.navigationController?.pushViewController(vc, animated: true)
                vc.categoryArray = categorys
                }else{

                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Config.Colors.MainContentBackgroundWhite
        self.addLoadingView()
        guard let section = self.section else{return}
        section.limit = nil
self.navigationItem.title = self.section!.title ?? ""
        fetchData()
    }
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview(self.loadingV)
    }
    
    
    override func fetchData(){
        guard let section = self.section else{return}
        
        let recommendationQuery = section.queryMatchingConditionsWithLatestDate(nil, oldestDate: nil)
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
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
        guard let section = self.section else{return}
        
        let recommendationQuery = section.queryMatchingConditionsWithLatestDate(latestDate, oldestDate: nil)
        
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
        guard let section = self.section else{return}
        let recommendationQuery = section.queryMatchingConditionsWithLatestDate(nil, oldestDate: oldestDate)
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


