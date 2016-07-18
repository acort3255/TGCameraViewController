//
//  UIImage+CameraFilters.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/18/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import CoreImage

let kCIColorControls: String = "CIColorControls"
let kCIToneCurve: String = "CIToneCurve"
let kCIVignette: String = "CIVignette"
let kInputContrast: String = "inputContrast"
let kInputImage: String = "inputImage"
let kInputIntensity: String = "inputIntensity"
let kInputPoint0: String = "inputPoint0"
let kInputPoint1: String = "inputPoint1"
let kInputPoint2: String = "inputPoint2"
let kInputPoint3: String = "inputPoint3"
let kInputPoint4: String = "inputPoint4"
let kInputRadius: String = "inputRadius"
let kInputSaturation: String = "inputSaturation"

extension UIImage {
    

    public func curveFilter() -> UIImage {
        let inputImage: CoreImage.CIImage = CoreImage.CIImage(image: self)!
        let filter: CIFilter = CIFilter(name: kCIToneCurve)!
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: 0), forKey: kInputPoint0)
        filter.setValue(CIVector(x: 0.25, y: 0.15), forKey: kInputPoint1)
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: kInputPoint2)
        filter.setValue(CIVector(x: 0.75, y: 0.85), forKey: kInputPoint3)
        filter.setValue(CIVector(x: 1, y: 1), forKey: kInputPoint4)
        let context: CIContext = CIContext()
        return imageFromContext(context, withFilter: filter)
    }
    
    public func saturateImage(saturation: CGFloat, withContrast contrast: CGFloat) -> UIImage {
        let inputImage: CoreImage.CIImage = CoreImage.CIImage(image: self)!
        let saturationNumber: Int = Int(saturation)
        let contrastNumber: Int = Int(contrast)
        let filter: CIFilter = CIFilter(name: kCIColorControls)!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(saturationNumber, forKey: kInputSaturation)
        filter.setValue(contrastNumber, forKey: kInputContrast)
        let context: CIContext = CIContext()
        return imageFromContext(context, withFilter: filter)

        
    }
    
    public func vignetteWithRadius(radius: CGFloat, intensity: CGFloat) -> UIImage {
        let inputImage: CoreImage.CIImage = CoreImage.CIImage(image: self)!
        let intentisyNumber: Int = Int(intensity)
        let radiusNumber: Int = Int(radius)
        let filter: CIFilter = CIFilter(name: kCIVignette)!
        //filter[kInputImage] = inputImage
        filter.setValue(inputImage, forKey: kInputImage)
        filter.setValue(intentisyNumber, forKey: kInputIntensity)
        filter.setValue(radiusNumber, forKey: kInputRadius)
        let context: CIContext = CIContext()
        return imageFromContext(context, withFilter: filter)
 
    }
    
    // MARK: Private
    internal func imageFromContext(context: CIContext, withFilter filter: CIFilter) -> UIImage {
        let outputImage: CoreImage.CIImage = filter.outputImage!
        let extent: CGRect = filter.outputImage!.extent
        let imageRef: CGImageRef = context.createCGImage(outputImage, fromRect: extent)
        let image: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
