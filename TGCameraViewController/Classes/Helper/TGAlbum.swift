//
//  TGAlbum.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/18/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import MobileCoreServices 

public class TGAlbum: NSObject {
    
    
    public static func imageWithMediaInfo(info: [NSObject : AnyObject]) -> UIImage? {
        let mediaType: String = info[UIImagePickerControllerMediaType] as! String
        if (mediaType == String(kUTTypeImage)) {
            return info[UIImagePickerControllerEditedImage] as? UIImage
        }
        return nil
    }
    
    public static func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)

    }
    
    public static func imagePickerControllerWithDelegate(delegate: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) -> UIImagePickerController {
        
        var pickerController: UIImagePickerController = UIImagePickerController()
        pickerController = UIImagePickerController()
        pickerController.delegate = delegate
        pickerController.mediaTypes = [kUTTypeImage as String]
        pickerController.allowsEditing = true
        return pickerController
    }
}