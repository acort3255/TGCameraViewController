//
//  TGAssetsLibrary.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/18/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import AssetsLibrary
import Photos
import UIKit

public typealias TGAssetsResultCompletion = (assetURL: NSURL?) -> Void
public typealias TGAssetsFailureCompletion = (error: NSError?) -> Void
public typealias TGAssetsLoadImagesCompletion = (items: [AnyObject], error: NSError?) -> Void

@available(iOS 8.0, *)
public class TGAssetsLibrary: PHImageManager{
    
    let appName: String = NSBundle.mainBundle().infoDictionary![String(kCFBundleNameKey)] as! String
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
   
    required override public init() {
        super.init()
        createAlbum()
    }
    
    
    private func createAlbum()
    {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", appName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.appName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    self.albumFound = (success ? true: false)
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult)
                        self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
                    }
            })
        }
    }
    
    
    public func deleteFile(file: TGAssetImageFile) {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        if fileManager.isDeletableFileAtPath(file.path) {
            do {
                try fileManager.removeItemAtPath(file.path)
            }
            catch _ {
            }
        }

    }
    
    public func loadImagesFromDocumentDirectory() -> [AnyObject] {
        
        let contents: [AnyObject] = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory())
       
        
        var items = [AnyObject]()
        for name: String in (contents as! [String])
        {
            let path: String = NSURL(fileURLWithPath: directory()).URLByAppendingPathComponent(name).absoluteString
            let data: NSData = NSData(contentsOfFile: path)!
            
            let image: UIImage = UIImage(data: data)!
            let file: TGAssetImageFile = TGAssetImageFile(path: path, image: image)
            items.append(file)
        }
        return items

    }
    
    public func loadImagesFromAlbum(albumName: String, withCallback callback: TGAssetsLoadImagesCompletion) {
        var items = [AnyObject]()
        
        let assets : PHFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        print(assets)
        
        let imageManager = PHCachingImageManager()
        //Enumerating objects to get a chached image - This is to save loading time
        assets.enumerateObjectsUsingBlock{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset {
                let asset = object as! PHAsset
                print(asset)
                
                let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .FastFormat
                
                imageManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: .AspectFill, options: options, resultHandler: {(image: UIImage?,
                    info: [NSObject : AnyObject]?) in
                    print(info)
                    print(image)
                    items.append(image!)
                    
                })
            }
        }
        callback(items: items, error: nil)
    }
    
    public func saveImage(image: UIImage, resultBlock: TGAssetsResultCompletion, failureBlock: TGAssetsFailureCompletion)
    {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder!])
            }, completionHandler: { success, error in
                print("added image to album")
                print(error)
                
                if success
                {
                    resultBlock(assetURL: NSURL(fileURLWithPath: ""))
                }
                    
                else
                {
                    failureBlock(error: error)
                }
                
        })
    }
    
    
    
    public func saveJPGImageAtDocumentDirectory(image: UIImage, resultBlock: TGAssetsResultCompletion, failureBlock: TGAssetsFailureCompletion) {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:SSSSZ"
        let directory: String? = self.directory()
        if (directory == nil) {
            failureBlock(error: nil)
            return
        }
        let fileName: String = dateFormatter.stringFromDate(NSDate()) + "jpg"
        let filePath: String? = directory!.stringByAppendingString(fileName)
        if filePath == nil {
            failureBlock(error: nil)
            return
        }
        let data: NSData = UIImageJPEGRepresentation(image, 1)!
        data.writeToFile(filePath!, atomically: true)
        let assetURL: NSURL = NSURL(string: filePath!)!
        resultBlock(assetURL: assetURL)

    }
    
   
    
    func directory() -> String {
        var path: String = NSMutableString() as String
        path += NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        path += "/Images/"
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            var _: NSError
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
            }
            catch _ {
            }
            
        }
        return path
    }
}
