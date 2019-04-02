//
//  PhotoLibrary.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 12/31/15.
//  Copyright © 2015 Atlas. All rights reserved.
//

import Photos


/**
PhotoLibrary

helper class for Photos API
*/
class PhotoLibrary {
    
    //MARK: - Properties
    
    static let SharedLibrary = PHPhotoLibrary.shared()

    
    //MARK: - Initializers
    
    //MARK: - Public Methods
    
    static func saveToAlbum(_ image:UIImage, album: String) {
        var assetCollectionPlaceholder: PHObjectPlaceholder!
        
        if let assetCollection = albumWithTitle(album) {
            createAssetForImage(image, inCollection: assetCollection)
        } else {
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: album)
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult)
                        let assetCollection:PHAssetCollection = collectionFetchResult.firstObject!
                        createAssetForImage(image, inCollection: assetCollection)
                    }
            })
        }
    }
    
    static func enumerateAssetsWithBlock(_ album: String? = nil, block: @escaping (AnyObject, Int, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        var fetchResult: PHFetchResult<PHAsset>?
        
        if let album = album {
            let assetCollection = albumWithTitle(album)
            if let assetCollection = assetCollection , assetCollection.estimatedAssetCount > 0 {
                // Album exists
 //               fetchOptions.predicate = NSPredicate(format: "title = %@", album)
                fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            }
        }
        
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        if let fetchResult = fetchResult , fetchResult.count > 0 {
            fetchResult.enumerateObjects(block)
        }
    }
    
    static func albumWithTitle(_ title: String) -> PHAssetCollection? {
        // Check if album exists. If not, create it.
        let predicate = NSPredicate(format: "title = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype:.any, options:options)
        if collection.count > 0 {
            return collection.firstObject!
        }
        return nil
        
    }
    
    //MARK: - Private Methods

    fileprivate static func createAssetForImage(_ image: UIImage, inCollection collection: PHAssetCollection) {
        var placeholderAsset: PHObjectPlaceholder!

        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholderAsset = assetCreationRequest.placeholderForCreatedAsset
        }, completionHandler: { success, error in
            if let error = error {
                log.error(error.localizedDescription)
            } else {
                PHPhotoLibrary.shared().performChanges({
                    guard let asset = getAssetFromlocalIdentifier(placeholderAsset.localIdentifier) else { return }
                    guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else {return }
                    let array = NSArray(array: [asset])
                    albumChangeRequest.addAssets(array)
                    
                }, completionHandler: { success, error in
                    if let error = error {
                        log.error(error.localizedDescription)
                    } else {

                    }
                })
            }
        })
    }
    
    fileprivate static func getAssetFromlocalIdentifier(_ localIdentifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options:nil)
        if result.count > 0 {
            return result.firstObject!
        }
        return nil;
    }
}
