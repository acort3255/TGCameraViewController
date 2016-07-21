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
        let device: AVCaptureDevice = (session.inputs.last?.device)!
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
    
    public static func flashModeWithCaptureSession(session: AVCaptureSession, andButton button: UIButton) {
        
        let device: AVCaptureDevice = (session.inputs.last?.device)!
        let mode: AVCaptureFlashMode = device.flashMode
        let image: UIImage = UIImageFromAVCapture(mode)
        let tintColor: UIColor = TintColorFromAVCapture(mode)
        button.enabled = device.isFlashModeSupported(mode)
        if (button is TGTintedButton) {
            (button as! TGTintedButton).customTintColorOverride = tintColor
        }
        button.setImage(image, forState: .Normal)
    }
    
    // MARK: Private
    
    private static func UIImageFromAVCapture(flashMode: AVCaptureFlashMode) -> UIImage
    {
        let array = ["CameraFlashOff", "CameraFlashOn", "CameraFlashAuto"]
        let imageName = array[flashMode.rawValue]
        return UIImage(named: imageName)!
    }
    
    
    private static func TintColorFromAVCapture(flashMode: AVCaptureFlashMode) -> UIColor
    {
        let array = [UIColor.grayColor(), TGCameraColor.tintColor(), TGCameraColor.tintColor()]
        let color: UIColor = array[flashMode.rawValue]
        return color
    }

}
