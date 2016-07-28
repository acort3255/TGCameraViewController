//
//  TGMediaViewController.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/22/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import UIKit
import Photos

let kTGCacheSatureKey: String = "TGCacheSatureKey"
let kTGCacheCurveKey: String = "TGCacheCurveKey"
let kTGCacheVignetteKey: String = "TGCacheVignetteKey"


public class TGMediaViewController: UIViewController, PlayerDelegate
{
    
    
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var filterView: TGCameraFilterView!
    @IBOutlet var defaultFilterButton: UIButton!
    @IBOutlet weak var filterWandButton: TGTintedButton!
    @IBOutlet weak var cancelButton: TGTintedButton!
    @IBOutlet weak var confirmButton: TGTintedButton!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    public var delegate: TGCameraDelegate!
    var detailFilterView: UIView!
    var photo: UIImage!
    var videoURL: NSURL!
    var cachePhoto: NSCache!
    var isVideo: Bool = false
    var videoPlayer: TGPlayer!
    public var albumPhoto: Bool!
    
    
    /*public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }*/
    
    public func newWithDelegateAndPhoto(delegate: TGCameraDelegate, photo: UIImage) -> TGMediaViewController
    {
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let viewController: TGMediaViewController = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        viewController.delegate = delegate
        viewController.photo = photo
        viewController.cachePhoto = NSCache()
        return viewController

    }
    
