//
//  FindViewController.swift
//  Atlas
//
//  Created by yingyang on 16/6/16.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class FindViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var titleView: UIView!
    
//    @IBOutlet weak var titleLabel: UILabel!
    var viewControllers = [UIViewController]()
    var currentViewController = UIViewController()
    let segmentHeight:CGFloat = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegment()
        let vc = self.viewControllerForSegmentIndex(segment.selectedSegmentIndex)
        self.addChildViewController(vc)
        vc.view.frame = self.view.bounds
        self.view.addSubview(vc.view)
        currentViewController = vc
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNav()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.frame.size.height = Config.AppConf.navigationBarHeight
    }
    func setupNav(){
        self.navigationController?.isNavigationBarHidden = false
//        self.tabBarController?.navigationController?.navigationBar.frame.size.height = Config.AppConf.navigationBarHeight + segmentHeight
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        titleView.frame = CGRect(x: 0, y:0, width:UIScreen.main.bounds.width, height:60)
        segment.frame = titleView.frame;
        self.tabBarController?.navigationItem.titleView = titleView
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

    }

    func setupSegment() {
        segment.addTarget(self, action: #selector(FindViewController.segmentChange(_:)), for: UIControlEvents.valueChanged)
        
    }
    func segmentChange(_ sender: AnyObject?) {
        let segment:UISegmentedControl = sender as! UISegmentedControl
        let vc = viewControllerForSegmentIndex(segment.selectedSegmentIndex)
        self.addChildViewController(vc)
        self.currentViewController.view.removeFromSuperview()
        vc.view.frame = self.view.bounds
        self.view.addSubview(vc.view)
        self.currentViewController = vc
    }


    func viewControllerForSegmentIndex(_ index:NSInteger) -> UIViewController {
        var vc = UIViewController()
        switch index {
        case 0:
           vc = HottestRecommendationViewController()
            break
        case 1:
             vc = LatestRecommendationViewController()
            break
        default:
            vc = storyboard?.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
            break
        }
        vc.view.backgroundColor = UIColor.clear
        return vc
    }
    
   func onSearchButtonTapped(_ sender:AnyObject) {
    let query =  DataQueryProvider.categoryQuery()
        query.findObjectsInBackground { (objects:[Any]?, error) in
            if error != nil {
                log.error(error?.localizedDescription)
            }else{
                if let categorys = objects as? [Category]{
                    let vcs = self.navigationController?.viewControllers

                    if vcs?.count > 1{
                        return
                    }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSearchViewController") as! GlobalSearchViewController
                    vc.rootImage = self.view.screenViewShots()
                    self.navigationController?.pushViewController(vc, animated: true)
                    vc.categoryArray = categorys

                }else{

                }
            }
        }

        
    }



}
