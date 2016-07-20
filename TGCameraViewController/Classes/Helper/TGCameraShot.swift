//
//  TGCameraShot.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class TGCameraShot: NSObject {
    public static func takePhotoCaptureView(captureView: UIView, stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: (photo: UIImage) -> Void) {
        
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var videoConnection: AVCaptureConnection? = nil
            for connection in stillImageOutput.connections {
                for port in connection.inputPorts! {
                    if port.mediaType == AVMediaTypeVideo {
                        videoConnection = connection as? AVCaptureConnection
                    }
                }
                if videoConnection == nil {
                    return
                }
                
                videoConnection!.videoOrientation = videoOrientation
            }
        
        
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (imageDataSampleBuffer: CMSampleBufferRef!, _) in
                    
                    if imageDataSampleBuffer != nil
                    {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let image = UIImage(data: imageData)
                        let croppedImage = cropImage(image!, withCropSize: cropSize)
                        completion(photo: croppedImage)
                    }
            })
        })
    }
    
    // MARK: Private
    public static func cropImage(image: UIImage, withCropSize cropSize: CGSize) -> UIImage
    {
        var newImage: UIImage? = nil
        let imageSize: CGSize = image.size
        let width: CGFloat = imageSize.width
        let height: CGFloat = imageSize.height
        let targetWidth: CGFloat = cropSize.width
        let targetHeight: CGFloat = cropSize.height
        var scaleFactor: CGFloat = 0
        var scaledWidth: CGFloat = targetWidth
        var scaledHeight: CGFloat = targetHeight
        var thumbnailPoint: CGPoint = CGPointMake(0, 0)
        
        if CGSizeEqualToSize(imageSize, cropSize) == false {
            let widthFactor: CGFloat = targetWidth / width
            let heightFactor: CGFloat = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            }
            else {
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }
            else {
                if widthFactor < heightFactor {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(cropSize, true, 0)
        var thumbnailRect: CGRect = CGRectZero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        image.drawInRect(thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!

    }
}