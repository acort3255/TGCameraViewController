//
//  TGCameraViewController.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/22/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit
import AVFoundation

open class TGCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    @IBOutlet weak var lblStopWatch: UILabel!
    @IBOutlet var slideUpView: TGCameraSlideView!
    @IBOutlet var slideDownView: TGCameraSlideView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var toggleButtonWidth: NSLayoutConstraint!
    var camera: TGCamera!
    var wasLoaded: Bool!
    fileprivate var croppedVideoURL: URL!
    fileprivate var timer: Timer?
    fileprivate var stopWatchValue: Int = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        wasLoaded = false
        if UIScreen.main.bounds.height <= 480 {
            self.topViewHeight.constant = 0
        }
        let devices: [AnyObject]? = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as [AnyObject]?
        if devices != nil && devices!.count > 1 {
            if TGCamera.toggleButtonHidden == true {
                self.toggleButton.isHidden = true
                self.toggleButtonWidth.constant = 0
            }
        }
        else {
            if TGCamera.toggleButtonHidden == true {
                self.toggleButton.isHidden = true
                self.toggleButtonWidth.constant = 0
            }
        }
        if TGCamera.albumButtonHidden == true {
            self.albumButton.isHidden = true
        }
        
        lblStopWatch.isHidden = true
        
        albumButton.layer.cornerRadius = 10.0
        albumButton.layer.masksToBounds = true
        
        let bundle = Bundle(for: TGCameraViewController.self)
        closeButton.setImage(UIImage(named: "CameraClose",in: bundle, compatibleWith: nil)!, for: .normal)
        shotButton.setImage(UIImage(named: "CameraShot", in: bundle, compatibleWith: nil)!, for: .normal)
        gridButton.setImage(UIImage(named: "CameraGrid", in: bundle, compatibleWith: nil)!, for: .normal)
        toggleButton.setImage(UIImage(named: "CameraToggle", in: bundle, compatibleWith: nil)!, for: .normal)
        camera = TGCamera()
        self.camera.setupWithFlashButtonForPictures(flashButton)
        camera.delegate = self
        self.captureView.backgroundColor = UIColor.clear
        self.topLeftView.transform = CGAffineTransform(rotationAngle: 0)
        self.topRightView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        self.bottomLeftView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        self.bottomRightView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2 * 2))
        
        // Scaffolding for video support testing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(takePicture))
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordVideo))
        shotButton.addGestureRecognizer(tapGesture)
        shotButton.addGestureRecognizer(longTapGesture)

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChangeNotification), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        separatorView.isHidden = false;
        
        actionsView.isHidden = true
        
        topLeftView.isHidden = true
        topRightView.isHidden = true
        bottomLeftView.isHidden = true
        bottomRightView.isHidden = true
        
        gridButton.isEnabled = false
        toggleButton.isEnabled = false
        shotButton.isEnabled = false
        albumButton.isEnabled = false
        flashButton.isEnabled = false
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        deviceOrientationDidChangeNotification()
        
        camera.startRunning()
        separatorView.isHidden = true
        
        TGCameraSlideView.hideSlideUpView(slideUpView, slideDownView: slideDownView, atView: captureView, completion: {
            
            self.actionsView.isHidden = false
            
            self.topLeftView.isHidden = false
            self.topRightView.isHidden = false
            self.bottomLeftView.isHidden = false
            self.bottomRightView.isHidden = false
            
            self.gridButton.isEnabled = true
            self.toggleButton.isEnabled = true
            self.shotButton.isEnabled = true
            self.albumButton.isEnabled = true
            self.flashButton.isEnabled = true
            
            if TGCamera.stopWatchHidden == false
            {
                self.resetTimer()
            }
            
        })
        
        if !wasLoaded
        {
            wasLoaded = true
            camera.insertSublayerWithCaptureView(captureView, atRootView: view)
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        lblStopWatch.isHidden = true
        resetTimer()
        killTimer()
        camera.stopRunning()
    }
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let photo: UIImage = TGAlbum.imageWithMediaInfo(info)!
        let bundle = Bundle(for: TGCameraViewController.self)
        let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        let viewController: TGMediaViewController = mediaVC.newWithDelegateAndPhoto(delegate, photo: photo)
        viewController.albumPhoto = true
        self.navigationController!.pushViewController(viewController, animated: false)
        self.dismiss(animated: true, completion: { _ in })
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: { _ in })
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
    
    func takePicture()
    {
        delegate.cameraWillCaptureMedia!()
        shotButton.isEnabled = false
        albumButton.isEnabled = false
        //print("Taking picture ")
        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        let videoOrientation: AVCaptureVideoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
        self.viewWillDisappearWithCompletion({() -> Void in
            self.camera.takePhotoWithCaptureView(self.captureView, videoOrientation: videoOrientation, cropSize: self.captureView.frame.size, completion: {(photo: UIImage) -> Void in
                let bundle = Bundle(for: TGCameraViewController.self)
                let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
                let viewController: TGMediaViewController = mediaVC.newWithDelegateAndPhoto(self.delegate, photo: photo)
                self.navigationController!.pushViewController(viewController, animated: true)
            })
        })
    }
    
    func recordVideo(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.began
        {
            delegate.cameraWillCaptureMedia!()
            //print("Started recording")
            shotButton.isEnabled = false
            albumButton.isEnabled = false
            toggleButton.isEnabled = false
            
            // Set the torch to the what appears on the flash button
            camera.setTorchMode(flashButton)
            
            // removes previous cropped video
            cleanupPreviousVideo()
            
            let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
            let videoOrientation: AVCaptureVideoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
            
            if TGCamera.maxDuration != CMTimeMake(0, 0) || TGCamera.stopWatchHidden == false
            {
                startTimer()
            }
            
            if TGCamera.stopWatchHidden == false
            {
                lblStopWatch.isHidden = false
            }
            
            camera.recordVideoWtihCaptureView(self.captureView, videoOrientation: videoOrientation, cropSize: self.captureView.frame.size)
        }
        
        if sender.state == UIGestureRecognizerState.ended
        {
            //print("Stopped recording")
            
            if TGCamera.maxDuration != CMTimeMake(0, 0) || TGCamera.stopWatchHidden == false
            {
                killTimer()
            }
            
            camera.stopRecording()
        }
    }
    
    
    @IBAction func albumTapped() {
        shotButton.isEnabled = false
        albumButton.isEnabled = false
        
        self.viewWillDisappearWithCompletion({() -> Void in
            let pickerController: UIImagePickerController = TGAlbum.imagePickerControllerWithDelegate(self)
            self.present(pickerController, animated: true, completion: { _ in })
        })

    }
    
    @IBAction func toggleTapped() {
        camera.toogleWithFlashButton(flashButton)
    }
    
    @IBAction func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        let touchPoint: CGPoint = recognizer.location(in: captureView)
        camera.focusView(captureView, inTouchPoint: touchPoint)
    }
    
    // MARK: - Private methods
    
    
    func deviceOrientationDidChangeNotification() {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        var degress: Int
        switch orientation {
        case .faceUp, .portrait, .unknown:
            degress = 0
        case .landscapeLeft:
            degress = 90
        case .faceDown, .portraitUpsideDown:
            degress = 180
        case .landscapeRight:
            degress = 270
        }
        
        let radians: CGFloat = CGFloat(degress) * CGFloat(M_PI) / 180
        let transform = CGAffineTransform(rotationAngle: radians)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.gridButton.transform = transform
            self.toggleButton.transform = transform
            self.albumButton.transform = transform
            self.flashButton.transform = transform
        })
    }
    
    func videoOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result: AVCaptureVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        switch deviceOrientation {
        case .landscapeLeft:
            result = .landscapeRight
        case .landscapeRight:
            result = .landscapeLeft
        default:
            break
        }
        
        return result
    }
    
    func viewWillDisappearWithCompletion(_ completion: @escaping () -> Void) {
        self.actionsView.isHidden = true
        TGCameraSlideView.showSlideUpView(slideUpView, slideDownView: slideDownView, atView: captureView, completion: {() -> Void in
            completion()
        })
    }
    
    // MARK: Timer methods
    
    func updateTimerLabel()
    {
        if  TGCamera.maxDuration != CMTimeMake(0, 0) && Double(self.lblStopWatch.text!)! >= (TGCamera.maxDuration.seconds - 1)
        {
            killTimer()
            stopWatchValue += 1
            lblStopWatch.text = "\(stopWatchValue)"
            camera.stopRecording()
            return
        }
        
        stopWatchValue += 1
        lblStopWatch.text = "\(stopWatchValue)"
    }
    
    func startTimer()
    {
        lblStopWatch.text = "\(stopWatchValue)"
        killTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    func killTimer()
    {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func resetTimer()
    {
        stopWatchValue = 0
        lblStopWatch.text = "\(stopWatchValue)"
    }
    
    func recordingStopped(_ videoFileURL: URL)
    {
        shotButton.isEnabled = true
        albumButton.isEnabled = true
        toggleButton.isEnabled = true
        flashButton.isEnabled = true
        
        //Send to TGMediaViewController
        croppedVideoURL = videoFileURL
        let bundle = Bundle(for: TGCameraViewController.self)
        let mediaVC = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        let viewController: TGMediaViewController = mediaVC.newWithDelegateAndVideo(self.delegate, videoURL: videoFileURL)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func cleanupPreviousVideo()
    {
        if croppedVideoURL != nil{
            do {
                try FileManager.default.removeItem(at: self.croppedVideoURL)
            }
            catch _ {
            }
            
        }
    }
    
}
