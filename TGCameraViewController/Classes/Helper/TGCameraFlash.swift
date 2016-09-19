//
//  TGCameraFlash.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

open class TGCameraFlash: NSObject {
    open static func changeModeWithCaptureSession(_ session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice!// = (session.inputs.last?.device)!
        // find the input that supports flash aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasFlash == true
            {
                device = (input as AnyObject).device
                break
            }
        }
        
        if device != nil {
        var mode: AVCaptureFlashMode = device.flashMode
        
        do {
            try device.lockForConfiguration()
            
                switch device.flashMode {
                case .auto:
                    mode = .on
                case .on:
                    mode = .off
                case .off:
                    mode = .auto
                }
            
            if device.isFlashModeSupported(mode) {
                device.flashMode = mode
            }
            
            device.unlockForConfiguration()
            self.flashModeWithCaptureSession(session, andButton: button)
        }
        
        catch
        {
            print("Could not lock configuration for avcapture device")
        }
        }
    }
    
    open static func matchFlashModeToTorchMode(_ session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = (input as AnyObject).device
            }
        }
        
        if device != nil {
            let mode: AVCaptureFlashMode = determineFlashMode(device)
            do {
                
                try device.lockForConfiguration()
                if device.isFlashModeSupported(mode) {
                    device.flashMode = mode
                }
                //print("Supported flash \(device.isFlashModeSupported(mode))")
                
                device.unlockForConfiguration()
                self.flashModeWithCaptureSession(session, andButton: button)
            }
                
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    open static func flashModeWithCaptureSession(_ session: AVCaptureSession, andButton button: UIButton) {
        
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        // find the input that supports flash aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasFlash == true
            {
                device = (input as AnyObject).device
                break
            }
        }
        
        if device != nil{
            let mode: AVCaptureFlashMode = device.flashMode
            let image: UIImage = UIImageFromAVCapture(mode)
            let tintColor: UIColor = TintColorFromAVCapture(mode)
            button.isEnabled = device.isFlashModeSupported(mode)
            if (button is TGTintedButton) {
                (button as! TGTintedButton).customTintColorOverride = tintColor
            }
            button.setImage(image, for: .normal)
        }
    }
    
    // MARK: Private
    
    fileprivate static func UIImageFromAVCapture(_ flashMode: AVCaptureFlashMode) -> UIImage
    {
        let bundle = Bundle(for: TGCameraViewController.self)
        let array = ["CameraFlashOff", "CameraFlashOn", "CameraFlashAuto"]
        let imageName = array[flashMode.rawValue]
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)!
    }
    
    
    fileprivate static func TintColorFromAVCapture(_ flashMode: AVCaptureFlashMode) -> UIColor
    {
        
        let array = [UIColor.gray, TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[flashMode.rawValue]
        return color
    }
    
    fileprivate static func determineFlashMode(_ device: AVCaptureDevice) -> AVCaptureFlashMode
    {
        var result: AVCaptureFlashMode!
        if device.hasTorch == true && device.flashMode != AVCaptureFlashMode(rawValue: device.torchMode.rawValue)!
        {
            result = AVCaptureFlashMode(rawValue: device.torchMode.rawValue)!
        }
            
        else
        {
            result = device.flashMode
        }
        
        return result
    }

}
