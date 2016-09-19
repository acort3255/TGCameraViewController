//
//  TGCameraNavigationController.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/22/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

open class TGCameraNavigationController: UINavigationController {
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //print("User newWithCameraDelegate to init")
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        //print("User newWithCameraDelegate to init")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //print("User newWithCameraDelegate to init")
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    static open func newWithCameraDelegate(_ delegate: TGCameraDelegate) -> TGCameraNavigationController{
        let navigationController: TGCameraNavigationController = TGCameraNavigationController()
        navigationController.isNavigationBarHidden = true
        //if navigationController != nil {
            let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch status {
            case .authorized:
                navigationController.setupAuthorizedWithDelegate(delegate)
            case .restricted, .denied:
                navigationController.setupDenied()
            case .notDetermined:
                navigationController.setupNotDeterminedWithDelegate(delegate)
            }
        // }
        return navigationController

    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    override open var shouldAutorotate : Bool {
        return false
    }
    
    // MARK -Private Methods
    
    func setupAuthorizedWithDelegate(_ delegate: TGCameraDelegate) {
        
        let bundle = Bundle(for: TGCameraViewController.self)
        let viewController: TGCameraViewController = TGCameraViewController(nibName: "TGCameraViewController", bundle: bundle)
        viewController.delegate = delegate
        self.viewControllers = [viewController]
    }
    
    func setupDenied() {
        let bundle = Bundle(for: TGCameraViewController.self)
        let viewController: UIViewController = TGCameraAuthorizationViewController(nibName: "TGCameraAuthorizationViewController", bundle: bundle)
        self.viewControllers = [viewController]
    }
    
    func setupNotDeterminedWithDelegate(_ delegate: TGCameraDelegate)
    {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(granted: Bool) -> Void in
            if granted {
                self.setupAuthorizedWithDelegate(delegate)
            }
            else {
                self.setupDenied()
            }
            semaphore.signal()
        })
        //semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}
