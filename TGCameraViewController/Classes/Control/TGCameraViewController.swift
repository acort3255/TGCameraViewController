//
//  TGCameraViewController.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/22/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

public class TGCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: TGCameraDelegate!
    @IBOutlet var captureView: UIView!
    @IBOutlet var topLeftView: UIImageView!
    @IBOutlet var topRightView: UIImageView!
    @IBOutlet var bottomLeftView: UIImageView!
    @IBOutlet var bottomRightView: UIImageView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var actionsView: UIView!
    @IBOutlet var closeButton: TGTintedButton!
    @IBOutlet var gridButton: TGTintedButton!
    @IBOutlet var toggleButton: TGTintedButton!
    @IBOutlet var shotButton: TGTintedButton!
    @IBOutlet var albumButton: TGTintedButton!
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var slideUpView: TGCameraSlideView!
    @IBOutlet var slideDownView: TGCameraSlideView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var toggleButtonWidth: NSLayoutConstraint!
    var camera: TGCamera!
    var wasLoaded: Bool!
    private var croppedVideoURL: NSURL!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        wasLoaded = false
        if CGRectGetHeight(UIScreen.mainScreen().bounds) <= 480 {
            self.topViewHeight.constant = 0
        }
        let devices: [AnyObject]? = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if devices != nil && devices!.count > 1 {
            if TGCamera.toggleButtonHidden == true {
                self.toggleButton.hidden = true
                self.toggleButtonWidth.constant = 0
            }
        }
        else {
            if TGCamera.toggleButtonHidden == true {
                self.toggleButton.hidden = true
                self.toggleButtonWidth.constant = 0
            }
        }
        if TGCamera.albumButtonHidden == true {
            self.albumButton.hidden = true
        }
        albumButton.layer.cornerRadius = 10.0
        albumButton.layer.masksToBounds = true
        
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        closeButton.setImage(UIImage(named: "CameraClose",inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
        shotButton.setImage(UIImage(named: "CameraShot", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
        gridButton.setImage(UIImage(named: "CameraGrid", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
        toggleButton.setImage(UIImage(named: "CameraToggle", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
        camera = TGCamera()
        self.camera.setupWithFlashButtonForPictures(flashButton)
        camera.delegate = self
        self.captureView.backgroundColor = UIColor.clearColor()
        self.topLeftView.transform = CGAffineTransformMakeRotation(0)
        self.topRightView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        self.bottomLeftView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        self.bottomRightView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 * 2))
        
        // Scaffolding for video support testing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(takePicture))
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordVideo))
        shotButton.addGestureRecognizer(tapGesture)
        shotButton.addGestureRecognizer(longTapGesture)

    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChangeNotification), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        separatorView.hidden = false;
        
        actionsView.hidden = true
        
        topLeftView.hidden = true
        topRightView.hidden = true
        bottomLeftView.hidden = true
        bottomRightView.hidden = true
        
        gridButton.enabled = false
        toggleButton.enabled = false
        shotButton.enabled = false
        albumButton.enabled = false
        flashButton.enabled = false
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        deviceOrientationDidChangeNotification()
        
        camera.startRunning()
        separatorView.hidden = true
        
        TGCameraSlideView.hideSlideUpView(slideUpView, slideDownView: slideDownView, atView: captureView, completion: {
            
            self.actionsView.hidden = false
            
            self.topLeftView.hidden = false
            self.topRightView.hidden = false
            self.bottomLeftView.hidden = false
            self.bottomRightView.hidden = false
            
            self.gridButton.enabled = true
            self.toggleButton.enabled = true
            self.shotButton.enabled = true
            self.albumButton.enabled = true
            self.flashButton.enabled = true
        })
        
        if !wasLoaded
        {
            wasLoaded = true
            camera.insertSublayerWithCaptureView(captureView, atRootView: view)
        }
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        camera.stopRunning()
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let photo: UIImage = TGAlbum.imageWithMediaInfo(info)!
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        let viewController: TGMediaViewController = mediaVC.newWithDelegateAndPhoto(delegate, photo: photo)
        viewController.albumPhoto = true
        self.navigationController!.pushViewController(viewController, animated: false)
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    // MARK: Actions
    
    @IBAction func closeTapped() {
        delegate.cameraDidCancel()
    }
    
    @IBAction func gridTapped() {
        camera.displayGridView()
    }
    
    @IBAction func flashTapped() {
        camera.changeFlashModeWithButton(flashButton)
    }
    
    /*@IBAction func shotTapped(sender: UITapGestureRecognizer) {
        shotButton.enabled = false
        albumButton.enabled = false
        
        
        let deviceOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        let videoOrientation: AVCaptureVideoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
        self.viewWillDisappearWithCompletion({() -> Void in
            TGCamera.takePhotoWithCaptureView(self.captureView, videoOrientation: videoOrientation, cropSize: self.captureView.frame.size, completion: {(photo: UIImage) -> Void in
                let viewController: TGPhotoViewController = TGPhotoViewController.newWithDelegate(self.delegate, photo: photo)
                self.navigationController!.pushViewController(viewController, animated: true)
            })
        })
    }*/
    
    func takePicture()
    {
        delegate.cameraWillCaptureMedia!()
        shotButton.enabled = false
        albumButton.enabled = false
        print("Taking picture ")
        let deviceOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        let videoOrientation: AVCaptureVideoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
        self.viewWillDisappearWithCompletion({() -> Void in
            self.camera.takePhotoWithCaptureView(self.captureView, videoOrientation: videoOrientation, cropSize: self.captureView.frame.size, completion: {(photo: UIImage) -> Void in
                let bundle = NSBundle(forClass: TGCameraViewController.self)
                let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
                let viewController: TGMediaViewController = mediaVC.newWithDelegateAndPhoto(self.delegate, photo: photo)
                self.navigationController!.pushViewController(viewController, animated: true)
            })
        })
    }
    
    func recordVideo(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began
        {
            delegate.cameraWillCaptureMedia!()
            print("Started recording")
            shotButton.enabled = false
            albumButton.enabled = false
            toggleButton.enabled = false
            
            // Set the torch to the what appears on the flash button
            camera.setTorchMode(flashButton)
            
            // removes previous cropped video
            cleanupPreviousVideo()
            
            let deviceOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
            let videoOrientation: AVCaptureVideoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
            camera.recordVideoWtihCaptureView(self.captureView, videoOrientation: videoOrientation, cropSize: self.captureView.frame.size)
        }
        
        if sender.state == UIGestureRecognizerState.Ended
        {
            print("Stopped recording")
            camera.stopRecording()
        }
    }
    
    
    @IBAction func albumTapped() {
        shotButton.enabled = false
        albumButton.enabled = false
        
        self.viewWillDisappearWithCompletion({() -> Void in
            let pickerController: UIImagePickerController = TGAlbum.imagePickerControllerWithDelegate(self)
            self.presentViewController(pickerController, animated: true, completion: { _ in })
        })

    }
    
    @IBAction func toggleTapped() {
        camera.toogleWithFlashButton(flashButton)
    }
    
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let touchPoint: CGPoint = recognizer.locationInView(captureView)
        camera.focusView(captureView, inTouchPoint: touchPoint)
    }
    
    // MARK: - Private methods
    
    
    func deviceOrientationDidChangeNotification() {
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        var degress: Int
        switch orientation {
        case .FaceUp, .Portrait, .Unknown:
            degress = 0
        case .LandscapeLeft:
            degress = 90
        case .FaceDown, .PortraitUpsideDown:
            degress = 180
        case .LandscapeRight:
            degress = 270
        }
        
        let radians: CGFloat = CGFloat(degress) * CGFloat(M_PI) / 180
        let transform = CGAffineTransformMakeRotation(radians)
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            self.gridButton.transform = transform
            self.toggleButton.transform = transform
            self.albumButton.transform = transform
            self.flashButton.transform = transform
        })
    }
    
    func videoOrientationForDeviceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result: AVCaptureVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        switch deviceOrientation {
        case .LandscapeLeft:
            result = .LandscapeRight
        case .LandscapeRight:
            result = .LandscapeLeft
        default:
            break
        }
        
        return result
    }
    
    func viewWillDisappearWithCompletion(completion: () -> Void) {
        self.actionsView.hidden = true
        TGCameraSlideView.showSlideUpView(slideUpView, slideDownView: slideDownView, atView: captureView, completion: {() -> Void in
            completion()
        })
    }
    
    func recordingStopped(videoFileURL: NSURL)
    {
        shotButton.enabled = true
        albumButton.enabled = true
        toggleButton.enabled = true
        flashButton.enabled = true
        
        //Send to TGMediaViewController
        croppedVideoURL = videoFileURL
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        let viewController: TGMediaViewController = mediaVC.newWithDelegateAndVideo(self.delegate, videoURL: videoFileURL)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func cleanupPreviousVideo()
    {
        if croppedVideoURL != nil{
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.croppedVideoURL)
            }
            catch _ {
            }
            
        }
    }
    
}