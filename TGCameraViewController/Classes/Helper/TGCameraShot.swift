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

open class TGCameraShot: NSObject {
    
    open static var delegate: TGCamera!
    open static func takePhotoCaptureView(_ captureView: UIView, stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping (_ photo: UIImage) -> Void) {
        
         DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            var videoConnection: AVCaptureConnection? = nil
            for connection in stillImageOutput.connections {
                for port in (connection as AnyObject).inputPorts! {
                    if (port as AnyObject).mediaType == AVMediaTypeVideo {
                        videoConnection = connection as? AVCaptureConnection
                    }
                }
                if videoConnection == nil {
                    return
                }
                
                videoConnection!.videoOrientation = videoOrientation
            }
        
        
                stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                    (imageDataSampleBuffer: CMSampleBuffer?, error: Error?) in
                    
                    if imageDataSampleBuffer != nil
                    {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let image = UIImage(data: imageData!)
                        let croppedImage = TGMediaCrop.cropImage(image!, withCropSize: cropSize)
                        completion(croppedImage)
                    }
            })
        })
    }
    
    open static func recordVideoCaptureView(_ captureView: UIView, movieFileOutput: AVCaptureMovieFileOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, delegate: TGCamera)
    {
        if movieFileOutput.isRecording == false
        {
            var videoConnection: AVCaptureConnection? = nil
            for connection in movieFileOutput.connections {
                for port in (connection as AnyObject).inputPorts! {
                    if (port as AnyObject).mediaType == AVMediaTypeVideo {
                        videoConnection = connection as? AVCaptureConnection
                    }
                }
            }
            
            if videoConnection == nil {
                return
            }
            
            videoConnection!.videoOrientation = videoOrientation
            
            
            // Start recording to a temporary file.
            let outputFileName: String = ProcessInfo.processInfo.globallyUniqueString
            let outputFileURL = NSTemporaryDirectory() + outputFileName + ".mp4"
            //NSLog(@"Path to video in camera call: %@", outputFileURL);
            movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFileURL), recordingDelegate: delegate)
        }
    }
    
}
