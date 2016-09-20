//
//  TGCameraFocus.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

open class TGCameraFocus: NSObject {
    open static func focusWithCaptureSession(_ session: AVCaptureSession, touchPoint: CGPoint, inFocusView focusView: UIView) {
        
        let device: AVCaptureDevice = (session.inputs.last as! AVCaptureDeviceInput).device
        self.showFocusView(focusView, withTouchPoint: touchPoint, andDevice: device)
        do{
            try device.lockForConfiguration()
            let pointOfInterest: CGPoint = self.pointOfInterestWithTouchPoint(touchPoint)
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = pointOfInterest
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = pointOfInterest
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        }
        
        catch
        {
            print("Could not lock configuration for AVCapture device")
        }
    }
    
    // MARK: - Private methods
    
    static func pointOfInterestWithTouchPoint(_ touchPoint: CGPoint) -> CGPoint {
        let screenSize: CGSize = UIScreen.main.bounds.size
        var pointOfInterest = CGPoint()
        pointOfInterest.x = touchPoint.x / screenSize.width
        pointOfInterest.y = touchPoint.y / screenSize.height
        return pointOfInterest
    }
    
    static func showFocusView(_ focusView: UIView, withTouchPoint touchPoint: CGPoint, andDevice device: AVCaptureDevice) {
        //
        // add focus view animated
        //
        let cameraFocusView: TGCameraFocusView = TGCameraFocusView(frame: CGRect(x: 0, y: 0, width: TGCameraFocusSize, height: TGCameraFocusSize))
        cameraFocusView.center = touchPoint
        focusView.addSubview(cameraFocusView)
        cameraFocusView.startAnimation()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {() -> Void in
            Thread.sleep(forTimeInterval: 0.5)
            while device.isAdjustingFocus || device.isAdjustingExposure || device.isAdjustingWhiteBalance {
                
            }
            DispatchQueue.main.async(execute: {() -> Void in
                //
                // remove focus view and focus subview animated
                //
                cameraFocusView.stopAnimation()
            })
        })
    }
}
