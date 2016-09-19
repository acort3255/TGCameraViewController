//
//  TGCameraTorch.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/23/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import AVFoundation
import UIKit

open class TGCameraTorch: NSObject {
    open static func changeModeWithCaptureSession(_ session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = (input as AnyObject).device
            }
        }
        
        if device != nil {
            var mode: AVCaptureTorchMode = device.torchMode
            do {
            
                try device.lockForConfiguration()
                    switch device.torchMode {
                    case .auto:
                        mode = .on
                    case .on:
                        mode = .off
                    case .off:
                        mode = .auto
                    }
                if device.isTorchModeSupported(mode) {
                    device.torchMode = mode
                }
                //print("Supported torch \(device.isTorchModeSupported(mode))")
        
                device.unlockForConfiguration()
                self.torchModeWithCaptureSession(session, andButton: button)
        }
        
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    open static func matchTorchModeToFlashMode(_ session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = (input as AnyObject).device
            }
        }
        
        if device != nil {
            let mode: AVCaptureTorchMode = determineTorchMode(device)
            do {
                
                try device.lockForConfiguration()
                if device.isTorchModeSupported(mode) {
                    device.torchMode = mode
                }
                //print("Supported torch \(device.isTorchModeSupported(mode))")
                
                device.unlockForConfiguration()
                self.torchModeWithCaptureSession(session, andButton: button)
            }
                
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    open static func torchModeWithCaptureSession(_ session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice!// = (session.inputs.first!.device)!
        
        // find input that supports torch aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                //print("Device has torch")
                device = (input as AnyObject).device
            }
        }
        
        if device != nil {
            let mode: AVCaptureTorchMode = device.torchMode
            let image: UIImage = UIImageFromAVCapture(mode)
            let tintColor: UIColor = TintColorFromAVCapture(mode)
            button.isEnabled = device.isTorchModeSupported(mode)
            if (button is TGTintedButton) {
                (button as! TGTintedButton).customTintColorOverride = tintColor
            }
            button.setImage(image, for: UIControlState())
        }
    }
    
    // MARK: Private
    
    fileprivate static func UIImageFromAVCapture(_ torchMode: AVCaptureTorchMode) -> UIImage
    {
        let bundle = Bundle(for:  TGCameraViewController.self)
        let array = ["CameraFlashOff", "CameraFlashOn", "CameraFlashAuto"]
        let imageName = array[torchMode.rawValue]
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)!
    }
    
    
    fileprivate static func TintColorFromAVCapture(_ torchMode: AVCaptureTorchMode) -> UIColor
    {
        let array = [UIColor.gray, TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[torchMode.rawValue]
        return color
    }
    
    fileprivate static func determineTorchMode(_ device: AVCaptureDevice) -> AVCaptureTorchMode
    {
        var result: AVCaptureTorchMode!
        if device.hasFlash == true && device.flashMode != AVCaptureFlashMode(rawValue: device.torchMode.rawValue)!
        {
            result = AVCaptureTorchMode(rawValue: device.flashMode.rawValue)!
        }
        
        else
        {
            result = device.torchMode
        }
        
        return result
    }
}
