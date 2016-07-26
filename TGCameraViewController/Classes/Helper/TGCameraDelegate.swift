//
//  TGCameraDelegate.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

@objc public protocol TGCameraDelegate: NSObjectProtocol
{
    func cameraDidCancel()
    func cameraDidSelectAlbumPhoto(image: UIImage?)
    func cameraDidTakePhoto(image: UIImage?)
    
    func cameraDidRecordVideo(videoURL: NSURL?)
    
    optional func cameraDidSavePhotoWithError(error: NSError?)
    optional func cameraDidSavePhotoAtPath(assetURL: NSURL?)
    optional func cameraWillTakePhoto()
    
}