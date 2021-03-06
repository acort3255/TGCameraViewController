//
//  TGMediaCrop.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/23/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

open  class TGMediaCrop
{
    open static func cropImage(_ image: UIImage, withCropSize cropSize: CGSize) -> UIImage
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
        var thumbnailPoint: CGPoint = CGPoint(x: 0, y: 0)
        
        if imageSize.equalTo(cropSize) == false {
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
        var thumbnailRect: CGRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        image.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
    
    open static func cropVideo(_ videoURL: URL, completion: @escaping (_ croppedVideoURL: URL) -> Void)
    {
        // cleanup initial file
        
        let cleanup: ()->() = {() -> Void in
            do {
                try FileManager.default.removeItem(at: videoURL)
            }
            catch _ {
            }
        }
        
        // output file
        let outputFileName: String = ProcessInfo.processInfo.globallyUniqueString
        let outputFileURL = NSTemporaryDirectory() + outputFileName + ".mp4"
        
        // input file
        let asset: AVAsset = AVAsset(url: videoURL)
        let composition: AVMutableComposition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        // input clip
        let clipVideoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        // make it square
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        // rotate to portrait
        let transformer: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1: CGAffineTransform = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let t2: CGAffineTransform = t1.rotated(by: CGFloat(M_PI_2))
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        // export
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputURL = URL(fileURLWithPath: outputFileURL)
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.exportAsynchronously(completionHandler: {() -> Void in
            //print("Exporting done!")
            cleanup()
            completion(URL(fileURLWithPath: outputFileURL))
        })
        
        //return videoURL
    }
}
