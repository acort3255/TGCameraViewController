//  TGPlayer.swift
//
//  Created by patrick piemonte on 11/26/14.
//  Modifed by Angel Cortez 1/15/16
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-present patrick piemonte (http://patrickpiemonte.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Foundation
import AVFoundation
import CoreGraphics


public enum PlaybackState: Int, CustomStringConvertible
{
    case Stopped = 0
    case Playing
    case Paused
    case Failed
    
    public var description: String
        {
        get
        {
            switch self
            {
            case .Stopped:
                return "Stopped"
            case .Playing:
                return "Playing"
            case .Failed:
                return "Failed"
            case .Paused:
                return "Paused"
            }
            
        }
    }
}

public enum BufferingState: Int, CustomStringConvertible
{
    case Unknown = 0
    case Ready
    case Delayed
    
    public var description: String
        {
        get
        {
            switch self {
            case .Unknown:
                return "Unknown"
            case .Ready:
                return "Ready"
            case .Delayed:
                return "Delayed"
            }
        }
    }
}

public protocol PlayerDelegate: class
{
    func playerReady(player: TGPlayer)
    func playerPlaybackStateDidChange(player: TGPlayer)
    func playerBufferingStateDidChange(player: TGPlayer)
    
    func playerPlaybackWillStartFromBeginning(player: TGPlayer)
    func playerPlaybackDidEnd(player: TGPlayer)
    func playerDidReachHalfWayPoint()
}

// KVO contexts

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

// KVO player keys

private let PlayerTrackKey = "tracks"
private let PlayerPlayableKey = "playable"
private let PlayerDurationKey = "duration"
private let PlayerRateKey = "rate"

// KVO player item keys

private let PlayerStatusKey = "status"
private let PlayerEmptyBufferKey = "playbackBufferEmpty"
private let PlayerKeepUp = "playbackLikelyToKeepUp"

// KVO player layer keys

private let PlayerReadyForDisplay = "readyForDisplay"

// MARK: - Player

public class TGPlayer: NSObject, NSURLSessionDownloadDelegate
{
    public weak var delegate: PlayerDelegate!
    private var mTimeObserver: AnyObject?
    private weak var weakSelf: TGPlayer?
    private var passedHalfWayTime: Bool?
    public func setURL(url: NSURL)
    {
        
        // Make sure everthing is reset beforehand
        if(self.playbackState == .Playing && self.playbackState != nil)
        {
            self.pause()
        }
        
        self.setupPlayerItem(nil)
        var videoAsset: AVAsset?
        if VideoCacheManager.sharedVideoCache.objectForKey(url.absoluteString) == nil
        {
            videoAsset = AVAsset(URL: url)
            
            VideoCacheManager.sharedVideoCache.setObject(videoAsset!, forKey: url.absoluteString)
        }
        
        else
        {
            videoAsset = VideoCacheManager.sharedVideoCache.objectForKey(url.absoluteString) as? AVAsset
        }
        
        self.setupAsset(VideoCacheManager.sharedVideoCache.objectForKey(url.absoluteString) as! AVAsset)
    }
    
    public func clearAsset()
    {
        self.asset = nil
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    {
        
    }
    
    public var muted: Bool!
        {
        get
        {
            return self.player.muted
        }
        
        set
        {
            self.player.muted = newValue
        }
    }
    
    public var fillMode: String!
        {
        get
        {
            return self.playerView.fillMode
        }
        
        set
        {
            return self.playerView.fillMode = newValue
        }
    }
    
    public var playbackLoops: Bool!
        {
        get
        {
            return (self.player.actionAtItemEnd == .None) as Bool
        }
        
        set
        {
            if newValue.boolValue
            {
                self.player.actionAtItemEnd = .None
            }
                
            else
            {
                self.player.actionAtItemEnd = .Pause
            }
        }
    }
    
    public var playbackFreezesAtEnd: Bool!
    public var playbackState: PlaybackState!
    public var bufferingState: BufferingState!
    
    public var maximumDuration: NSTimeInterval!
        {
        get
        {
            if let playerItem = self.playerItem
            {
                return CMTimeGetSeconds(playerItem.currentTime())
            }
                
            else
            {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    public var currentTime: NSTimeInterval!
        {
        get
        {
            if let playerItem = self.playerItem
            {
                return CMTimeGetSeconds(playerItem.currentTime())
            }
                
            else
            {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    public var naturalSize: CGSize!
        {
        get
        {
            if let playerItem = self.playerItem
            {
                let track = playerItem.asset.tracksWithMediaType(AVMediaTypeVideo)[0]
                return track.naturalSize
            }
                
            else
            {
                return CGSizeZero
            }
        }
    }
    
    private var asset: AVAsset!
    private var playerItem: AVPlayerItem?
    
    private var player: AVPlayer!
    public var playerView: PlayerView!
    
    // MARK: object lifecycle
    
    override init()
    {
        super.init()
        
        weakSelf = self
        self.setupPlayer()
        
        self.player = AVPlayer()
        self.player.actionAtItemEnd = .Pause
        self.player.addObserver(self, forKeyPath: PlayerRateKey, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerObserverContext)
        
        // Setup Activity View for loading icon on video player
        
        self.playbackLoops = false
        self.playbackFreezesAtEnd = false
        self.playbackState = .Stopped
        self.bufferingState = .Unknown
    }
    
    deinit
    {
        self.playerView?.player = nil
        self.delegate = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.playerView?.layer.removeObserver(self, forKeyPath: PlayerReadyForDisplay, context: &PlayerLayerObserverContext)
        self.player.removeObserver(self, forKeyPath: PlayerRateKey, context: &PlayerObserverContext)
        
        self.player.pause()
        
        self.setupPlayerItem(nil)
    }
    
    // MARK: methods
    
    public func playFromBeginning()
    {
        self.delegate?.playerPlaybackWillStartFromBeginning(self)
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
        passedHalfWayTime = false
    }
    
    public func playFromCurrentTime()
    {
        self.playbackState = .Playing
        self.delegate?.playerPlaybackStateDidChange(self)
        self.player.play()
    }
    
    public func pause()
    {
        if self.playbackState != .Playing
        {
            self.player.pause()
            self.playbackState = .Paused
            self.delegate?.playerPlaybackStateDidChange(self)
        }
    }
    
    public func stop()
    {
        if self.playbackState != .Stopped
        {
            self.player.pause()
            self.playbackState = .Stopped
            self.delegate?.playerPlaybackStateDidChange(self)
            self.delegate?.playerPlaybackDidEnd(self)
        }
    }
    
    public func seetToTime(time: CMTime)
    {
        if let playerItem = self.playerItem
        {
            playerItem.seekToTime(time)
        }
    }
    
    // MARK: private setup
    
    private func setupAsset(asset: AVAsset)
    {
        if self.playbackState == .Playing
        {
            self.pause()
        }
        
        self.bufferingState = .Unknown
        self.delegate?.playerBufferingStateDidChange(self)
        
        self.asset = asset
        if let _ = self.asset
        {
            self.setupPlayerItem(nil)
        }
        
        let keys: [String] = [PlayerTrackKey, PlayerPlayableKey, PlayerDurationKey]
        
        let backgroundQueue: dispatch_queue_t = dispatch_queue_create("com.thisApp.setupAsset.bgqueue", nil)
        
        self.asset.loadValuesAsynchronouslyForKeys(keys) {
            dispatch_sync(backgroundQueue, {
                for key in keys
                {
                    var error: NSError?
                    let status = self.asset.statusOfValueForKey(key, error: &error)
                    if status == .Failed
                    {
                        self.playbackState = .Failed
                        self.delegate?.playerPlaybackStateDidChange(self)
                        return
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.asset.playable.boolValue == false
                    {
                        self.playbackState = .Failed
                        self.delegate?.playerPlaybackStateDidChange(self)
                    }
                        
                    else
                    {
                        let playerItem: AVPlayerItem = AVPlayerItem(asset: self.asset)
                        self.setupPlayerItem(playerItem)
                    }
                })
            })
        }
    }
    
    private func setupPlayerItem(playerItem: AVPlayerItem?)
    {
        if self.playerItem != nil
        {
            self.playerItem?.removeObserver(self, forKeyPath: PlayerEmptyBufferKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerKeepUp, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerStatusKey, context: &PlayerItemObserverContext)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.playerItem)
        }
        
        self.playerItem = playerItem
        
        if self.playerItem != nil
        {
            self.playerItem?.addObserver(self, forKeyPath: PlayerEmptyBufferKey, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerKeepUp, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerStatusKey, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerItemObserverContext)
            mTimeObserver = self.player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 1), queue: nil, usingBlock: {_ in
                self.weakSelf?.reachedHalfWayPoint()
            })
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.playerItem)
            
            self.player.replaceCurrentItemWithPlayerItem(self.playerItem)
            
            if self.playbackLoops.boolValue == true
            {
                self.player.actionAtItemEnd = .None
            }
                
            else
            {
                self.player.actionAtItemEnd = .Pause
            }
            
        }
        
    }
    
    private func setupPlayer()
    {
        passedHalfWayTime = false
        self.playerView = PlayerView(frame: CGRectZero)
        self.playerView.fillMode = AVLayerVideoGravityResizeAspect
        self.playerView.playerLayer.hidden = true
        self.playerView.layer.addObserver(self, forKeyPath: PlayerReadyForDisplay, options: ([NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old]), context: &PlayerLayerObserverContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        
    }
    
    // MARK: NSNotifications
    
    public func playerItemDidPlayToEndTime(aNotification: NSNotification)
    {
        if self.playbackLoops.boolValue == true || self.playbackFreezesAtEnd.boolValue == true
        {
            self.player.seekToTime(kCMTimeZero)
            passedHalfWayTime = false
        }
        
        if self.playbackLoops.boolValue == false
        {
            self.stop()
        }
    }
    
    public func playerItemFailedToPlayToEndTime(aNotification: NSNotification)
    {
        self.playbackState = .Failed
        self.delegate?.playerPlaybackStateDidChange(self)
    }
    
    public func applicationWillResignActive(aNotificaiton: NSNotification)
    {
        if self.playbackState == .Playing
        {
            self.pause()
        }
    }
    
    public func applicationDidEnterBackground(aNotification: NSNotification)
    {
        if self.playbackState == .Playing
        {
            self.pause()
        }
    }
    
    public func applicationWillEnterForeground(aNotificaiton: NSNotification)
    {
        if self.playbackState == .Paused
        {
            self.player.play()
        }
    }
    
    // MARK: KVO
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        switch (keyPath, context)
        {
        case (.Some(PlayerRateKey), &PlayerItemObserverContext):
            true
        case (.Some(PlayerStatusKey), &PlayerItemObserverContext):
            true
        case (.Some(PlayerKeepUp), &PlayerItemObserverContext):
            if let item = self.playerItem
            {
                self.bufferingState = .Ready
                self.delegate?.playerBufferingStateDidChange(self)
                
                if item.playbackLikelyToKeepUp && self.playbackState == .Playing
                {
                    self.playFromCurrentTime()
                }
            }
            
            let status = (change?[NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            
            switch status {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.playerView.playerLayer.player = self.player
                self.playerView.playerLayer.hidden = false
            case AVPlayerStatus.Failed.rawValue:
                self.playbackState = PlaybackState.Failed
                self.delegate?.playerPlaybackStateDidChange(self)
            default:
                true
            }
            
        case (.Some(PlayerEmptyBufferKey), &PlayerItemObserverContext):
            if let item = self.playerItem
            {
                if item.playbackBufferEmpty
                {
                    self.bufferingState = .Delayed
                    self.delegate?.playerBufferingStateDidChange(self)
                }
            }
            
            let status = (change?[NSKeyValueChangeNewKey] as! NSNumber).integerValue as AVPlayerStatus.RawValue
            
            switch status {
            case AVPlayerStatus.ReadyToPlay.rawValue:
                self.playerView.playerLayer.player = self.player
                self.playerView.playerLayer.hidden = false
            case AVPlayerStatus.Failed.rawValue:
                self.playbackState = PlaybackState.Failed
                self.delegate?.playerPlaybackStateDidChange(self)
            default:
                true
            }
            
        case (.Some(PlayerReadyForDisplay), &PlayerLayerObserverContext):
            if self.playerView.playerLayer.readyForDisplay
            {
                self.delegate?.playerReady(self)
            }
            default: break
            //super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func reachedHalfWayPoint()
    {
        let playerDuration = CMTimeGetSeconds((self.player.currentItem?.duration)!)
        let playerCurrentTime = CMTimeGetSeconds((self.player.currentItem?.currentTime())!)
        
        if playerCurrentTime >= playerDuration/2 && !passedHalfWayTime!
        {
            passedHalfWayTime = true
            self.delegate?.playerDidReachHalfWayPoint()
        }
    }
    
}

extension TGPlayer
{
    public func reset()
    {
        
    }
}

// MARK: - PlayerView

public class PlayerView: UIView
{
    var player: AVPlayer!
        {
        get
        {
            return (self.layer as! AVPlayerLayer).player
        }
        
        set
        {
            (self.layer as! AVPlayerLayer).player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer!
        {
        get
        {
            return self.layer as! AVPlayerLayer
        }
    }
    
    var fillMode: String!
        {
        get
        {
            return (self.layer as! AVPlayerLayer).videoGravity
        }
        
        set
        {
            (self.layer as! AVPlayerLayer).videoGravity = newValue
        }
    }
    
    override public class func layerClass() -> AnyClass
    {
        return AVPlayerLayer.self
    }
    
    // MARK: object lifecycle
    
    convenience init()
    {
        self.init(frame: CGRectZero)
        self.playerLayer.backgroundColor = UIColor.blackColor().CGColor
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.playerLayer.backgroundColor = UIColor.blackColor().CGColor
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}