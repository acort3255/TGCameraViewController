//
//  TGCamera.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

public class TGCamera: NSObject {
    
    public static var toggleButtonHidden: Bool = false
    public static var albumButtonHidden: Bool = false
    public static var filterButtonHidden: Bool = false
    public static var saveImageToAlbum: Bool = false
    public static var previewLayer = AVCaptureVideoPreviewLayer()
    public static var stillImageOutput = AVCaptureStillImageOutput()
    
    private static var session = AVCaptureSession()
    private static var gridView: TGCameraGridView?
    
    public required override init() {
        super.init()
    }
    
    public static func gridViewSetup()
    {
        if  self.gridView == nil {
            var frame: CGRect = previewLayer.frame
            frame.origin.x = 0
            frame.origin.y = 0
            self.gridView = TGCameraGridView(frame: frame)
            self.gridView!.numberOfColumns = 2
            self.gridView!.numberOfRows = 2
            self.gridView!.alpha = 0
        }
    }
    
    public static func newCamera() -> TGCamera {
        return super.init() as! TGCamera
    }
    public static func cameraWithFlashButton(flashButton: UIButton) -> TGCamera
    {
        let camera = TGCamera.newCamera()
        setupWithFlashButton(flashButton)
        return camera
    }
    
    public static func cameraWithFlashButton(flashButton: UIButton, devicePosition: AVCaptureDevicePosition)-> TGCamera{
        let camera = TGCamera.newCamera()
        setupWithFlashButton(flashButton, devicePosition: devicePosition)
        return camera
    }
    
    public static func startRunning()
    {
        session.startRunning()
    }
    
    public static func stopRunning()
    {
        session.stopRunning()
    }
    
    public static func insertSublayerWithCaptureView(captureView: UIView, atRootView rootView: UIView)
    {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let rootLayer: CALayer = rootView.layer
        rootLayer.masksToBounds = true
        let frame: CGRect = captureView.frame
        self.previewLayer.frame = frame
        rootLayer.insertSublayer(previewLayer, atIndex: 0)
        let index: Int = captureView.subviews.count - 1
        gridViewSetup()
        captureView.insertSubview(self.gridView!, atIndex: index)
    }
    
    public static func displayGridView()
    {
        
        TGCameraGrid.disPlayGridView(gridView!)
    }
    
    public static func changeFlashModeWithButton(button: UIButton)
    {
        TGCameraFlash.changeModeWithCaptureSession(session, andButton: button)
    }
    
    public static func focusView(focusView: UIView, inTouchPoint touchPoint: CGPoint)
    {
        TGCameraFocus.focusWithCaptureSession(session, touchPoint: touchPoint, inFocusView: focusView)
    }
    
    public static func takePhotoWithCaptureView(captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: (image: UIImage) -> Void)
    {
        TGCameraShot.takePhotoCaptureView(captureView, stillImageOutput: stillImageOutput, videoOrientation: videoOrientation, cropSize: cropSize, completion: {(photo: UIImage) -> Void in
            completion(image: photo)
        })

    }
    
    public static func toogleWithFlashButton(flashButton: UIButton)
    {
        TGCameraToggle.toogleWithCaptureSession(session)
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)

    }
    
    // MARK - Private Methods
    
    
    public static func setupWithFlashButton(flashButton: UIButton) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        //
        // setup device
        //
        let device: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do{
            try device.lockForConfiguration()
            if device.autoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .Near
            }
            if device.smoothAutoFocusSupported {
                device.smoothAutoFocusEnabled = true
            }
            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusMode = .ContinuousAutoFocus
            }
            device.exposureMode = .ContinuousAutoExposure
            device.unlockForConfiguration()
        }
        
        catch
        {
            print("Unable to lock configuration")
        }
        
        //
        // add device input to session
        //
        let deviceInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device)
        session.addInput(deviceInput)
        //
        // add output to session
        //
        let outputSettings: [NSObject : AnyObject] = [
            AVVideoCodecJPEG : AVVideoCodecKey
        ]
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings = outputSettings
        session.addOutput(stillImageOutput)
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)

    }
    
    public static func setupWithFlashButton(flashButton: UIButton, devicePosition: AVCaptureDevicePosition) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        //
        // setup device
        //
        let devices: [AnyObject] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var device: AVCaptureDevice
        for aDevice in devices {
            if aDevice.position == devicePosition {
                device = aDevice as! AVCaptureDevice
            }
        }
        //if  device != nil {
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //}
        
        do {
            try device.lockForConfiguration()
            if device.autoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .Near
            }
            if device.smoothAutoFocusSupported {
                device.smoothAutoFocusEnabled = true
            }
            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusMode = .ContinuousAutoFocus
            }
            device.exposureMode = .ContinuousAutoExposure
            device.unlockForConfiguration()
        }
        
        catch{
            print("Unable to lock configuration")
        }
        
        //
        // add device input to session
        //
        let deviceInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device)
        session.addInput(deviceInput)
        //
        // add output to session
        //
        let outputSettings: [NSObject : AnyObject] = [
            AVVideoCodecJPEG : AVVideoCodecKey
        ]
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings = outputSettings
        session.addOutput(stillImageOutput)
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)
    }
}