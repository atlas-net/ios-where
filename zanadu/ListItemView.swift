//
//  ListItemView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/18/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




protocol ListItemViewSelectionDelegate {
    func onListItemTitleTapped(_ listItem: ListItem)
    func onListItemPhotoTappedWithPhotos(_ photos:[Photo], selectedIndex index:Int)
}


/**
ListItemView

how to display a ListItem
*/
class ListItemView : UIView,LGSublimationViewDelegate {
    
    //MARK: - Properties
    
    weak var listItem: ListItem!
    var selectionDelegate: ListItemViewSelectionDelegate?
    var container: ResizableLayoutItemContainer?
    var photos:[Photo]?

    //MARK: - Outlets
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var slideshowView: LGSublimationView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var venueImgView: UIImageView!

    
    //MARK: - Initializers
    
    //MARK: - Actions
    
    func onListItemSelected() {
        if let selectionDelegate = selectionDelegate {
            selectionDelegate.onListItemTitleTapped(listItem)
        }
    }
    
    //MARK: - Methods
    
    func setupWithListItem(_ listItem: ListItem, andIndex index: Int, selectionDelegate: ListItemViewSelectionDelegate? = nil) {
        self.listItem = listItem
        self.selectionDelegate = selectionDelegate
        
        backgroundColor = UIColor.clear
        
        titleLabel.textColor = Config.Colors.MainContentColorBlack
        
        self.titleLabel.text = "\(index + 1). " + listItem.title!
        self.descriptionLabel.text = listItem.text
        self.descriptionLabel.backgroundColor = UIColor.clear
        self.descriptionLabel.textColor = Config.Colors.MainContentColorBlack

        venueImgView.isHidden = true
        
        listItem.photos?.query().findObjectsInBackground({ (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else if objects != nil  {
                if let objects = objects as? [Photo]{
                    self.setupSlideShow(objects)
                }
            }
        })
        
        
        if let container = container {


            delay(1, closure: { () -> () in
                
                let titleLabelHeight = self.titleLabel.frame.height
                let slideshowHeight = self.slideshowView != nil ? self.slideshowView.frame.height : 0
                let descriptionLabelOptimumHeight = heightForView(listItem.text!, font: self.descriptionLabel.font, width: self.descriptionLabel.frame.width)

                
                self.frame.size.height = titleLabelHeight + 8 + 8 + 8 + 8 + slideshowHeight + descriptionLabelOptimumHeight

                container.onHeightUpdated(self.frame.height, forItem: self)
            })
        }
        
        self.listItem.venue?.fetchIfNeededInBackground({ (obj, error) in
            
        })
    }
    func onViewSelected(_ view: UIView!, at index: Int) {
        if let  delegate = self.selectionDelegate {
            if let photos = self.photos {
            delegate.onListItemPhotoTappedWithPhotos(photos, selectedIndex: index)
            }
        }
    }
    
    
    fileprivate func setupSlideShow(_ photos: [Photo]) {
        


        if photos.count < 1 {
            slideshowView.frame.size.height = 0
            slideshowView.removeFromSuperview()
            coverImage.isHidden = true
            slideshowView.frame.size.height = 0
//            slideshowView.
//            slideshowView.hidden = true
            return
        }
        
        self.slideshowView.defaultSettings()
        slideshowView.delegate = self
        var views = [UIView]()
        var titles = [String]()
        var subtitles = [String]()
        
        let sortedPhotos = photos.sorted {
            guard let firstOrder = $0.sort,
                  let secondOrder = $1.sort else {
                return false
            }
            return firstOrder.compare(secondOrder) == .orderedAscending
        }
        self.photos = sortedPhotos
        
        for photo in sortedPhotos {
            photo.caption = nil
            if let file = photo.file {
                let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: self.slideshowView.frame.width - 16, height: self.slideshowView.frame.height))
                imageView.isUserInteractionEnabled = true
                views.append(imageView)
                subtitles.append("")
                titles.append("")
                
                if views.count == photos.count {
                    self.finishSetup(views, titles: titles, subtitles: subtitles)
                }

                imageView.image = UIImage(named: "itemDefaultImage")
                file.getImageWithBlock( withBlock: { (image, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        imageView.image = image
                                            }
                })
//                Shared.imageCache.fetch(key: photo.objectId, formatName: ImageFormatKey.InListRecommentationCoverFormat.rawValue, failure: { (error) -> () in
                    
//                    
//                    file.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                        if error != nil {
//                            log.error(error?.localizedDescription)
//                        } else {
//                            let image = UIImage(data: data)
//                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.slideshowView.frame.width, height: self.slideshowView.frame.height))
//                            imageView.image = image
//                            views.append(imageView)
//                            subtitles.append("")
//                            titles.append("")
//                            
//                            if views.count == photos.count {
//                                self.finishSetup(views, titles: titles, subtitles: subtitles)
//                            }
                    
//                            Shared.imageCache.set(value: image!, key: photo.objectId, formatName: ImageFormatKey.InListRecommentationCoverFormat.rawValue, success: { image in
//
//                            })
//                        }
//                    })
//                    
//                    }, success: { image in
//                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.slideshowView.frame.width, height: self.slideshowView.frame.height))
//                        imageView.image = image
//                        views.append(imageView)
//                        subtitles.append("")
//                        titles.append("")
//                })
            }
        }
        
        addTapListener()
    }
    
    fileprivate func finishSetup(_ views: [UIView], titles: [String], subtitles: [String]) {
        self.slideshowView.titleLabelFont = UIFont.systemFont(ofSize: 22)
        self.slideshowView.titleLabelTextColor = UIColor.white
        
        self.slideshowView.descriptionLabelFont = UIFont.systemFont(ofSize: 20)
        self.slideshowView.descriptionLabelTextColor = UIColor.white
        
        self.slideshowView.viewsToSublime = views
        self.slideshowView.backgroundColor = UIColor.clear
        self.slideshowView.titleStrings = titles
        self.slideshowView.descriptionStrings = subtitles
        
        self.slideshowView.titleLabelY = self.slideshowView.frame.height * 6 / 12
        self.slideshowView.descriptionLabelY = self.slideshowView.frame.height * 6 / 12 + 30
        
//        
//        let shadeView = UIView(frame: CGRect(x: 0, y: 0, width: self.slideshowView.frame.width, height: self.slideshowView.frame.height))
//        shadeView.backgroundColor = Config.Colors.ImagesDarkOverlayColor
//        shadeView.alpha = Config.Colors.ImagesDarkOverlayAlpha
//        self.slideshowView.inbetweenView = shadeView
        



        
    }
    
    func addTapListener() {
        let titleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ListItemView.onListItemSelected))
        titleLabel.addGestureRecognizer(titleTap)
        if let venue = listItem.venue , venue.customName != nil {
            venueImgView.isHidden = false
            venueImgView.isUserInteractionEnabled = true
            let venueImgViewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ListItemView.onListItemSelected))
            venueImgView.addGestureRecognizer(venueImgViewTap)
        }else{
            venueImgView.isHidden = true
        }
        
    }
}


