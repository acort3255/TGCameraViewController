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

public class TGCameraNavigationController: UINavigationController {
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("User newWithCameraDelegate to init")
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        print("User newWithCameraDelegate to init")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("User newWithCameraDelegate to init")
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    static public func newWithCameraDelegate(delegate: TGCameraDelegate) -> TGCameraNavigationController{
        let navigationController: TGCameraNavigationController = TGCameraNavigationController()
        navigationController.navigationBarHidden = true
        //if navigationController != nil {
            let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            switch status {
            case .Authorized:
                navigationController.setupAuthorizedWithDelegate(delegate)
            case .Restricted, .Denied:
                navigationController.setupDenied()
            case .NotDetermined:
                navigationController.setupNotDeterminedWithDelegate(delegate)
            }
        // }
        return navigationController

    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override public func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK -Private Methods
    
    func setupAuthorizedWithDelegate(delegate: TGCameraDelegate) {
        
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let viewController: TGCameraViewController = TGCameraViewController(nibName: "TGCameraViewController", bundle: bundle)
        viewController.delegate = delegate
        self.viewControllers = [viewController]
    }
    
    func setupDenied() {
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let viewController: UIViewController = TGCameraAuthorizationViewController(nibName: "TGCameraAuthorizationViewController", bundle: bundle)
        self.viewControllers = [viewController]
    }
    
    func setupNotDeterminedWithDelegate(delegate: TGCameraDelegate)
    {
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted: Bool) -> Void in
            if granted {
                self.setupAuthorizedWithDelegate(delegate)
            }
            else {
                self.setupDenied()
            }
            dispatch_semaphore_signal(semaphore)
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}