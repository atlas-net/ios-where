//
//  PhotoGroupTableView.swift
//  XYPhoto
//
//  Created by jiaxiaoyan on 16/7/20.
//  Copyright © 2016年 jiaxiaoyan. All rights reserved.
//

import UIKit
import Photos

@objc protocol PhotoGroupTableDelegate {
    func didSelectPhotoGroupTableRowCallBack(_ cell : PhotoGroupCell)
}

//enum AlbumType {
//    case cameraRollAlbum,SelfieAlbum,ScreenshotsAlbum
//}
class PhotoGroupTableView: UITableView,UITableViewDataSource,UITableViewDelegate {
    var tableCellIdentifier = "PhotoGroupCell"
    var groups = [PhotoGroupItem]()
    var assetsFetchResults: PHFetchResult<PHAsset>?
    var totleCount = 0
    weak var photoGroupDelegate : PhotoGroupTableDelegate?
    func setUpSelf(_ rect : CGRect){
        frame = rect
        backgroundColor = UIColor.clear
        separatorStyle = .singleLine
        separatorInset = UIEdgeInsetsMake(0, -120, 0, -120)
        register(UINib(nibName : tableCellIdentifier, bundle : nil), forCellReuseIdentifier: tableCellIdentifier)
        
        setDataSource()
    }
    
    func setDataSource() {
        
        
        
        let states = PHPhotoLibrary.authorizationStatus()
        if states == .denied {
            showAlert()
        }else if states == .authorized{
            delegate = self
            dataSource = self
            
            weak var weakSelf = self
            self.groups.removeAll()


           
            let cameraRollAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            getGroupData(cameraRollAlbums as! PHFetchResult<AnyObject>)
        
            let recentAddAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
            getGroupData(recentAddAlbums as! PHFetchResult<AnyObject>)
            
            
            let SelfieAndScreenshotsAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            SelfieAndScreenshotsAlbums.enumerateObjects( {(collections, count, success) in
                    if let assetCollection = collections as? PHAssetCollection {                        
                        if assetCollection.localizedTitle == "Screenshots" || assetCollection.localizedTitle == "Selfies" || assetCollection.localizedTitle == "自拍" || assetCollection.localizedTitle == "屏幕快照"{

                            weakSelf!.fillDataSoure(assetCollection)
                        }
                    }
            } )

            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
            
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: userAlbumsOptions)
            print("userAlbums : \(userAlbums.count)")
            getGroupData(userAlbums as! PHFetchResult<AnyObject>)
           
        }
        
    }
    
    func getGroupData(_ phAssestResult :PHFetchResult<AnyObject>) {
        
        weak var weakSelf = self

        phAssestResult.enumerateObjects( {(collections, count, success) in
                if let collection = collections as? PHAssetCollection {
                    weakSelf!.fillDataSoure(collection)
                }
        } )
    }
    
    func fillDataSoure(_ phAssetCollection : PHAssetCollection) {
        weak var weakSelf = self

        let onlyImagesOptions = PHFetchOptions()
        onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
        if let result = PHAsset.fetchKeyAssets(in: phAssetCollection, options: onlyImagesOptions) {
            if result.count > 0{
//                print("Images count: \(result.count)")
                let groupItem = PhotoGroupItem()
                groupItem.groupName = phAssetCollection.localizedTitle
                groupItem.group = phAssetCollection
                weakSelf!.groups.append(groupItem)
                
                weakSelf?.reloadData()
  
            }
            
        }
    }
    func refesh(){

        reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.groups.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! PhotoGroupCell
        for subView in cell.contentView.subviews {
            subView.isHidden = true
        }
        let group = groups[(indexPath as NSIndexPath).row]
        
        cell.commomInitCell(group)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PhotoGroupCell
        if let target = photoGroupDelegate {
            target.didSelectPhotoGroupTableRowCallBack(cell)
        }
    }

}
extension PhotoGroupTableView{
    func showAlert()  {
         let   mainInfoDictory =  Bundle.main.infoDictionary!
            
        let appName = mainInfoDictory["CFBundleName"] as! String
        let alertController = UIAlertController(title: "提示",message: "请前往设置－>隐私－>照片,允许" + appName + "使用获取相册功能", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancle", comment: "取消"), style: UIAlertActionStyle.default,handler: {  action in
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController!.present(alertController, animated: true, completion: nil)

    }
    
}
