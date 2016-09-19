//
//  TGAlbum.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/18/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import MobileCoreServices 

open class TGAlbum: NSObject {
    
    
    open static func imageWithMediaInfo(_ info: [AnyHashable: Any]) -> UIImage? {
        let mediaType: String = info[UIImagePickerControllerMediaType] as! String
        if (mediaType == String(kUTTypeImage)) {
            return info[UIImagePickerControllerEditedImage] as? UIImage
        }
        return nil
    }
    
    open static func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)

    }
    
    open static func imagePickerControllerWithDelegate(_ delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> UIImagePickerController {
        
        var pickerController: UIImagePickerController = UIImagePickerController()
        pickerController = UIImagePickerController()
        pickerController.delegate = delegate
        pickerController.mediaTypes = [kUTTypeImage as String]
        pickerController.allowsEditing = true
        return pickerController
    }
}
