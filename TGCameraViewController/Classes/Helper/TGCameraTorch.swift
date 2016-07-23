//
//  TGCameraTorch.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/23/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import AVFoundation
import UIKit

class TGCameraTorch: NSObject {
    public static func changeModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        var device: AVCaptureDevice = (session.inputs.last?.device)!
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
    
    public static func torchModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        let device: AVCaptureDevice = (session.inputs.first!.device)!
        let mode: AVCaptureTorchMode = device.torchMode
        let image: UIImage = UIImageFromAVCapture(mode)
        let tintColor: UIColor = TintColorFromAVCapture(mode)
        button.enabled = device.isTorchModeSupported(mode)
        if (button is TGTintedButton) {
            (button as! TGTintedButton).customTintColorOverride = tintColor
        }
        button.setImage(image, forState: .Normal)
    }
    
    // MARK: Private
    
    private static func UIImageFromAVCapture(torchMode: AVCaptureTorchMode) -> UIImage
    {
        let array = ["CameraTorchOff", "CameraTorchOn", "CameraTorchAuto"]
        let imageName = array[torchMode.rawValue]
        return UIImage(named: imageName)!
    }
    
    
    private static func TintColorFromAVCapture(torchMode: AVCaptureTorchMode) -> UIColor
    {
        let array = [UIColor.grayColor(), TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[torchMode.rawValue]
        return color
    }
}