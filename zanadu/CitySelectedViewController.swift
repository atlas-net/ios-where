//
//  File.swift
//  Atlas
//
//  Created by jiaxiaoyan on 16/3/21.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
/**
 Protocol that transmit result to delegate
 
 You should implement the protocol's methods to handle CameraButtonViewCell events
 */
@objc protocol selectedCityCallBackProtocol{
    func didSelectedCity(_ result : String)
}

class CitySelectedViewController : UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate{
    var bgView = UIImageView()

    @IBOutlet weak var collectionView: UICollectionView!
    let titleArray = ["全部\nAll","北京\nBeijing","上海\nShanghai","东京\nTokyo","纽约\nNew York","期待更多..."]
    var delegate : selectedCityCallBackProtocol?
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        self.bgView.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height )
        self.bgView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height);
        let  img = UIImage(named: "loadingBg")!
        self.bgView.image = img
        self.view.addSubview(bgView)
        self.view.sendSubview(toBack: bgView)
        self.setupNav()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width-24)/2, height: (UIScreen.main.bounds.width-24)/2)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical//设置垂直显示
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)//设置边距
        flowLayout.minimumLineSpacing = 8.0;//每个相邻layout的上下
        flowLayout.minimumInteritemSpacing = 4.0;//每个相邻layout的左右
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 0);
        collectionView.collectionViewLayout = flowLayout
    }
    func setupNav(){
        let navView = UIView()
        navView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        navView.backgroundColor = UIColor(bd_hexColor : "482137")
        self.view.addSubview(navView)

        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        
        let searchFrame = CGRect(x: 0,y: 20, width: 80, height: 44)
        let cancelButton = UIButton(frame: searchFrame)
        
        cancelButton.setTitle(NSLocalizedString("Cancle", comment: "取消"), for: UIControlState())
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.setTitleColor(UIColor.white, for: UIControlState())
        cancelButton.addTarget(self, action: #selector(CitySelectedViewController.onCancelButtonTapped), for: UIControlEvents.touchUpInside)

        self.view.addSubview(cancelButton)


    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    func onCancelButtonTapped(){

        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return titleArray.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityItemCell", for: indexPath)as! CityItemCell
        let imgNameArray = ["icon_quanbu","icon_beijing","icon_shanghai","icon_tokoy","icon_newYork","icon_qidai"]

        cell.titleLab.text = titleArray[(indexPath as NSIndexPath).row]
        cell.imageView.image = UIImage(named: imgNameArray[(indexPath as NSIndexPath).row])
        cell.imageView.cornerRadius = 3
        cell.imageView.clipsToBounds = true
        if (indexPath as NSIndexPath).row == titleArray.count - 1 {
            cell.coverImg.image = UIImage(named: "effectCover398")
        }else{
            cell.coverImg.image = UIImage(named: "effect1")

        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CityItemCell", forIndexPath: indexPath)as! CityItemCell
        if (indexPath as NSIndexPath).row == titleArray.count - 1 {
            return
        }
        var str = titleArray[(indexPath as NSIndexPath).row]
        let index = str.characters.index(str.startIndex, offsetBy: 2)
        str = str.substring(to: index)
        saveChoice(str)
        self.delegate?.didSelectedCity(str)
        self.dismiss(animated: true) { () -> Void in
        }
    }
    
    func saveChoice(_ name:String){
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(name, forKey: "city")
        userDefaults.synchronize()
        
        
            }
    
}
