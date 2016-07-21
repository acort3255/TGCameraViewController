//
//  TGCameraFocus.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

public class TGCameraFocus: NSObject {
    public static func focusWithCaptureSession(session: AVCaptureSession, touchPoint: CGPoint, inFocusView focusView: UIView) {
        
        let device: AVCaptureDevice = session.inputs.last!.device
        self.showFocusView(focusView, withTouchPoint: touchPoint, andDevice: device)
        do{
            try device.lockForConfiguration()
            let pointOfInterest: CGPoint = self.pointOfInterestWithTouchPoint(touchPoint)
            if device.focusPointOfInterestSupported {
                device.focusPointOfInterest = pointOfInterest
            }
            if device.exposurePointOfInterestSupported {
                device.exposurePointOfInterest = pointOfInterest
            }
            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusMode = .ContinuousAutoFocus
            }
            if device.isExposureModeSupported(.ContinuousAutoExposure) {
                device.exposureMode = .ContinuousAutoExposure
            }
            device.unlockForConfiguration()
        }
        
        catch
        {
            print("Could not lock configuration for AVCapture device")
        }
    }
    
    // MARK: - Private methods
    
    static func pointOfInterestWithTouchPoint(touchPoint: CGPoint) -> CGPoint {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        var pointOfInterest = CGPoint()
        pointOfInterest.x = touchPoint.x / screenSize.width
        pointOfInterest.y = touchPoint.y / screenSize.height
        return pointOfInterest
    }
    
    static func showFocusView(focusView: UIView, withTouchPoint touchPoint: CGPoint, andDevice device: AVCaptureDevice) {
        //
        // add focus view animated
        //
        let cameraFocusView: TGCameraFocusView = TGCameraFocusView(frame: CGRectMake(0, 0, TGCameraFocusSize, TGCameraFocusSize))
        cameraFocusView.center = touchPoint
        focusView.addSubview(cameraFocusView)
        cameraFocusView.startAnimation()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {() -> Void in
            NSThread.sleepForTimeInterval(0.5)
            while device.adjustingFocus || device.adjustingExposure || device.adjustingWhiteBalance {
                
            }
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                //
                // remove focus view and focus subview animated
                //
                cameraFocusView.stopAnimation()
            })
        })
    }
}