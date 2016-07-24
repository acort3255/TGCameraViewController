//
//  TGCamera.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

public class TGCamera: NSObject, AVCaptureFileOutputRecordingDelegate{
    
    public static var toggleButtonHidden = false
    public static var albumButtonHidden = false
    public static var filterButtonHidden = false
    public static var saveMediaToAlbum = false
    public var previewLayer: AVCaptureVideoPreviewLayer!
    public var stillImageOutput: AVCaptureStillImageOutput!
    
    // Video
    public static var recordsVideo: Bool = false
    public var movieOutputFile: AVCaptureMovieFileOutput!
    public var videoCaptureDevice: AVCaptureDevice!
    public var audioCaptureDevice: AVCaptureDevice!
    public var audioInput: AVCaptureDeviceInput!
    public var videoInput: AVCaptureDeviceInput!
    public var movieOutputFileURL = NSURL()
    public var delegate = TGCameraViewController()
    public var cropSize = CGSize()
    public var isRecording = false
    //
    
    private var session: AVCaptureSession!
    private var gridView: TGCameraGridView?
    
    public required override init() {
        super.init()
        
        previewLayer = AVCaptureVideoPreviewLayer()
        stillImageOutput = AVCaptureStillImageOutput()
        
    }
    
    public func gridViewSetup()
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
    
    public func newCamera() -> TGCamera {
        return self.dynamicType.init()
    }
    public func cameraWithFlashButton(flashButton: UIButton) -> TGCamera
    {
        let camera = newCamera()
        setupWithFlashButtonForPictures(flashButton)
        return camera
    }
    
    public func cameraWithFlashButton(flashButton: UIButton, devicePosition: AVCaptureDevicePosition)-> TGCamera{
        let camera = newCamera()
        setupWithFlashButtonForPictures(flashButton)
        return camera
    }
    
    public func startRunning()
    {
        session.startRunning()
    }
    
    public func stopRunning()
    {
        session.stopRunning()
    }
    
    public func stopRecording()
    {
        print("stop!!!!!!!")
        movieOutputFile.stopRecording()
        isRecording = false
    }
    
    public func insertSublayerWithCaptureView(captureView: UIView, atRootView rootView: UIView)
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
        cropSize = captureView.frame.size
        captureView.insertSubview(self.gridView!, atIndex: index)
    }
    
    public func displayGridView()
    {
        
        TGCameraGrid.disPlayGridView(gridView!)
    }
    
    public func changeFlashModeWithButton(button: UIButton)
    {
        if isRecording == false{
            TGCameraFlash.changeModeWithCaptureSession(session, andButton: button)
        }
        else
        {
            TGCameraTorch.changeModeWithCaptureSession(session, andButton: button)
        }
    }
    
    public func focusView(focusView: UIView, inTouchPoint touchPoint: CGPoint)
    {
        TGCameraFocus.focusWithCaptureSession(session, touchPoint: touchPoint, inFocusView: focusView)
    }
    
    public func takePhotoWithCaptureView(captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: (image: UIImage) -> Void)
    {
        TGCameraShot.takePhotoCaptureView(captureView, stillImageOutput: stillImageOutput, videoOrientation: videoOrientation, cropSize: cropSize, completion: {(photo: UIImage) -> Void in
            completion(image: photo)
        })

    }
    
    public func recordVideoWtihCaptureView(captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize)
    {
        TGCameraShot.recordVideoCaptureView(captureView, movieFileOutput: movieOutputFile, videoOrientation: videoOrientation, cropSize: cropSize, delegate: self)
        isRecording = true
    }
    
    public func toogleWithFlashButton(flashButton: UIButton)
    {
        TGCameraToggle.toogleWithCaptureSession(session)
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)

    }
    
    // MARK - Private Methods
    
    
    public func setupWithFlashButtonForPictures(flashButton: UIButton) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetHigh
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
        
        movieOutputFile = AVCaptureMovieFileOutput()
        session.addOutput(movieOutputFile)
        audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        audioInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        session.addInput(audioInput)
        
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)

    }
    
    public func setupWithFlashButtonForPictures(flashButton: UIButton, devicePosition: AVCaptureDevicePosition) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetHigh
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
        
        movieOutputFile = AVCaptureMovieFileOutput()
        session.addOutput(movieOutputFile)
        audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        audioInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        session.addInput(audioInput)
        
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)
    }
    
    /* public func setupWithFlashButtonForVideo(flashButton: UIButton)
    {
        //
        // create session
        //
        //session = AVCaptureSession()
        //self.session.sessionPreset = AVCaptureSessionPresetPhoto
        //
        // setup device
        //
        movieOutputFile = AVCaptureMovieFileOutput()
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
        
        
        session.beginConfiguration()
        audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        audioInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        session.addInput(audioInput)
        session.addOutput(movieOutputFile)
        session.commitConfiguration()
        
        //
        // setup torch button
        //
        TGCameraTorch.torchModeWithCaptureSession(session, andButton: flashButton)
    }*/
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!)
    {
        // send url for cropped video
        print("did Finish recording")
        
        if error == nil
        {
            //let tempURL = TGMediaCrop.cropVideo(outputFileURL, withCropSize: cropSize)
            //delegate.recordingStopped(tempURL)
            TGMediaCrop.cropVideo(outputFileURL, completion: { (croppedVideoURL) in
                
                dispatch_async(dispatch_get_main_queue(), {
                   self.delegate.recordingStopped(croppedVideoURL)
                })
            })
        }
        
        else
        {
            print(error.description)
        }
    }
}