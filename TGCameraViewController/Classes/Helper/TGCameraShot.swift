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
    
    public static var delegate: TGCamera!
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
                        let croppedImage = TGMediaCrop.cropImage(image!, withCropSize: cropSize)
                        completion(photo: croppedImage)
                    }
            })
        })
    }
    
    public static func recordVideoCaptureView(captureView: UIView, movieFileOutput: AVCaptureMovieFileOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize)
    {
        if movieFileOutput.recording == false
        {
            // Start recording to a temporary file.
            let outputFileName: String = NSProcessInfo.processInfo().globallyUniqueString
            let outputFilePath: String = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(outputFileName + "mov").absoluteString
            let outputFileURL = NSURL.fileURLWithPath(outputFilePath)
            //NSLog(@"Path to video in camera call: %@", outputFileURL);
            movieFileOutput.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: delegate)
        }
    }
    
}