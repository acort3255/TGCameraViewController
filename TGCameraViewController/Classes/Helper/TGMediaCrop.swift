//
//  TGMediaCrop.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/23/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

public  class TGMediaCrop
{
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
    
    public static func cropVideo(videoURL: NSURL, completion: (croppedVideoURL: NSURL) -> Void)
    {
        // cleanup initial file
        
        let cleanup: dispatch_block_t = {() -> Void in
            do {
                try NSFileManager.defaultManager().removeItemAtURL(videoURL)
            }
            catch _ {
            }
        }
        
        // output file
        let outputFileName: String = NSProcessInfo.processInfo().globallyUniqueString
        let outputFileURL = NSTemporaryDirectory() + outputFileName + ".mp4"
        
        // input file
        let asset: AVAsset = AVAsset(URL: videoURL)
        let composition: AVMutableComposition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        // input clip
        let clipVideoTrack: AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        // make it square
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        // rotate to portrait
        let transformer: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1: CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let t2: CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        // export
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputURL = NSURL.fileURLWithPath(outputFileURL)
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.exportAsynchronouslyWithCompletionHandler({() -> Void in
            print("Exporting done!")
            cleanup()
            completion(croppedVideoURL: NSURL.fileURLWithPath(outputFileURL))
        })
        
        //return videoURL
    }
}