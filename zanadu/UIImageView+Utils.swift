//
//  UIImageView+Utils.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 9/9/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension UIImageView {
    
    fileprivate func setupForAvatarWithPhoto(_ photo: Photo, circleBorder: Bool = true) {
        let screenScale = UIScreen.main.scale
        let screenWidth = UIScreen.main.bounds.size.width
        
        if let avatarFile = photo.file {
            
            let thumbnailUrl = avatarFile.getThumbnailURLWithScale(toFit: true, width: Int32(screenWidth * screenScale) / 4, height: Int32(screenWidth * screenScale / 4))
            
            ImageCacheManager.avatarImageWithURL(thumbnailUrl!, completed: { (image, error, type, finished, url) in
                if error != nil {
                    log.error("avatar file download error : \(error?.localizedDescription)")
                    return
                }
                self.image = image
                if circleBorder{
                    self.circularBorder(UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4).cgColor, withWidth: 2)
                }
                self.isHidden = false
            })

        }
    }

    fileprivate func initAvatar(_ avatar: Photo, circleBorder: Bool = true) {
        if avatar.isDataAvailable() {
            setupForAvatarWithPhoto(avatar, circleBorder: circleBorder)
        } else {
            avatar.fetchInBackground({ (object, error) -> Void in
                if error != nil {
                    log.error("recommendation fetching : \(error?.localizedDescription)")
                } else {

                    self.setupForAvatarWithPhoto(avatar,circleBorder: circleBorder)
                }
            })
        }
    }
    
    
    func setupForAvatarWithUser(_ user: User, circleBorder: Bool = true) {
        if let avatar = user.avatar {
            initAvatar(avatar,circleBorder: circleBorder)
        } else {// if user.isDataAvailable() {

                self.image = UIImage(named: Config.AppConf.defaultUserAvatar)
            if circleBorder{
                               self.circularBorder(UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.4).cgColor, withWidth:2)
            }

                self.isHidden = false
        }
    }
    
    
    func setupForNotificationImage(_ file:AVFile) {
        file.getImageWithBlock { (image, error) in
            if error != nil {
                log.error(error?.localizedDescription)
            } else {
                self.image = image
            }
        }
        
    }
}
