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


open class TGMediaViewController: UIViewController, PlayerDelegate
{
    
    
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var filterView: TGCameraFilterView!
    @IBOutlet var defaultFilterButton: UIButton!
    @IBOutlet weak var filterWandButton: TGTintedButton!
    @IBOutlet weak var cancelButton: TGTintedButton!
    @IBOutlet weak var confirmButton: TGTintedButton!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    open var delegate: TGCameraDelegate!
    var detailFilterView: UIView!
    var photo: UIImage!
    var videoURL: URL!
    var cachePhoto: NSCache<NSString, AnyObject>!
    var isVideo: Bool = false
    var videoPlayer: TGPlayer!
    open var albumPhoto: Bool!
    
    
    /*public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }*/
    
    open func newWithDelegateAndPhoto(_ delegate: TGCameraDelegate, photo: UIImage) -> TGMediaViewController
    {
        let bundle = Bundle(for: TGCameraViewController.self)
        let viewController: TGMediaViewController = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        viewController.delegate = delegate
        viewController.photo = photo
        viewController.cachePhoto = NSCache()
        return viewController

    }
    
    open func newWithDelegateAndVideo(_ delegate: TGCameraDelegate, videoURL: URL) -> TGMediaViewController
    {
        let bundle = Bundle(for: TGCameraViewController.self)
        let viewController: TGMediaViewController = TGMediaViewController(nibName: "TGMediaViewController", bundle: bundle)
        viewController.delegate = delegate
        viewController.videoURL = videoURL
        viewController.isVideo = true
        return viewController
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        detailFilterView = UIView()
        
        if UIScreen.main.bounds.height <= 480 {
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
            videoPlayer.playerView.frame = CGRect(x: photoView.frame.origin.x, y: photoView.frame.origin.y, width: 414, height: 414)//photoView.frame
            videoPlayer.setURL(videoURL)
            
            // Scaffolding for Swift 3.0 migration
            videoPlayer.muted =  true
           
            videoPlayer.playerView.contentMode = UIViewContentMode.scaleAspectFill
            videoPlayer.delegate = self
            view.addSubview(videoPlayer.playerView)
            videoPlayer.playbackLoops = true
            videoPlayer.playFromBeginning()
            
        }
        
        cancelButton.setImage(UIImage(named: "CameraBack")!, for: UIControlState())
        confirmButton.setImage(UIImage(named: "CameraShot")!, for: UIControlState())
        if TGCamera.filterButtonHidden == true || isVideo == true{
            self.filterWandButton.isHidden = true
        }
        self.addDetailViewToButton(defaultFilterButton)

    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isVideo == true
        {
            videoPlayer.muted = false
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isVideo == true {
            videoPlayer.muted = true
        }
    }
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    @IBAction func backTapped() {
        
        if isVideo == true {
            videoPlayer.pause()
            videoPlayer.muted = true
            //videoPlayer.delegate = nil
            videoPlayer.clearAsset()
            //videoPlayer.playerView.removeFromSuperview()
            //videoPlayer = nil
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func confirmTapped() {
        if TGCamera.saveMediaToAlbum == true { 
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
            
            let library = TGAssetsLibrary()
            let status = PHPhotoLibrary.authorizationStatus()
            
                if status != PHAuthorizationStatus.denied
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
                        (assetURL: URL?) in
                        self.delegate.cameraDidSavePhotoAtPath!(assetURL!)
                        }, failureBlock: { (error) in
                            self.delegate.cameraDidSavePhotoWithError!(error!)
                    })
                
                    delegate.cameraDidSavePhotoAtPath!(nil)
                
                }
           
            }
        
            else
            {
                let library = TGAssetsLibrary()
                let status = PHPhotoLibrary.authorizationStatus()
                if status != .denied
                {
                    library.saveVideo(videoURL, resultBlock: {_ in
                    self.delegate.cameraDidRecordVideo(self.videoURL)
                    }, failureBlock: {(error) in
                        print("Could not save video to album: \(error!.description)")
                })
            }
            
          }
        }
        
