//
//  TGCamera.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

open class TGCamera: NSObject, AVCaptureFileOutputRecordingDelegate{
    
    open static var toggleButtonHidden = false
    open static var albumButtonHidden = false
    open static var filterButtonHidden = false
    open static var saveMediaToAlbum = false
    open static var stopWatchHidden = true
    open static var maxDuration = CMTimeMake(0, 0)
    open static var minDuration = CMTimeMake(0, 0)
    open static var capturePreset = AVCaptureSessionPreset1280x720
    open var previewLayer: AVCaptureVideoPreviewLayer!
    open var stillImageOutput: AVCaptureStillImageOutput!
    
    // Video
    open static var recordsVideo: Bool = false
    open var movieOutputFile: AVCaptureMovieFileOutput!
    open var videoCaptureDevice: AVCaptureDevice!
    open var audioCaptureDevice: AVCaptureDevice!
    open var audioInput: AVCaptureDeviceInput!
    open var videoInput: AVCaptureDeviceInput!
    open var movieOutputFileURL = URL(string: "")
    open var delegate = TGCameraViewController()
    open var cropSize = CGSize()
    open var isRecording = false
    //
    
    fileprivate var session: AVCaptureSession!
    fileprivate var gridView: TGCameraGridView?
    
    public required override init() {
        super.init()
        
        //previewLayer = AVCaptureVideoPreviewLayer()
        //stillImageOutput = AVCaptureStillImageOutput()
        
    }
    
    open func gridViewSetup()
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
    
    open func newCamera() -> TGCamera {
        return type(of: self).init()
    }
    open func cameraWithFlashButton(_ flashButton: UIButton) -> TGCamera
    {
        let camera = newCamera()
        setupWithFlashButtonForPictures(flashButton)
        return camera
    }
    
    open func cameraWithFlashButton(_ flashButton: UIButton, devicePosition: AVCaptureDevicePosition)-> TGCamera{
        let camera = newCamera()
        setupWithFlashButtonForPictures(flashButton)
        return camera
    }
    
    open func startRunning()
    {
        session.startRunning()
    }
    
    open func stopRunning()
    {
        session.stopRunning()
    }
    
    open func stopRecording()
    {
        movieOutputFile.stopRecording()
        isRecording = false
    }
    
    open func insertSublayerWithCaptureView(_ captureView: UIView, atRootView rootView: UIView)
    {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let rootLayer: CALayer = rootView.layer
        rootLayer.masksToBounds = true
        let frame: CGRect = captureView.frame
        self.previewLayer.frame = frame
        rootLayer.insertSublayer(previewLayer, at: 0)
        let index: Int = captureView.subviews.count - 1
        gridViewSetup()
        cropSize = captureView.frame.size
        captureView.insertSubview(self.gridView!, at: index)
    }
    
    open func displayGridView()
    {
        
        TGCameraGrid.disPlayGridView(gridView!)
    }
    
    open func changeFlashModeWithButton(_ button: UIButton)
    {
        if isRecording == false{
            TGCameraFlash.changeModeWithCaptureSession(session, andButton: button)
        }
        else
        {
            TGCameraTorch.changeModeWithCaptureSession(session, andButton: button)
        }
    }
    
    open func focusView(_ focusView: UIView, inTouchPoint touchPoint: CGPoint)
    {
        TGCameraFocus.focusWithCaptureSession(session, touchPoint: touchPoint, inFocusView: focusView)
    }
    
    open func takePhotoWithCaptureView(_ captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping (_ image: UIImage) -> Void)
    {
        TGCameraShot.takePhotoCaptureView(captureView, stillImageOutput: stillImageOutput, videoOrientation: videoOrientation, cropSize: cropSize, completion: {(photo: UIImage) -> Void in
            completion(photo)
        })

    }
    
    open func recordVideoWtihCaptureView(_ captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize)
    {
        TGCameraShot.recordVideoCaptureView(captureView, movieFileOutput: movieOutputFile, videoOrientation: videoOrientation, cropSize: cropSize, delegate: self)
        isRecording = true
    }
    
