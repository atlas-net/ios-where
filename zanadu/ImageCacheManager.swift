//
//  ImageCacheManager.swift
//  Atlas
//
//  Created by liudeng on 16/8/2.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation
import SDWebImage

enum ImageFormatKey: String {
    case InListRecommentationCoverFormat = "InListRecommentationCoverFormat"
    case TribeFlagFormat = "TribeFlagFormat"
    case AvatarFormat = "AvatarFlagFormat"
}



class ImageCacheManager {
    
    fileprivate static var _singleton = ImageCacheManager()
    fileprivate class func shareInstance() -> ImageCacheManager{
        return _singleton
    }
    
    fileprivate lazy var recommendationImageCache : SDImageCache = {
        var imageCache = SDImageCache(namespace: ImageFormatKey.InListRecommentationCoverFormat.rawValue)
        imageCache?.maxCacheSize = UInt(200 * 1024 * 1024)
        return imageCache!
    }()
    
    fileprivate lazy var recommendationImageCacheManager : SDWebImageManager = {
        return SDWebImageManager(cache:self.recommendationImageCache,downloader: SDWebImageDownloader.shared())
    }()
    
    fileprivate lazy var tribeImageCache: SDImageCache = {
        var imageCache = SDImageCache(namespace: ImageFormatKey.TribeFlagFormat.rawValue)
        imageCache?.maxCacheSize = UInt(50 * 1024 * 1024)
        return imageCache!
    }()
    
    fileprivate lazy var tribeImageCacheManager : SDWebImageManager = {
        return SDWebImageManager(cache:self.tribeImageCache,downloader: SDWebImageDownloader.shared())
    }()
    
    fileprivate lazy var avatarImageCache: SDImageCache = {
        var imageCache = SDImageCache(namespace: ImageFormatKey.AvatarFormat.rawValue)
        imageCache?.maxCacheSize = UInt(20 * 1024 * 1024)
        return imageCache!
    }()
    
    fileprivate lazy var avatarImageCacheManager : SDWebImageManager = {
        return SDWebImageManager(cache:self.avatarImageCache,downloader: SDWebImageDownloader.shared())
    }()
    
    class func recommendationImageWithURL(_ urlStr: String,option:SDWebImageOptions? = nil,completed completedBlock: SDWebImageCompletionWithFinishedBlock!){
        if let _ = option {
            ImageCacheManager.shareInstance().recommendationImageCacheManager.downloadImage(with: URL(string:urlStr), options: [option!], progress: { (receivedSize, expectedSize) in
                
                }, completed: completedBlock)
        }
        else{
            ImageCacheManager.shareInstance().recommendationImageCacheManager.downloadImage(with: URL(string:urlStr), options: [SDWebImageOptions.avoidAutoSetImage], progress: { (receivedSize, expectedSize) in
                
                }, completed: completedBlock)
        }

    }
    
    class func tribeImageWithURL(_ urlStr: String,completed completedBlock: SDWebImageCompletionWithFinishedBlock!){
        ImageCacheManager.shareInstance().tribeImageCacheManager.downloadImage(with: URL(string:urlStr), options: [SDWebImageOptions.avoidAutoSetImage], progress: { (receivedSize, expectedSize) in
            
            }, completed: completedBlock)
    }
    
    class func avatarImageWithURL(_ urlStr: String,completed completedBlock: SDWebImageCompletionWithFinishedBlock!){
        ImageCacheManager.shareInstance().avatarImageCacheManager.downloadImage(with: URL(string:urlStr), options: [SDWebImageOptions.avoidAutoSetImage], progress: { (receivedSize, expectedSize) in
            
            }, completed: completedBlock)
    }
    
    class func totalSize() -> UInt {
        return ImageCacheManager.shareInstance().avatarImageCache.getSize() +
                ImageCacheManager.shareInstance().recommendationImageCache.getSize() +
                ImageCacheManager.shareInstance().tribeImageCache.getSize()
    }
    
    class func clearCache() {
        ImageCacheManager.shareInstance().avatarImageCache.clearDisk()
        ImageCacheManager.shareInstance().avatarImageCache.clearMemory()
        ImageCacheManager.shareInstance().recommendationImageCache.clearDisk()
        ImageCacheManager.shareInstance().recommendationImageCache.clearMemory()
        ImageCacheManager.shareInstance().tribeImageCache.clearDisk()
        ImageCacheManager.shareInstance().tribeImageCache.clearMemory()
    }
    
}
