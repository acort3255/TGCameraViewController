//
//  TGCameraTorch.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/23/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import AVFoundation
import UIKit

public class TGCameraTorch: NSObject {
    public static func changeModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = input.device
            }
        }
        
        if device != nil {
            var mode: AVCaptureTorchMode = device.torchMode
            do {
            
                try device.lockForConfiguration()
                    switch device.torchMode {
                    case .Auto:
                        mode = .On
                    case .On:
                        mode = .Off
                    case .Off:
                        mode = .Auto
                    }
                if device.isTorchModeSupported(mode) {
                    device.torchMode = mode
                }
                print("Supported torch \(device.isTorchModeSupported(mode))")
        
                device.unlockForConfiguration()
                self.torchModeWithCaptureSession(session, andButton: button)
        }
        
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    public static func matchTorchModeToFlashMode(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice! //= (session.inputs.last?.device)!
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                device = input.device
            }
        }
        
        if device != nil {
            let mode: AVCaptureTorchMode = determineTorchMode(device)
            do {
                
                try device.lockForConfiguration()
                if device.isTorchModeSupported(mode) {
                    device.torchMode = mode
                }
                print("Supported torch \(device.isTorchModeSupported(mode))")
                
                device.unlockForConfiguration()
                self.torchModeWithCaptureSession(session, andButton: button)
            }
                
            catch
            {
                print("Could not lock configuration for AVCapture (TGCamera Torch)")
            }
        }
    }
    
    public static func torchModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice!// = (session.inputs.first!.device)!
        
        // find input that supports torch aka video input
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasTorch == true
            {
                print("Device has torch")
                device = input.device
            }
        }
        
        if device != nil {
            let mode: AVCaptureTorchMode = device.torchMode
            let image: UIImage = UIImageFromAVCapture(mode)
            let tintColor: UIColor = TintColorFromAVCapture(mode)
            button.enabled = device.isTorchModeSupported(mode)
            if (button is TGTintedButton) {
                (button as! TGTintedButton).customTintColorOverride = tintColor
            }
            button.setImage(image, forState: .Normal)
        }
    }
    
    // MARK: Private
    
    private static func UIImageFromAVCapture(torchMode: AVCaptureTorchMode) -> UIImage
    {
        let array = ["CameraFlashOff", "CameraFlashOn", "CameraFlashAuto"]
        let imageName = array[torchMode.rawValue]
        return UIImage(named: imageName)!
    }
    
    
    private static func TintColorFromAVCapture(torchMode: AVCaptureTorchMode) -> UIColor
    {
        let array = [UIColor.grayColor(), TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[torchMode.rawValue]
        return color
    }
    
    private static func determineTorchMode(device: AVCaptureDevice) -> AVCaptureTorchMode
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