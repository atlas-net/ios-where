//
//  PlaceViewController.swift
//  Atlas
//
//  Created by yingyang on 16/6/12.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
import MBProgressHUD
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

class PlaceViewController:  UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var recommendationSectionsStreamView: RecommendationSectionsStreamView!
    
    @IBOutlet weak var recommendationSectionsStreamViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var destinationView: UIView!
    
    @IBOutlet weak var destinationViewHeightConstraint: NSLayoutConstraint!
    
    var loadingV = LoadingView()
    let segmentHeight:CGFloat = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.initDestination()
        DataQueryProvider.sectionsWithPage(1).executeInBackground({ (objects:[Any]?, error) -> () in
            if error != nil {
                log.error("Sections fetching error : \(error?.localizedDescription)")
                self.showBasicAlertWithTitle("网络连接错误")
            } else if let sections = objects as? [Section] , objects?.count > 0 {
                self.recommendationSectionsStreamView.heightChangeDelegate = self
                self.recommendationSectionsStreamView.recommendationSelectionDelegate = self
                self.recommendationSectionsStreamView.sectionSelectionDelegate = self
                self.recommendationSectionsStreamView.setup(sections)
            }
            
        })

    }
   
    func addLoadingView(){
        self.loadingV.frame = CGRect(x: 0, y: -39,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview(self.loadingV)
    }
    
    func destinationClick(_ sender : UIButton)  {
        let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        let tag = sender.tag
        var  parameter = ["" : CLLocation()]
        var radius = 0
        switch tag {
        case 199:
            parameter = ["北京" : CitySwitchLocation.BeiJingLocation]
            radius = CitySwitchLocation.BeijingRadius
        case 200:
            parameter = ["上海" : CitySwitchLocation.ShangHaiLocation]
            radius = CitySwitchLocation.ShanghaiRadius
            
        case 201:
            parameter = ["东京" : CitySwitchLocation.TokyoLocation]
            radius = CitySwitchLocation.TokyoRadius
            
        case 202:
            parameter = ["纽约" : CitySwitchLocation.NewYorkLocation]
            radius = CitySwitchLocation.NewYorkRadius
            
            
        default:
            print("default error")
            return
            
        }
        
        let query =  DataQueryProvider.categoryQuery()
        query.findObjectsInBackground { (objects:[Any]?, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                log.error(error?.localizedDescription)
            }else{
                if let categorys = objects as? [Category]{

                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DestinationDetailViewController") as! DestinationDetailViewController
                vc.currentPosition = parameter
                vc.imageIndex = tag - 199
                vc.locationRadius = radius
                    vc.categoryArray = categorys
                
                let vcs = self.navigationController?.viewControllers
                if vcs?.count > 1{
                    return
                }
                self.navigationController?.pushViewController(vc, animated: true)
                }else{

                }

            }
        }
        
        
    }
    
    func showBasicAlertWithTitle(_ title:String){
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message: title, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func initDestination() {
        self.destinationViewHeightConstraint.constant = UIScreen.main.bounds.width
        self.destinationView.isHidden = true
        let headerButton = UIButton()
        headerButton.frame = CGRect(x: 8, y: 9, width: 78, height: 25)
        headerButton.clipsToBounds = true
//        headerButton.layer.borderColor = Config.Colors.SectionTextColor.CGColor
//        headerButton.layer.cornerRadius = 3
//        headerButton.layer.borderWidth = 1
        headerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        headerButton.setTitle(NSLocalizedString("Destination", comment:"目的地"), for: UIControlState())
        headerButton.backgroundColor = UIColor.clear
        headerButton.setTitleColor(Config.Colors.SectionTextColor, for: UIControlState())
        destinationView.addSubview(headerButton)
        
        let widthItem = (UIScreen.main.bounds.width - 24)/2
        let array = ["北京","上海","东京","纽约"]
        let imgNameArray = ["icon_beijing","icon_shanghai","icon_tokoy","icon_newYork"]
        for i in 0...3{
            let tagButton = UIButton()
            tagButton.frame = CGRect(x: CGFloat((i%2))*(widthItem + 8) + 8,y: CGFloat((i/2))*(widthItem + 8) + 47 , width: widthItem, height: widthItem)
            tagButton.adjustsImageWhenHighlighted = false
            tagButton.clipsToBounds = true
            tagButton.layer.cornerRadius = 3
            tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            tagButton.layer.borderColor = UIColor.white.cgColor
            tagButton.backgroundColor = UIColor.clear
            let imageName = imgNameArray[i]
            tagButton.setBackgroundImage(UIImage.init(named: imageName), for: UIControlState())
            destinationView.addSubview(tagButton)
            //传递触摸对象（即点击的按钮），需要在定义action参数时，方法名称后面带上冒号
            tagButton.addTarget(self,action:#selector(PlaceViewController.destinationClick(_:)),for:.touchUpInside)
            tagButton.tag = 199 + i
            
            //effectCover
            let coverImageV = UIImageView()
            coverImageV.image = UIImage(named:"effectCover398")
            coverImageV.frame = CGRect(x: 0,y: 0, width: widthItem, height: widthItem)
            tagButton.addSubview(coverImageV)
            
            let titleLeb = UILabel()
            titleLeb.frame = CGRect(x: 6, y: 6, width: 70, height: 24)
            titleLeb.font = UIFont.systemFont(ofSize: 15)
            titleLeb.backgroundColor = UIColor.clear
            titleLeb.textColor = UIColor.white
            titleLeb.text = array[i]
            tagButton.addSubview(titleLeb)
        }
    }

  }


extension PlaceViewController: RecommendationSectionsStreamViewHeightDelegate {
    func onHeightChanged(_ height: CGFloat) {
        recommendationSectionsStreamViewHeightConstraint.constant = height
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: height + tabBarController!.tabBar.frame.height  + destinationViewHeightConstraint.constant + Config.AppConf.navigationBarAndStatuesBarHeight + segmentHeight)
        self.loadingV.removeFromSuperview()
        self.destinationView.isHidden = false
    }
}

extension PlaceViewController: RecommendationSelectionProtocol {
    func onRecommendationSelected(_ recommendation: Recommendation) {
        let previewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! CreationPreviewViewController
        previewViewController.recommendation = recommendation
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension PlaceViewController: SectionSelectionProtocol {
    func onSectionButtonSelected(_ section: Section) {
        // leancloud AVAnalytics
        let eventIdStr = "首页\(section.title!)点击"
        AVAnalytics.event( "sectionTitleClick", label:eventIdStr)
        
        if section.type?.intValue == SectionType.normal.rawValue {
            
            let sectionViewController = storyboard?.instantiateViewController(withIdentifier: "SectionViewController") as! SectionViewController
            sectionViewController.section = section
            navigationController?.pushViewController(sectionViewController, animated: true)
        } else {
            let aroundMeSectionViewController = storyboard?.instantiateViewController(withIdentifier: "AroundMeSectionViewController") as! AroundMeSectionViewController
            aroundMeSectionViewController.section = section
            navigationController?.pushViewController(aroundMeSectionViewController, animated: true)
        }
    }
    
    func onSectionItemButtonSelected(_ section: Section) {
        // leancloud AVAnalytics
        AVAnalytics.event("首页周边地图点击")
        let aroundMapViewController = storyboard?.instantiateViewController(withIdentifier: "AroundMapViewController") as! AroundMapViewController
        navigationController?.pushViewController(aroundMapViewController, animated: true)
    }
}
