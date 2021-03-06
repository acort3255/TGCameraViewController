//
//  TGCameraToggle.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import AVFoundation

open class TGCameraToggle: NSObject {
    open static func toogleWithCaptureSession(_ session: AVCaptureSession)
    {
        var deviceInput: AVCaptureDeviceInput! //= session.inputs.last as! AVCaptureDeviceInput
        
        for input in session.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasMediaType(AVMediaTypeVideo)
            {
                deviceInput = input as! AVCaptureDeviceInput
            }
        }
        
        if deviceInput != nil {
            let reverseDeviceInput: AVCaptureDeviceInput = self.reverseDeviceInput(deviceInput)!
            session.beginConfiguration()
            session.removeInput(deviceInput)
            session.addInput(reverseDeviceInput)
            session.commitConfiguration()
        }
    }
    
    // MARK: Private
    
    static func reverseDeviceInput(_ deviceInput: AVCaptureDeviceInput) -> AVCaptureDeviceInput? {
        //
        // reverse device position
        //
        var reversePosition: AVCaptureDevicePosition
        if deviceInput.device.position == .front {
            reversePosition = .back
        }
        else {
            reversePosition = .front
        }
        //
        // find device with reverse position
        //
        let devices: [AnyObject] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as [AnyObject]
        var reverseDevice: AVCaptureDevice? = nil
        for device in devices {
            if device.position == reversePosition {
                reverseDevice = device as? AVCaptureDevice
            }
        }
        //
        // reverse device input
        //
        do {
            return try AVCaptureDeviceInput(device: reverseDevice!)
        }
        catch let error {
            print(error)
            return nil
        }
       
        
    }
}