    public func newWithDelegateAndVideo(delegate: TGCameraDelegate, videoURL: NSURL) -> TGMediaViewController
    {
        let bundle = NSBundle(forClass: TGCameraViewController.self)
        let viewController: TGMediaViewController = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        viewController.delegate = delegate
        viewController.videoURL = videoURL
        viewController.isVideo = true
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        detailFilterView = UIView()
        
        if CGRectGetHeight(UIScreen.mainScreen().bounds) <= 480 {
            self.topViewHeight.constant = 0
        }
        self.photoView.clipsToBounds = true
        
        if isVideo == false
        {
            self.photoView.image = photo
        }
        
        else
        {
            videoPlayer = TGPlayer()
            videoPlayer.playerView.frame = CGRectMake(photoView.frame.origin.x, photoView.frame.origin.y, 414, 414)//photoView.frame
            videoPlayer.setURL(videoURL)
            videoPlayer.delegate = self
            view.addSubview(videoPlayer.playerView)
            videoPlayer.playbackLoops = true
            videoPlayer.playFromBeginning()
            
        }
        
        cancelButton.setImage(UIImage(named: "CameraBack")!, forState: .Normal)
        confirmButton.setImage(UIImage(named: "CameraShot")!, forState: .Normal)
        if TGCamera.filterButtonHidden == true || isVideo == true{
            self.filterWandButton.hidden = true
        }
        self.addDetailViewToButton(defaultFilterButton)

    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isVideo == true {
            videoPlayer.pause()
            videoPlayer.muted = true
            videoPlayer.delegate = nil
            videoPlayer.clearAsset()
            videoPlayer.playerView.removeFromSuperview()
            videoPlayer = nil
        }
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    @IBAction func backTapped() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmTapped() {
        delegate.cameraWillTakePhoto!()
        
        
        if photoView != nil && isVideo == false
        {
            photo = photoView.image
            
            if albumPhoto != nil
            {
                delegate.cameraDidSelectAlbumPhoto(photo)
            }
            
            else
            {
                delegate.cameraDidTakePhoto(photo)
            }
            
            
            if #available(iOS 8.0, *) {
                let library = TGAssetsLibrary()
                let status = PHPhotoLibrary.authorizationStatus()
                
                if TGCamera.saveMediaToAlbum == true && status != PHAuthorizationStatus.Denied
                {
                    library.saveImage(photo, resultBlock: { (assetURL) in
                        self.delegate.cameraDidSavePhotoAtPath!(assetURL)
                        }, failureBlock: { (error) in
                            self.delegate.cameraDidSavePhotoWithError!(error!)
                    })
                }
                
                else
                {
                    library.saveJPGImageAtDocumentDirectory(photo, resultBlock: {
                            (assetURL: NSURL?) in
                            self.delegate.cameraDidSavePhotoAtPath!(assetURL!)
                            }, failureBlock: { (error) in
                                self.delegate.cameraDidSavePhotoWithError!(error!)
                    })
                    
                    delegate.cameraDidSavePhotoAtPath!(nil)
                    
                }
            } else {
                // Fallback on earlier versions
                print("Can't save to directory")
            }
            
        }
        
        else
        {
            if #available(iOS 8.0, *) {
                let library = TGAssetsLibrary()
                let status = PHPhotoLibrary.authorizationStatus()
                if TGCamera.saveMediaToAlbum == true && status != .Denied
                {
                    library.saveVideo(videoURL, resultBlock: {_ in
                        self.delegate.cameraDidRecordVideo(self.videoURL)
                        }, failureBlock: {(error) in
                        print("Could not save video to album: \(error!.description)")
                    })
                }
            } else {
                // Fallback on earlier versions
                print("This version is not supported")
            }
        }
    }
    
    @IBAction func filtersTapped() {
        if filterView.isDescendantOfView(self.view!) {
            filterView.removeFromSuperviewAnimated()
        }
        else {
            filterView.addToView(self.view!, aboveView: bottomView)
            self.view!.sendSubviewToBack(filterView)
            self.view!.sendSubviewToBack(photoView)
        }

    }
    
    // MARK: Filter view actions
    
    @IBAction func defaultFilterTapped(button: UIButton) {
        self.addDetailViewToButton(button)
        self.photoView.image = photo
    }
    
    @IBAction func satureFilterTapped(button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto[kTGCacheSatureKey] != nil) {
            self.photoView.image = (cachePhoto[kTGCacheSatureKey] as! UIImage)
        }
        else {
            cachePhoto[kTGCacheSatureKey] = photo.saturateImage(1.8, withContrast: 1)
            self.photoView.image = (cachePhoto[kTGCacheSatureKey] as! UIImage)
        }

    }
    
    @IBAction func curveFilterTapped(button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto[kTGCacheCurveKey] != nil) {
            self.photoView.image = (cachePhoto[kTGCacheCurveKey] as! UIImage)
        }
        else {
            cachePhoto[kTGCacheCurveKey] = photo.curveFilter()
            self.photoView.image = (cachePhoto[kTGCacheCurveKey] as! UIImage)
        }

    }
    
    @IBAction func vignetteFilterTapped(button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto[kTGCacheVignetteKey] != nil) {
            self.photoView.image = (cachePhoto[kTGCacheVignetteKey] as! UIImage)
        }
        else {
            cachePhoto[kTGCacheVignetteKey] = photo.vignetteWithRadius(0, intensity: 6)
            self.photoView.image = (cachePhoto[kTGCacheVignetteKey] as! UIImage)
        }
    }
    
    // MARK: Video Player delegate
    
    public func playerReady(player: TGPlayer)
    {
        
    }
    public func playerPlaybackStateDidChange(player: TGPlayer)
    {
        
    }
    public func playerBufferingStateDidChange(player: TGPlayer)
    {
        
    }
    
    public func playerPlaybackWillStartFromBeginning(player: TGPlayer)
    {
        
    }
    public func playerPlaybackDidEnd(player: TGPlayer)
    {
        
    }
    
    public func playerDidReachHalfWayPoint()
    {
        
    }
    
    // MARK: Private methods
    
    func addDetailViewToButton(button: UIButton) {
        detailFilterView.removeFromSuperview()
        let height: CGFloat = 2.5
        var frame: CGRect = button.frame
        frame.size.height = height
        frame.origin.x = 0
        frame.origin.y = CGRectGetMaxY(button.frame) - height
        self.detailFilterView = UIView(frame: frame)
        self.detailFilterView.backgroundColor = TGCameraColor.tintColor()
        self.detailFilterView.userInteractionEnabled = false
        button.addSubview(detailFilterView)

    }
    
    
}

extension NSCache {
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return objectForKey(key)
        }
        set {
            if let value: AnyObject = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}