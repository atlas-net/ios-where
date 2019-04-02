//
//  PhotoGroupPickerViewController.swift
//  XYPhoto
//
//  Created by jiaxiaoyan on 16/7/20.
//  Copyright © 2016年 jiaxiaoyan. All rights reserved.
//
import UIKit
import Photos

class PhotoGroupPickerViewController: UIViewController,PhotoGroupTableDelegate {
    var tableView : PhotoGroupTableView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setUpTableView()
    }
    
    func setUpTableView(){
        if tableView == nil{
            tableView = PhotoGroupTableView()
            let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            tableView.setUpSelf(rect)
            tableView.photoGroupDelegate = self
            view.addSubview(tableView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setnav()
    }
    func setnav() {
        title = "照片"
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 110, height: 44)
        backButton.backgroundColor = UIColor.clear
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, -40)

        backButton.setTitle(NSLocalizedString("Cancle", comment: "取消"), for: UIControlState())
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backButton.setTitleColor(Config.Colors.MainContentColorBlack, for: UIControlState())
        backButton.addTarget(self, action: #selector(PhotoGroupPickerViewController.cancleButtonClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.hidesBackButton = true
    }
    
    func  cancleButtonClick() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func didSelectPhotoGroupTableRowCallBack(_ cell : PhotoGroupCell){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let pickerVC = mainStoryboard.instantiateViewController(withIdentifier: "PhotoLibraryController") as! PhotoLibraryController
        self.navigationController?.pushViewController(pickerVC, animated: true)
        pickerVC.navTitle = cell.groupNameLabel.text!
        pickerVC.assetCollection = cell.group
        
        pickerVC.elementCounts = cell.counts
        print("pickerVC.elementCounts：    \(pickerVC.elementCounts)")

    }
}
