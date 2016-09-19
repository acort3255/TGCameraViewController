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
    func cameraDidSelectAlbumPhoto(_ image: UIImage?)
    func cameraDidTakePhoto(_ image: UIImage?)
    
    func cameraDidRecordVideo(_ videoURL: URL?)
    
    @objc optional func cameraDidSavePhotoWithError(_ error: NSError?)
    @objc optional func cameraDidSavePhotoAtPath(_ assetURL: URL?)
    @objc optional func cameraWillCaptureMedia()
    
}
