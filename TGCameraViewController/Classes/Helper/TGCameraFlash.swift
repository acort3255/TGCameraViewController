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

public class TGCameraFlash: NSObject {
    public static func changeModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice!// = (session.inputs.last?.device)!
        // find the input that supports flash aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasFlash == true
            {
                device = input.device
                break
            }
        }
        
        if device != nil {
        var mode: AVCaptureFlashMode = device.flashMode
        
        do {
            try device.lockForConfiguration()
            
                switch device.flashMode {
                case .Auto:
                    mode = .On
                case .On:
                    mode = .Off
                case .Off:
                    mode = .Auto
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
    
    public static func matchFlashModeToTorchMode(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = input.device
            }
        }
        
        if device != nil {
            let mode: AVCaptureFlashMode = determineFlashMode(device)
            do {
                
                try device.lockForConfiguration()
                if device.isFlashModeSupported(mode) {
                    device.flashMode = mode
                }
                print("Supported flash \(device.isFlashModeSupported(mode))")
                
                device.unlockForConfiguration()
                self.flashModeWithCaptureSession(session, andButton: button)
            }
                
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    public static func flashModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        // find the input that supports flash aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasFlash == true
            {
                device = input.device
                break
            }
        }
        
        if device != nil{
            let mode: AVCaptureFlashMode = device.flashMode
            let image: UIImage = UIImageFromAVCapture(mode)
            let tintColor: UIColor = TintColorFromAVCapture(mode)
            button.enabled = device.isFlashModeSupported(mode)
            if (button is TGTintedButton) {
                (button as! TGTintedButton).customTintColorOverride = tintColor
            }
            button.setImage(image, forState: .Normal)
        }
    }
    
    // MARK: Private
    
    private static func UIImageFromAVCapture(flashMode: AVCaptureFlashMode) -> UIImage
    {
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let array = ["CameraFlashOff", "CameraFlashOn", "CameraFlashAuto"]
        let imageName = array[flashMode.rawValue]
        return UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }
    
    
    private static func TintColorFromAVCapture(flashMode: AVCaptureFlashMode) -> UIColor
    {
        let array = [UIColor.grayColor(), TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[flashMode.rawValue]
        return color
    }
    
    private static func determineFlashMode(device: AVCaptureDevice) -> AVCaptureFlashMode
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
