//
//  PhotoLibraryController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/1/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import Foundation
import UIKit
import Photos

enum PhotoLibraryState {
    case library
    case camera
    case slideshow
}

enum PhotoLibraryTarget {
    case recommendation
    case userAvatar
    case userCover
    case recommendationCover
    case recommendationAddPhoto
}

protocol PhotoLibraryControllerDelegate {
    func photoLibraryControllerDelegateDidChangeCover(_ photo: Photo)
    func photoLibraryControllerDelegateDidAddPhoto(_ photos: [Photo])
}

class PhotoLibraryController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NYTPhotosViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photosViewController: NYTPhotosViewController?
    var isFromRecommendation = false

    var target: PhotoLibraryTarget = .recommendation
    fileprivate var state: PhotoLibraryState = .library
    fileprivate var imageManager: PHCachingImageManager!
    
    fileprivate var previousPreheatRect: CGRect?
    
    var assetCollection : PHAssetCollection?
    var  navTitle = ""
    var  elementCounts = 0
    var assetsFetchResults: PHFetchResult<PHAsset>?
  //  private var assetCollection: PHAssetCollection?
    
    let minimumSpacingBetweenItems: CGFloat = 2
    
    // MARK: - PhotoLibrary Properties
    
    static let Library = PHPhotoLibrary.shared()
    var assets:[PHAsset] = []
    var selectedAssets:[PHAsset] = []
    var currentIndex:Int = -1
    let photoCellIdentifier = "PhotoViewCell"
    let cameraCellIdentifier = "CameraButtonViewCell"
    var showPhotosCount = 20
    var limitPhotoCount = 20
    var isSettingData = false
    
    var assetGridThumbnailSize: CGSize!
    
    // MARK: SlideShow Properties
    
    var viewConstraints:[AnyObject]?
    var photos:[AssetPhoto] = []
    
    
    // MARK: ImagePicker Properties
    
    var imagePickerController:UIImagePickerController?
    //MARK: recommendationDetail Properties
    var recommendationCover:Photo?
    var delegate: PhotoLibraryControllerDelegate?
    
    // MARK: - PhotoLibrary Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var bottomBar: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var bottomBarUser: UIView!
    @IBOutlet weak var validateButton: UIButton!
    
    
    // MARK: - PhotoLibrary Action
    
    @IBAction func onValidateButtonTappped(_ sender: AnyObject) {
        let user = User.current() as? User
        let indicatorFrame = CGRect(
            x: validateButton.frame.width / 2 - validateButton.frame.height / 2,
            y: 0, width: validateButton.frame.height, height: validateButton.frame.height)
        
        let buttonIndicator = UIActivityIndicatorView(frame: indicatorFrame)
        buttonIndicator.tintColor = Config.Colors.ZanaduCerisePink
        validateButton.addSubview(buttonIndicator)
        
        
        
        if selectedAssets.count > 0 {
            _ = Photo(asset: selectedAssets[0], completion: {(photo) -> () in
                if self.target == .userAvatar {
                    user?.avatar = photo
                } else if self.target == .userCover {
                    user?.cover = photo
                } else if self.target == .recommendationCover{
                    self.recommendationCover = photo
                    if let delegate = self.delegate {
                        delegate.photoLibraryControllerDelegateDidChangeCover(self.recommendationCover!)
                    }
                    self.navigationController?.popViewController(animated: true)
                    return
                }else{
                    return
                }
                buttonIndicator.startAnimating()
                
                self.validateButton.setTitle("", for: UIControlState())
                self.validateButton.isEnabled = false
                self.validateButton.backgroundColor = Config.Colors.ZanaduGrey
                
                photo.saveInBackground({ (success, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                        buttonIndicator.stopAnimating()
                        self.validateButton.setTitle(NSLocalizedString("Save", comment: "保存"), for: UIControlState())
                        self.validateButton.isEnabled = true
                        self.validateButton.backgroundColor = Config.Colors.ZanaduCerisePink
                        self.showBasicAlertWithTitle("保存失败，请检查网络再试一次")
                        
                    } else {
                        user?.saveInBackground({ (success, error) -> Void in
                            if error != nil {
                                log.error(error?.localizedDescription)
                                
                                buttonIndicator.stopAnimating()
                                self.validateButton.setTitle(NSLocalizedString("Save", comment: "保存"), for: UIControlState())
                                self.validateButton.isEnabled = true
                                self.validateButton.backgroundColor = Config.Colors.ZanaduCerisePink
                                self.showBasicAlertWithTitle("保存失败，请检查网络再试一次")
                                
                            } else {
                                buttonIndicator.stopAnimating()
                                self.validateButton.setTitle(NSLocalizedString("Save", comment: "保存"), for: UIControlState())
                                self.validateButton.isEnabled = true
                                self.validateButton.backgroundColor = Config.Colors.ZanaduCerisePink
                                
                                self.showChangeAlert()
                            }
                        })
                    }
                })
            })
            if  self.target ==  .recommendationAddPhoto {
                var photoArr = [Photo]()
                for asset in selectedAssets {
                    let photo = Photo(asset: asset)
                    photoArr.append(photo)
                }
                if let delegate = self.delegate {
                    delegate.photoLibraryControllerDelegateDidAddPhoto(photoArr)
                }
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
    }
    
    override func awakeFromNib() {
        PhotoLibrary.SharedLibrary.register(self)
    }
    
    deinit {
        PhotoLibrary.SharedLibrary.unregisterChangeObserver(self)
    }
    
    fileprivate func showChangeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("remind", comment: "提醒"),message:NSLocalizedString("Successfully", comment: "上传成功"), preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Sure", comment: "确定"), style: UIAlertActionStyle.default,handler: {  action in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    // MARK: ImagePicker Outlets
    
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var galleryButton: UIButton!
    
    
    // MARK: ImagePicker Actions
    
    @IBAction func onThumbnailButtonClicked(_ sender: UIButton) {
        print("thumbnailButton or cancelButton", terminator: "")
        self.dismiss(animated: true, completion:nil)
        state = .library
    }
    
    @IBAction func onPhotoButtonClicked(_ sender: UIButton) {
        imagePickerController?.showsCameraControls = false
        imagePickerController!.takePicture()
        //        imagePickerController?.showsCameraControls = true
    }
    
    
    //MARK: - ViewController's Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Foundation.UserDefaults.standard.removeObject(forKey: "draftLastStep")
        Foundation.UserDefaults.standard.synchronize()
        // leancloud AVAnalytics
        AVAnalytics.event("动态开始创建")
        guard let _ = User.current() else{return}

        state = .library

        
        let assetGridThumbnailWidth: CGFloat = (collectionView.frame.width - minimumSpacingBetweenItems * 2) / 3
        self.assetGridThumbnailSize = CGSize(width: assetGridThumbnailWidth, height: assetGridThumbnailWidth)
        

        
        if bottomBar.superview is NYTPhotosOverlayView {
            self.collectionView.addSubview(self.bottomBar)
            self.view.removeConstraints(self.view.constraints)
            self.view.addConstraints(self.viewConstraints! as! [NSLayoutConstraint])
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = User.current() else{return}
        // Begin caching assets in and around collection view's visible rect.
        if let _ = self.previousPreheatRect{
        self.updateCachedAssets()
        }else{
            commentInit()
        }
    }

    func cancleButtonClick() {
        if isFromRecommendation {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
            
        }
    }

    
    
    func preparePhotosArrayForNYTPhotoViewer() {
        

        let priority = DispatchQueue.GlobalQueuePriority.high
        DispatchQueue.global(priority: priority).async {

            self.photos.removeAll(keepingCapacity: true)
            if let fetchResult = self.assetsFetchResults , fetchResult.count > 0 {
                for i in 0...fetchResult.count-1 {
                    self.photos.append(AssetPhoto(asset: fetchResult[i] as! PHAsset))
                }
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Router.Storyboard = self.storyboard
        
        guard let _ = User.current()  else{
            Router.redirectToLoginViewController(fromViewController: self)
            return
        }
        commentInit()
       setNav()
    }
    func setNav() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        backButton.backgroundColor = UIColor.clear
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setImage(UIImage(named: "backIcon"), for: UIControlState())
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        backButton.setTitle(NSLocalizedString("Back", comment:"返回"), for: UIControlState())
        backButton.setTitleColor(Config.Colors.MainContentColorBlack, for: UIControlState())
        backButton.addTarget(self, action: #selector(PhotoLibraryController.backButtonClick), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        
        let cancleButton = UIButton(type: .custom)
        cancleButton.frame = CGRect(x: 0, y: 0, width: 110, height: 44)
        cancleButton.backgroundColor = UIColor.clear
        cancleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, -40)
        cancleButton.setTitle(NSLocalizedString("Cancle", comment: "取消"), for: UIControlState())
        cancleButton.setTitleColor(Config.Colors.MainContentColorBlack, for: UIControlState())
        cancleButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)

        cancleButton.addTarget(self, action: #selector(PhotoLibraryController.cancleButtonClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: cancleButton)

    }
    func commentInit(){

        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let assetCollection = assetCollection {
            title = navTitle
            self.assetsFetchResults = nil
            self.photos.removeAll()
            let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            self.assetsFetchResults = fetchResult
            fetchResult.enumerateObjects({ (collections, count, success) in
//                print("的groupAsset：    \(count)")
//                print("self.elementCounts：    \(self.elementCounts)")

                if self.elementCounts == count+1{
                    for i in 0...fetchResult.count-1 {
                        self.photos.append(AssetPhoto(asset: fetchResult[i] ))
                    }
                    self.collectionView.reloadData()
                }
            })
        }else{
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            self.assetsFetchResults = PHAsset.fetchAssets(with: fetchOptions)
            preparePhotosArrayForNYTPhotoViewer()
            title = NSLocalizedString("Camera Roll", comment: "相机胶卷")
        }
        
        
        self.imageManager = PHCachingImageManager()
        resetCachedAssets()
        
        self.collectionView.register(UINib(nibName: photoCellIdentifier, bundle: nil), forCellWithReuseIdentifier: photoCellIdentifier)
        self.collectionView.register(UINib(nibName: cameraCellIdentifier, bundle: nil), forCellWithReuseIdentifier: cameraCellIdentifier)
        
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(PhotoLibraryController.handleNotification(_:)), name: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil)
        Foundation.NotificationCenter.default.addObserver(self, selector:#selector(PhotoLibraryController.handleNotification(_:)), name: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"), object:nil)
        
        
        if target == .recommendation {
            bottomBarUser.isHidden = true
            if !RecommendationFactory.created() {
                RecommendationFactory.createEmpty()
            } else {
                selectedAssets = RecommendationFactory.sharedInstance.photoAssets
            }
            updateBottomBar()
        }else if target == .recommendationCover{
            self.validateButton.setTitle("添加", for: UIControlState())
            bottomBarUser.isHidden = false
            bottomBar.isHidden = true
            bottomBarUser.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }else if target == .recommendationAddPhoto{
            self.validateButton.setTitle("添加", for: UIControlState())
            bottomBarUser.isHidden = false
            bottomBar.isHidden = true
            bottomBarUser.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }else {
            bottomBarUser.isHidden = false
            bottomBar.isHidden = true
            bottomBarUser.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
        
        if self.assets.isEmpty {
//             setupData()
        }

        
    }
    
    func  backButtonClick() {

        DraftManager.removeDraftFromSandBox()
        self.navigationController?.popViewController(animated: true)
    }

    
    func handleNotification(_ message: Foundation.Notification) {
        if message.name.rawValue == "_UIImagePickerControllerUserDidCaptureItem" {
            // Remove overlay, so that it is not available on the preview view;
            print("pick", terminator: "")
            self.imagePickerController!.cameraOverlayView = nil
        }
        if message.name.rawValue == "_UIImagePickerControllerUserDidRejectItem" {
            // Remove overlay, so that it is not available on the preview view;
            print("reject", terminator: "")
            self.imagePickerController!.cameraOverlayView = self.overlayView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        if target == .recommendation {
            if segue?.identifier == "showLocationScreen" {

                
                var tmpLocation: CLLocation?
                RecommendationFactory.sharedInstance.photos.removeAll(keepingCapacity: true)
                RecommendationFactory.sharedInstance.venue = nil
                
                var draftPhotosArray = [DraftPhotos]()
                var count = 0
                for asset in selectedAssets {
                    count += 1
                    let photo = Photo(asset: asset)

                    RecommendationFactory.sharedInstance.photos.append(photo)
                    if let location = photo.location , tmpLocation == nil {

                        //locations.append(CGPointMake(CGFloat(location.latitude), CGFloat(location.longitude)))
                        tmpLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    }
                    let draftPhoto = DraftPhotos()
                    draftPhoto.createPhotoInfoFrom(photo)
                    draftPhotosArray.append(draftPhoto)
                    let imageFileSuffix = "image" + String(count)
                    Foundation.UserDefaults.standard.set((photo.file?.name)!, forKey: imageFileSuffix)
                    Foundation.UserDefaults.standard.synchronize()
                    DraftManager.saveImagetoSandboxWithPath(photo.imageData!, pathExtension: imageFileSuffix)
                }
                
                RecommendationFactory.sharedInstance.photosCenter = tmpLocation
                RecommendationFactory.sharedInstance.draftArray.removeAll()
                RecommendationFactory.sharedInstance.draftArray.append(draftPhotosArray as AnyObject)
                
                if photosViewController != nil && state == .slideshow {

                    self.dismiss(animated: false, completion:nil)
                }
            }
        }
    }
    
    
    // MARK: - PhotoLibraryController Methods
    
    func reloadData() {
        self.assets = []
        self.photos = []
     //   setupData()
    }
    
    func setupData() {
        if isSettingData == true {
            return
        }
        isSettingData = true

        PhotoLibrary.enumerateAssetsWithBlock { (object, index, _) -> Void in
            if let asset = object as? PHAsset {
                //                let imageManager = PHImageManager.defaultManager()
                //                let requestOptions = PHImageRequestOptions()
                //                requestOptions.networkAccessAllowed = false
                //                requestOptions.synchronous = true
                //
                //                imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 1, height: 1), contentMode: PHImageContentMode.AspectFit, options: requestOptions, resultHandler: { (image, info) -> Void in
                //                    if let info = info {
                //                      //
                //                      //
                //                        //info![PHImageResultIsInCloudKey] as! Int == 1
                //                      //
                //                      //
                //                    }
                //                    if image != nil {
                self.assets.append(asset)
                self.photos.append(AssetPhoto(asset:asset))
                //                    }
                //                })
            }
        }

        
        self.collectionView!.reloadData()
        

        
        // It should be way faster in many cases. What do you think?
        if self.selectedAssets.count > 0 {
            var rmIndices = [Int]()
            for (index, selectedAsset) in self.selectedAssets.enumerated() {
                let cont = self.assets.contains {a in
                    a.localIdentifier == selectedAsset.localIdentifier
                }
                if !cont {
                    rmIndices.append(index)
                }
            }
            for rmIndice in rmIndices.reversed() {
                self.selectedAssets.remove(at: rmIndice)
            }
            self.updateBottomBar()
        }

        isSettingData = false
    }
    
    func isSelectedAsset(_ asset: PHAsset) -> Bool {
        return selectedAssets.contains {a in
            a.localIdentifier == asset.localIdentifier
        }
    }
    
    func shouldSelectAsset(_ asset: PHAsset) -> Bool {
        var checked: Bool = false
        
        if !isSelectedAsset(asset) {
            if target == .recommendation {
                if selectedAssets.count < Config.AppConf.MaxPhotoPerRecommendation {
                    selectedAssets.append(asset)
                    RecommendationFactory.sharedInstance.photoAssets.append(asset)
                    checked = true
                } else {
                    self.showBasicAlertWithTitle("最多\(limitPhotoCount)张")
                    
                }
            } else if target == .recommendationAddPhoto {
                
                if selectedAssets.count < self.limitPhotoCount {
                    selectedAssets.append(asset)
                    checked = true
                } else {
                    self.showBasicAlertWithTitle("最多\(self.limitPhotoCount)张")

                }
            } else if target == .recommendationCover {
                if selectedAssets.count > 0{
                    self.showBasicAlertWithTitle("最多1张")
                }else{
                    selectedAssets.append(asset)
                    checked = true
                }
            }else {
                if selectedAssets.count == 0 {
                    selectedAssets.append(asset)
                    checked = true
                } else {
                    self.showBasicAlertWithTitle("最多1张")
                }
            }
        } else {
            let i = find(selectedAssets) { a in
                a.localIdentifier == asset.localIdentifier
            }
            selectedAssets.remove(at: i!)
            
            if target == .recommendation {
                RecommendationFactory.sharedInstance.photoAssets.remove(at: i!)
            }
        }
        updateBottomBar()
        return checked
    }
    
    
    func onSelectButtonClicked(_ cell: PhotoViewCell) {
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [cell.assetIdentifier!], options: nil)
        if fetchResult.count > 0 {
            if let asset = fetchResult[0] as? PHAsset {
                
                shouldSelectAsset(asset)
                let checked = isSelectedAsset(asset) 
                if checked {
                    cell.selectButton()
                } else {
                    cell.deselectButton()
                }
            }
        }
    }
    
    func updateBottomBar() {
        if target == .recommendation {
            countLabel.text = "\(selectedAssets.count)"
            if selectedAssets.count >= Config.AppConf.MinPhotoPerRecommendation {
                nextButton.alpha = 1
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor.clear
                nextButton.addGradientWithColors(Config.Colors.ButtonGradient)
            } else {
                nextButton.alpha = 0.7
                nextButton.isEnabled = false
                nextButton.backgroundColor = Config.Colors.ZanaduGrey
                nextButton.removeGradient()
            }
        }
        else {
            if selectedAssets.count > 0 {
                validateButton.alpha = 1
                validateButton.isEnabled = true
                validateButton.backgroundColor = UIColor.clear
                validateButton.addGradientWithColors(Config.Colors.ButtonGradient)
            } else {
                validateButton.alpha = 0.7
                validateButton.isEnabled = false
                validateButton.backgroundColor = Config.Colors.ZanaduGrey
                validateButton.removeGradient()
            }
        }
    }
    
    func showImagePickerForSourceType(_ sourceType:UIImagePickerControllerSourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        if sourceType == UIImagePickerControllerSourceType.camera {
            /*
            The user wants to use the camera interface. Set up our custom overlay view for the camera.
            */
            imagePickerController.showsCameraControls = true
            
            /*
            Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
            */
            Bundle.main.loadNibNamed("CameraOverlayView", owner:self, options:nil)
            self.overlayView.frame = imagePickerController.cameraOverlayView!.frame
            imagePickerController.cameraOverlayView = self.overlayView
            //self.overlayView = nil
            self.imagePickerController = imagePickerController
            
            
            // add preview of last taken picture if it exists
            //    var albumAssets:[PHAsset] = []
            // search all photo albums in the library
            
            PhotoLibrary.enumerateAssetsWithBlock(Config.AppConf.PhotoAlbumName) { (object, index, _) -> Void in
                if index == 0 {
                    if let asset = object as? PHAsset {
                        let imageManager = PHImageManager.default()
                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isNetworkAccessAllowed = false
                        requestOptions.isSynchronous = false
                        
                        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                            if image != nil {
                                self.galleryButton.setImage(image, for: UIControlState())
                            }
                        })
                    }
                }
            }
            
            //            PhotoLibraryController.Library.enumerateGroupsWithTypes(Config.AppConf.PhotoAlbumName, usingBlock: { (group, stop) -> Void in
            //
            //                //compare the names of the albums
            //                if group != nil && Config.AppConf.PhotoAlbumName == group.valueForProperty(ALAssetsGroupPropertyName) as! String {
            //
            //                    //search in app album for pics
            //                    let assetBlock : ALAssetsGroupEnumerationResultsBlock = {
            //                        (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            //
            //                        if asset != nil {
            //                            albumAssets.append(asset)
            //                        }
            //                    }
            //                    group.enumerateAssetsUsingBlock(assetBlock)
            //                } else if group == nil {
            //                    // order assets by date
            //                    albumAssets.sortInPlace({($0.valueForProperty(ALAssetPropertyDate) as! NSDate).compare($1.valueForProperty(ALAssetPropertyDate) as! NSDate) == NSComparisonResult.OrderedDescending})
            //
            //                    //take the 1st one
            //                    if albumAssets.count > 0 {
            //                        let thumbAsset = albumAssets[0]
            //                        //display it to imageView
            //                        self.galleryButton.setImage(UIImage(CGImage: thumbAsset.thumbnail().takeUnretainedValue()), forState: UIControlState.Normal)
            //                    }
            //
            //                }
            //
            //
            //                }) { (error) -> Void in
            //                    print(error, terminator: "")
            //            }
            
            
            self.present(self.imagePickerController!, animated:true, completion:nil)
            
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: NSInteger) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
    
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for:indexPath) as! PhotoViewCell
            
            if cell.delegate == nil {
                cell.delegate = self
                cell.addTapListener()
            }
            
            
            cell.button.tag = (indexPath as NSIndexPath).row
            cell.aroundButton.tag = (indexPath as NSIndexPath).row
            cell.thumbnailImageView.tag = (indexPath as NSIndexPath).row
            
            guard let result = self.assetsFetchResults else {
                return cell
            }
            
            guard let asset = result[(indexPath as NSIndexPath).item ] as? PHAsset else {
                return cell
            }
            
            
            isSelectedAsset(asset) ? cell.selectButton() : cell.deselectButton()
            
            cell.assetIdentifier = asset.localIdentifier
            
            self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (image, info) -> Void in
                if cell.assetIdentifier == asset.localIdentifier {
                    cell.thumbnailImage = image
                }
            })
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        if SizeClass.horizontalClass == UIUserInterfaceSizeClass.Compact {
        //
        //        return CGSize(width: 105, height: 105)
        let width: CGFloat = (collectionView.frame.width - minimumSpacingBetweenItems * 2) / 3
        //return self.assetGridThumbnailSize  
        return CGSize(width: width, height: width)
        
        //        } else {
        //
        //            return CGSize(width: 236, height: 236)
        //        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumSpacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumSpacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    //mark  fix Yuko
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         self.collectionView!.reloadData()
    }

    // MARK: NYTPhotosViewControllerDelegate
    func photosViewController(_ photosViewController: NYTPhotosViewController!, handleActionButtonTappedFor photo: NYTPhoto!) -> Bool {
        
        
        let photo = photo as! AssetPhoto
        let index: Int = photos.index(of: photo)!
        let indexPath = IndexPath(item: index, section: 0)


        
        let asset = assetsFetchResults![index] as! PHAsset
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoViewCell {
            self.onSelectButtonClicked(cell)
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [cell.assetIdentifier!], options: nil)
            if fetchResult.count > 0 {
                if let asset = fetchResult[0] as? PHAsset{
                    let checked = isSelectedAsset(asset)
                    checked ? photosViewController.selectButton() : photosViewController.deselectButton()
                }
            }
            
        } else {
            let checked = shouldSelectAsset(asset)
            checked ? photosViewController.selectButton() : photosViewController.deselectButton()
        }

        print("Button Tapped", terminator: "")
        return true
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController!, referenceViewFor photo: NYTPhoto!) -> UIView! {
        return (collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as! PhotoViewCell).thumbnailImageView
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController!, loadingViewFor photo: NYTPhoto!) -> UIView! {
        return nil
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController!, captionViewFor photo: NYTPhoto!) -> UIView! {
        return self.bottomBar
    }

    
    
    func photosViewController(_ photosViewController: NYTPhotosViewController!, didNavigateTo photo: NYTPhoto!, at photoIndex: UInt) {
        print("Did Display Photo: \(photo) identifier: \(photoIndex)", terminator: "")
        
        isSelectedAsset((photo as! AssetPhoto).asset!) ? photosViewController.selectButton() : photosViewController.deselectButton()
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController!, actionCompletedWithActivityType activityType: String!) {
        print("Action Completed With Activity Type: \(activityType)", terminator: "")
    }
    
    func photosViewControllerDidDismiss(_ photosViewController: NYTPhotosViewController!) {
        print("Did dismiss Photo Viewer: \(photosViewController)", terminator: "")
        
        self.collectionView.addSubview(self.bottomBar)
        self.view.removeConstraints(self.view.constraints)
        self.view.addConstraints(self.viewConstraints as! [NSLayoutConstraint])
        state = .library
    }
    
    
    
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    // This method is called when an image has been chosen from the library or taken from the camera.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        print("image picked : \(image) withInfo : \(editingInfo)")
        self.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("image picked info : \(info)")
        
        print("image picked info : \(info)", terminator: "")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print("image: \(image))", terminator: "")
        PhotoLibrary.saveToAlbum(image, album: Config.AppConf.PhotoAlbumName)
        reloadData()
        self.dismiss(animated: true, completion:nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion:nil)
    }
    
    //MARK: - Method Overrides
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    //MARK: - Asset Caching
    
    fileprivate func resetCachedAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRect.zero;
    }
    
    fileprivate func updateCachedAssets() {
        let isViewVisible: Bool = self.isViewLoaded && self.view.window != nil
        if !isViewVisible { return }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect: CGRect = self.collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height);

        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta: CGFloat = abs(preheatRect.midY - self.previousPreheatRect!.midY)
        
        if (delta > self.collectionView.bounds.height / 3.0) {
            
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths = [IndexPath]()
            var removedIndexPaths = [IndexPath]()
            
            self.computeDifferenceBetweenRect(self.previousPreheatRect!, andRect: preheatRect, removedHandler: { (removedRect) -> () in
                if let indexPaths = self.collectionView.indexPathsForElementsInRect(removedRect) {
                    removedIndexPaths.append(contentsOf: indexPaths)
                }
                }, addedHandler: { (addedRect) -> () in
                    if let indexPaths = self.collectionView.indexPathsForElementsInRect(addedRect) {
                        addedIndexPaths.append(contentsOf: indexPaths)
                    }
            })
            
            
            // Update the assets the PHCachingImageManager is caching.
            if let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths) {
                self.imageManager.startCachingImages(for: assetsToStartCaching,
                    targetSize: assetGridThumbnailSize,
                    contentMode:PHImageContentMode.aspectFit,
                    options:nil)
            }
            
            if let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths) {
                self.imageManager.stopCachingImages(for: assetsToStopCaching,
                    targetSize:assetGridThumbnailSize,
                    contentMode:PHImageContentMode.aspectFit,
                    options:nil)
            }
            
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect;
        }
    }
    
    fileprivate func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler:(CGRect) -> (), addedHandler:(CGRect) -> ()) {
        if (newRect.intersects(oldRect)) {
            let oldMaxY: CGFloat = oldRect.maxY
            let oldMinY: CGFloat = oldRect.minY
            let newMaxY: CGFloat = newRect.maxY
            let newMinY: CGFloat = newRect.minY
            
            if (newMaxY > oldMaxY) {
                let rectToAdd: CGRect = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if (oldMinY > newMinY) {
                let rectToAdd: CGRect = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if (newMaxY < oldMaxY) {
                let rectToRemove: CGRect = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if (oldMinY < newMinY) {
                let rectToRemove: CGRect = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    fileprivate func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset]? {
        if (indexPaths.count == 0) { return nil }
        
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            if let result = self.assetsFetchResults {
                if let asset = result[(indexPath as NSIndexPath).item] as? PHAsset {
                    assets.append(asset)
                }
            }
        }
        return assets
    }
    
    
}

extension PhotoLibraryController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Check if there are changes to the assets we are showing.

        
        guard let result = self.assetsFetchResults else {
            return
        }
        
        guard let collectionChanges: PHFetchResultChangeDetails = changeInstance.changeDetails(for: result as! PHFetchResult<PHObject>) else {
            return
        }
        
        /*
        Change notifications may be made on a background queue. Re-dispatch to the
        main queue before acting on the change as we'll be updating the UI.
        */
        DispatchQueue.main.async {
            // Get the new fetch result.
            self.assetsFetchResults = collectionChanges.fetchResultAfterChanges as! PHFetchResult<PHAsset>

            let collectionView = self.collectionView
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                // Reload the collection view if the incremental diffs are not available
                collectionView?.reloadData()
            } else {
                /*
                Tell the collection view to animate insertions and deletions if we
                have incremental diffs.
                */
                 collectionView?.reloadData()
//                collectionView?.performBatchUpdates({ () -> Void in
//
//                    if let removedIndexes: IndexSet = collectionChanges.removedIndexes {
//                        if removedIndexes.count > 0 {
//                            collectionView?.deleteItems(at: removedIndexes.indexPathsFromIndexesWithSection(0))
//                        }
//                    }
//                    if let insertedIndexes: IndexSet = collectionChanges.insertedIndexes {
//                        if insertedIndexes.count > 0 {
//                            collectionView?.insertItems(at: insertedIndexes.indexPathsFromIndexesWithSection(0))
//
//                        }
//                    }
//                    if let changedIndexes: IndexSet = collectionChanges.changedIndexes {
//                        if changedIndexes.count > 0 {
//                            collectionView?.reloadItems(at: changedIndexes.indexPathsFromIndexesWithSection(0))
//
//                        }
//                    }
//
//                }, completion: nil)

            }
            self.resetCachedAssets()
            self.preparePhotosArrayForNYTPhotoViewer()
        }
    }
    
    //MARK: - Photos authorization
    
    static func isPhotoLibraryAccessAuthorized(_ completion: @escaping (Bool)->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            completion(true)
        } else if status == PHAuthorizationStatus.denied {
            completion(false)
        } else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) -> Void in
                completion(newStatus == PHAuthorizationStatus.authorized)
            })
        }
    }
    
}


//extension PhotoLibraryController:

extension PhotoLibraryController: CameraButtonViewCellSelectionDelegate {
    func onCameraButtonTapped() {
        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.camera)
        state = .camera
    }
}

extension PhotoLibraryController: PhotoViewCellSelectionDelegate {
    func onCellButtonTapped(_ cell: PhotoViewCell) {
        onSelectButtonClicked(cell)
    }
    
    func onAroundCellButtonTapped(_ cell: PhotoViewCell) {
        onSelectButtonClicked(cell)
    }
    
    func onCellThumbnailButtonTapped(_ cell: PhotoViewCell) {
        self.currentIndex = cell.button.tag
        self.viewConstraints = self.view.constraints
        
        photosViewController = NYTPhotosViewController(photos:self.photos, initialPhoto: self.photos[currentIndex])
        photosViewController!.delegate = self
        photosViewController!.setRightBarButtonItemButton((collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as! PhotoViewCell).button)
        photosViewController!.setNavigationBarBackgroundColor()
        
        present(photosViewController!, animated: true, completion: nil)
        state = .slideshow
    }
    
}
extension PhotoLibraryController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update cached assets for the new visible area.
        self.updateCachedAssets()
    }
}