        else
        {
            if isVideo == false
            {
                delegate.cameraDidTakePhoto(photo)
            }
            
            else
            {
                delegate.cameraDidRecordVideo(self.videoURL)
            }
        }
    }
    
    @IBAction func filtersTapped() {
        if filterView.isDescendant(of: self.view!) {
            filterView.removeFromSuperviewAnimated()
        }
        else {
            filterView.addToView(self.view!, aboveView: bottomView)
            self.view!.sendSubview(toBack: filterView)
            self.view!.sendSubview(toBack: photoView)
        }

    }
    
    // MARK: Filter view actions
    
    @IBAction func defaultFilterTapped(_ button: UIButton) {
        self.addDetailViewToButton(button)
        self.photoView.image = photo
    }
    
    @IBAction func satureFilterTapped(_ button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto.object(forKey: kTGCacheSatureKey as NSString) != nil) {
            self.photoView.image = (cachePhoto.object(forKey: (kTGCacheSatureKey as NSString)) as! UIImage)
        }
        else {
            cachePhoto.setObject(photo.saturateImage(1.8, withContrast: 1), forKey: kTGCacheSatureKey as NSString)
            self.photoView.image = (cachePhoto.object(forKey: kTGCacheSatureKey as NSString) as! UIImage)
        }

    }
    
    @IBAction func curveFilterTapped(_ button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto.object(forKey:kTGCacheCurveKey as NSString) != nil) {
            self.photoView.image = (cachePhoto.object(forKey: kTGCacheCurveKey as NSString) as! UIImage)
        }
        else {
            //cachePhoto[kTGCacheCurveKey] = photo.curveFilter()
            cachePhoto.setObject(photo.curveFilter(), forKey: kTGCacheCurveKey as NSString)
            self.photoView.image = (cachePhoto.object(forKey: kTGCacheCurveKey as NSString) as! UIImage)
        }

    }
    
    @IBAction func vignetteFilterTapped(_ button: UIButton) {
        self.addDetailViewToButton(button)
        if (cachePhoto.object(forKey: kTGCacheVignetteKey as NSString) != nil) {
            self.photoView.image = (cachePhoto.object(forKey: kTGCacheVignetteKey as NSString) as! UIImage)
        }
        else {
            //cachePhoto[kTGCacheVignetteKey] = photo.vignetteWithRadius(0, intensity: 6)
            cachePhoto.setObject(photo.vignetteWithRadius(0, intensity: 6), forKey: kTGCacheVignetteKey as NSString)
            self.photoView.image = (cachePhoto.object(forKey: kTGCacheVignetteKey as NSString) as! UIImage)
        }
    }
    
    // MARK: Video Player delegate
    
    open func playerReady(_ player: TGPlayer)
    {
        
    }
    open func playerPlaybackStateDidChange(_ player: TGPlayer)
    {
        
    }
    open func playerBufferingStateDidChange(_ player: TGPlayer)
    {
        
    }
    
    open func playerPlaybackWillStartFromBeginning(_ player: TGPlayer)
    {
        
    }
    open func playerPlaybackDidEnd(_ player: TGPlayer)
    {
        
    }
    
    open func playerDidReachHalfWayPoint()
    {
        
    }
    
    // MARK: Private methods
    
    func addDetailViewToButton(_ button: UIButton) {
        detailFilterView.removeFromSuperview()
        let height: CGFloat = 2.5
        var frame: CGRect = button.frame
        frame.size.height = height
        frame.origin.x = 0
        frame.origin.y = button.frame.maxY - height
        self.detailFilterView = UIView(frame: frame)
        self.detailFilterView.backgroundColor = TGCameraColor.tintColor()
        self.detailFilterView.isUserInteractionEnabled = false
        button.addSubview(detailFilterView)

    }
    
    
}
/*
extension NSCache {
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return object(forKey: key as! KeyType)
        }
        set {
            if let value: AnyObject = newValue {
                setObject(value as! ObjectType, forKey: key as! KeyType)
            } else {
                removeObject(forKey: key as! KeyType)
            }
        }
    }
}
*/
