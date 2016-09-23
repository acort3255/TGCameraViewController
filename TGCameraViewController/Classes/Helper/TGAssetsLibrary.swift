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

public typealias TGAssetsResultCompletion = (_ assetURL: URL?) -> Void
public typealias TGAssetsFailureCompletion = (_ error: NSError?) -> Void
public typealias TGAssetsLoadImagesCompletion = (_ items: [AnyObject], _ error: NSError?) -> Void

@available(iOS 8.0, *)
open class TGAssetsLibrary: PHImageManager{
    
    let appName: String = Bundle.main.infoDictionary![String(kCFBundleNameKey)] as! String
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult<AnyObject>!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
   
    required override public init() {
        super.init()
        createAlbum()
    }
    
    
    fileprivate func createAlbum()
    {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", appName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject! as PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.appName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    self.albumFound = (success ? true: false)
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collectionFetchResult.firstObject! as PHAssetCollection
                    }
            })
        }
    }
    
    
    open func deleteFile(_ file: TGAssetImageFile) {
        let fileManager: FileManager = FileManager.default
        if fileManager.isDeletableFile(atPath: file.path) {
            do {
                try fileManager.removeItem(atPath: file.path)
            }
            catch _ {
            }
        }

    }
    
    open func loadImagesFromDocumentDirectory() -> [AnyObject] {
        
        let contents: [AnyObject] = try! FileManager.default.contentsOfDirectory(atPath: directory()) as [AnyObject]
       
        
        var items = [AnyObject]()
        for name: String in (contents as! [String])
        {
            let path: String = URL(fileURLWithPath: directory()).appendingPathComponent(name).absoluteString
            let data: Data = try! Data(contentsOf: URL(fileURLWithPath: path))
            
            let image: UIImage = UIImage(data: data)!
            let file: TGAssetImageFile = TGAssetImageFile(path: path, image: image)
            items.append(file)
        }
        return items

    }
    
    open func loadImagesFromAlbum(_ albumName: String, withCallback callback: TGAssetsLoadImagesCompletion) {
        var items = [AnyObject]()
        
        let assets : PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        
        let imageManager = PHCachingImageManager()
        //Enumerating objects to get a chached image - This is to save loading time
        assets.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset {
                let asset = object as! PHAsset
                
                let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: {(image: UIImage?,
                    info: [AnyHashable: Any]?) in
                    items.append(image!)
                    
                })
            }
        })
        callback(items, nil)
    }
    
    open func saveImage(_ image: UIImage, resultBlock: @escaping TGAssetsResultCompletion, failureBlock: @escaping TGAssetsFailureCompletion)
    {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
            }, completionHandler: { success, error in
                print("added image to album")
                
                if success
                {
                    resultBlock(URL(fileURLWithPath: ""))
                }
                    
                else
                {
                    failureBlock(error as NSError?)
                }
                
        })
    }
    
    open func saveVideo(_ videoURL: URL, resultBlock: @escaping TGAssetsResultCompletion, failureBlock: @escaping TGAssetsFailureCompletion)
    {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
            }, completionHandler: { success, error in
                print("added video to album")
                
                if success
                {
                    resultBlock(URL(fileURLWithPath: ""))
                }
                    
                else
                {
                    failureBlock(error as NSError?)
                }
                
        })
    }
    
    
    
    open func saveJPGImageAtDocumentDirectory(_ image: UIImage, resultBlock: TGAssetsResultCompletion, failureBlock: TGAssetsFailureCompletion) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:SSSSZ"
        let directory: String? = self.directory()
        if (directory == nil) {
            failureBlock(nil)
            return
        }
        let fileName: String = dateFormatter.string(from: Date()) + ".jpg"
        let filePath: String? = directory! + fileName
        if filePath == nil {
            failureBlock(nil)
            return
        }
        let data: Data = UIImageJPEGRepresentation(image, 1)!
        try? data.write(to: URL(fileURLWithPath: filePath!), options: [.atomic])
        let assetURL: URL = URL(string: filePath!)!
        resultBlock(assetURL)

    }
    
   
    
    func directory() -> String {
        var path: String = NSMutableString() as String
        path += NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path += "/Images/"
        if !FileManager.default.fileExists(atPath: path) {
            var _: NSError
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            }
            catch _ {
            }
            
        }
        return path
    }
}
