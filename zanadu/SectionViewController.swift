//
//  SectionViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/28/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
SectionViewController

Display a section's list of recommendations
*/
class SectionViewController : BaseTimeRecommendationTableViewController {

    var section: Section?
    var sectionItems = [SectionItem]()
    var loadingV = LoadingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.addLoadingView()
        guard let section = self.section else{return}
        section.limit = nil
        self.navigationItem.title = self.section!.title ?? ""
        fetchData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.navigationController?.navigationBar.frame.size.height = Config.AppConf.navigationBarHeight
    }
    
   func addLoadingView(){
            self.loadingV.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.addSubview(self.loadingV)
    }
    
    
    override func fetchData(){
        guard let section = self.section else{return}
        
        let recommendationQuery = DataQueryProvider.historyRecommendationForSection(section, latestDate:nil , oldestDate:nil )
        
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
        if error != nil{
            self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
        }else{
            
            for obj in objects! {
                if let sectionItem = obj as? SectionItem{
                    self.recommendations.append(sectionItem.recommendation!)
                    self.sectionItems.append(sectionItem)
                }
            }
            if self.recommendations.count > 0{
                self.hideEmptyStreamLabel()
                self.lastestDate = self.sectionItems.first!.createdAt
                self.oldestDate = self.sectionItems.last!.createdAt
                self.tableView.reloadData()
            }else{
               self.showEmptyStreamLabel()
            }
           
        }
        }
    }
    
    
    override func fetchDataWithLatestDate(_ latestDate:Date){
        guard let section = self.section else{return}
        
        let recommendationQuery = DataQueryProvider.historyRecommendationForSection(section, latestDate:latestDate , oldestDate:nil )
        
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            }else{
                var recommendationArray = [Recommendation]()
                var  sectionItemArray = [SectionItem]()
                for obj in objects! {
                    if let sectionItem = obj as? SectionItem{
                        recommendationArray.append(sectionItem.recommendation!)
                        sectionItemArray.append(sectionItem)
                    }
                }
                if recommendationArray.count > 0{
                    recommendationArray += self.recommendations
                    self.recommendations = recommendationArray
                    sectionItemArray += self.sectionItems
                    self.sectionItems = sectionItemArray
                }
                
                if self.recommendations.count > 0{
                    self.hideEmptyStreamLabel()
                    self.lastestDate = self.sectionItems.first!.createdAt
                    self.oldestDate = self.sectionItems.last!.createdAt
                    self.tableView.reloadData()
                }else{
                    self.showEmptyStreamLabel()
                }
                
            }
        }
    }
    
    override func fetchDataWithOldestDate(_ oldestDate:Date){
        guard let section = self.section else{return}
         let recommendationQuery = DataQueryProvider.historyRecommendationForSection(section, latestDate:nil , oldestDate:oldestDate )
        recommendationQuery.executeInBackground { (objects:[Any]?, error) in
            self.loadingV.removeFromSuperview()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if error != nil{
                self.showBasicAlertWithTitle(NSLocalizedString("Load timeout", comment:"加载超时"))
            }else{
                for obj in objects! {
                    if let sectionItem = obj as? SectionItem{
                        self.recommendations.append(sectionItem.recommendation!)
                        self.sectionItems.append(sectionItem)
                    }
                }
                if self.recommendations.count > 0{
                    self.hideEmptyStreamLabel()
                    self.lastestDate = self.sectionItems.first!.createdAt
                    self.oldestDate = self.sectionItems.last!.createdAt
                    self.tableView.reloadData()
                }else{
                    self.showEmptyStreamLabel()
                }
                
            }
        }
    }
    
}