    open func toogleWithFlashButton(_ flashButton: UIButton)
    {
        TGCameraToggle.toogleWithCaptureSession(session)
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)
        
    }
    
    // Sets the flash mode to what appears on the flash button for when the view disappears
    open func setFlashMode(_ flashButton: UIButton)
    {
        TGCameraFlash.matchFlashModeToTorchMode(session, andButton: flashButton)
    }
    
    // Sets the torch mode to what appears on the flash button when the recording
    open func setTorchMode(_ flashButton: UIButton)
    {
        TGCameraTorch.matchTorchModeToFlashMode(session, andButton: flashButton)
    }
    
    // MARK - Private Methods
    
    
    open func setupWithFlashButtonForPictures(_ flashButton: UIButton) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = TGCamera.capturePreset
        self.session.automaticallyConfiguresApplicationAudioSession = false
        self.session.usesApplicationAudioSession = true
        
        
        //
        // setup device
        //
        let device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do{
            try device.lockForConfiguration()
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
            if device.isSmoothAutoFocusSupported {
                device.isSmoothAutoFocusEnabled = true
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.exposureMode = .continuousAutoExposure
            
            
            if TGCamera.minDuration != CMTimeMake(0, 0)
            {
                device.activeVideoMinFrameDuration = TGCamera.minDuration
            }
            
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
        let outputSettings: [AnyHashable: Any] = [
            AVVideoCodecJPEG : AVVideoCodecKey
        ]
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings = outputSettings
        session.addOutput(stillImageOutput)
        
        movieOutputFile = AVCaptureMovieFileOutput()
        
        if TGCamera.maxDuration != CMTimeMake(0, 0)
        {
            movieOutputFile.maxRecordedDuration = TGCamera.maxDuration
        }
        
        session.addOutput(movieOutputFile)
        audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        audioInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        session.addInput(audioInput)
        
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)

    }
    
    open func setupWithFlashButtonForPictures(_ flashButton: UIButton, devicePosition: AVCaptureDevicePosition) {
        //
        // create session
        //
        self.session = AVCaptureSession()
        self.session.sessionPreset = TGCamera.capturePreset
        self.session.automaticallyConfiguresApplicationAudioSession = false
        self.session.usesApplicationAudioSession = true
        //
        // setup device
        //
        let devices: [AnyObject] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as [AnyObject]
        var device: AVCaptureDevice
        for aDevice in devices {
            if aDevice.position == devicePosition {
                device = aDevice as! AVCaptureDevice
                //device.activeVideoMaxFrameDuration
            }
        }
        //if  device != nil {
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //}
        
        do {
            try device.lockForConfiguration()
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }
            if device.isSmoothAutoFocusSupported {
                device.isSmoothAutoFocusEnabled = true
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.exposureMode = .continuousAutoExposure
            
            if TGCamera.minDuration != CMTimeMake(0, 0)
            {
                device.activeVideoMinFrameDuration = TGCamera.minDuration
            }
            
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
        let outputSettings: [AnyHashable: Any] = [
            AVVideoCodecJPEG : AVVideoCodecKey
        ]
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings = outputSettings
        session.addOutput(stillImageOutput)
        
        movieOutputFile = AVCaptureMovieFileOutput()
        
        if TGCamera.maxDuration != CMTimeMake(0, 0)
        {
            movieOutputFile.maxRecordedDuration = TGCamera.maxDuration
        }
        
        session.addOutput(movieOutputFile)
        audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        audioInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        session.addInput(audioInput)
        
        //
        // setup flash button
        //
        TGCameraFlash.flashModeWithCaptureSession(session, andButton: flashButton)
    }
    
    open func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!)
    {
        // send url for cropped video
        if error == nil
        {
            //let tempURL = TGMediaCrop.cropVideo(outputFileURL, withCropSize: cropSize)
            //delegate.recordingStopped(outputFileURL)
            TGMediaCrop.cropVideo(outputFileURL, completion: { (croppedVideoURL) in
                
                DispatchQueue.main.async(execute: {
                   self.delegate.recordingStopped(croppedVideoURL)
                })
            })
        }
        
        else
        {
            print(error)
        }
    }
}
