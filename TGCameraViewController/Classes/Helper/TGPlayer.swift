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
    case stopped = 0
    case playing
    case paused
    case failed
    
    public var description: String
        {
        get
        {
            switch self
            {
            case .stopped:
                return "Stopped"
            case .playing:
                return "Playing"
            case .failed:
                return "Failed"
            case .paused:
                return "Paused"
            }
            
        }
    }
}

public enum BufferingState: Int, CustomStringConvertible
{
    case unknown = 0
    case ready
    case delayed
    
    public var description: String
        {
        get
        {
            switch self {
            case .unknown:
                return "Unknown"
            case .ready:
                return "Ready"
            case .delayed:
                return "Delayed"
            }
        }
    }
}

public protocol PlayerDelegate: class
{
    func playerReady(_ player: TGPlayer)
    func playerPlaybackStateDidChange(_ player: TGPlayer)
    func playerBufferingStateDidChange(_ player: TGPlayer)
    
    func playerPlaybackWillStartFromBeginning(_ player: TGPlayer)
    func playerPlaybackDidEnd(_ player: TGPlayer)
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

open class TGPlayer: NSObject, URLSessionDownloadDelegate
{
    open weak var delegate: PlayerDelegate!
    fileprivate var mTimeObserver: AnyObject?
    fileprivate weak var weakSelf: TGPlayer?
    fileprivate var passedHalfWayTime: Bool?
    open func setURL(_ url: URL)
    {
        
        // Make sure everthing is reset beforehand
        if(self.playbackState == .playing && self.playbackState != nil)
        {
            self.pause()
        }
        
        self.setupPlayerItem(nil)
        var videoAsset: AVAsset?
        if VideoCacheManager.sharedVideoCache.object(forKey: url.absoluteString as AnyObject) == nil
        {
            videoAsset = AVAsset(url: url)
            
            VideoCacheManager.sharedVideoCache.setObject(videoAsset!, forKey: url.absoluteString as AnyObject)
        }
        
        else
        {
            videoAsset = VideoCacheManager.sharedVideoCache.object(forKey: url.absoluteString as AnyObject) as? AVAsset
        }
        
        self.setupAsset(VideoCacheManager.sharedVideoCache.object(forKey: url.absoluteString as AnyObject) as! AVAsset)
    }
    
    open func clearAsset()
    {
        self.asset = nil
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        
    }
    
    open var muted: Bool!
        {
        get
        {
            return self.player.isMuted
        }
        
        set
        {
            self.player.isMuted = newValue
        }
    }
    
    open var fillMode: String!
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
    
    open var playbackLoops: Bool!
        {
        get
        {
            return (self.player.actionAtItemEnd == .none) as Bool
        }
        
        set
        {
            if newValue != nil
            {
                self.player.actionAtItemEnd = .none
            }
                
            else
            {
                self.player.actionAtItemEnd = .pause
            }
        }
    }
    
    open var playbackFreezesAtEnd: Bool!
    open var playbackState: PlaybackState!
    open var bufferingState: BufferingState!
    
    open var maximumDuration: TimeInterval!
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
    
    open var currentTime: TimeInterval!
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
    
    open var naturalSize: CGSize!
        {
        get
        {
            if let playerItem = self.playerItem
            {
                let track = playerItem.asset.tracks(withMediaType: AVMediaTypeVideo)[0]
                return track.naturalSize
            }
                
            else
            {
                return CGSize.zero
            }
        }
    }
    
    fileprivate var asset: AVAsset!
    fileprivate var playerItem: AVPlayerItem?
    
    fileprivate var player: AVPlayer!
    open var playerView: PlayerView!
    
    // MARK: object lifecycle
    
    override public init()
    {
        super.init()
        
        weakSelf = self
        self.setupPlayer()
        
        self.player = AVPlayer()
        self.player.actionAtItemEnd = .pause
        self.player.addObserver(self, forKeyPath: PlayerRateKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerObserverContext)
        
        // Setup Activity View for loading icon on video player
        
        self.playbackLoops = false
        self.playbackFreezesAtEnd = false
        self.playbackState = .stopped
        self.bufferingState = .unknown
    }
    
    deinit
    {
        self.playerView?.player = nil
        self.delegate = nil
        
        NotificationCenter.default.removeObserver(self)
        
        self.playerView?.layer.removeObserver(self, forKeyPath: PlayerReadyForDisplay, context: &PlayerLayerObserverContext)
        self.player.removeObserver(self, forKeyPath: PlayerRateKey, context: &PlayerObserverContext)
        
        self.player.pause()
        
        self.setupPlayerItem(nil)
    }
    
    // MARK: methods
    
    open func playFromBeginning()
    {
        self.delegate?.playerPlaybackWillStartFromBeginning(self)
        self.player.seek(to: kCMTimeZero)
        self.player.play()
        passedHalfWayTime = false
    }
    
    open func playFromCurrentTime()
    {
        self.playbackState = .playing
        self.delegate?.playerPlaybackStateDidChange(self)
        self.player.play()
    }
    
    open func pause()
    {
        if self.playbackState != .playing
        {
            self.player.pause()
            self.playbackState = .paused
            self.delegate?.playerPlaybackStateDidChange(self)
        }
    }
    
    open func stop()
    {
        if self.playbackState != .stopped
        {
            self.player.pause()
            self.playbackState = .stopped
            self.delegate?.playerPlaybackStateDidChange(self)
            self.delegate?.playerPlaybackDidEnd(self)
        }
    }
    
    open func seetToTime(_ time: CMTime)
    {
        if let playerItem = self.playerItem
        {
            playerItem.seek(to: time)
        }
    }
    
    // MARK: private setup
    
    fileprivate func setupAsset(_ asset: AVAsset)
    {
        if self.playbackState == .playing
        {
            self.pause()
        }
        
        self.bufferingState = .unknown
        self.delegate?.playerBufferingStateDidChange(self)
        
        self.asset = asset
        if let _ = self.asset
        {
            self.setupPlayerItem(nil)
        }
        
        let keys: [String] = [PlayerTrackKey, PlayerPlayableKey, PlayerDurationKey]
        
        let backgroundQueue: DispatchQueue = DispatchQueue(label: "com.thisApp.setupAsset.bgqueue", attributes: [])
        
        self.asset.loadValuesAsynchronously(forKeys: keys) {
            backgroundQueue.sync(execute: {
                for key in keys
                {
                    var error: NSError?
                    let status = self.asset.statusOfValue(forKey: key, error: &error)
                    if status == .failed
                    {
                        self.playbackState = .failed
                        self.delegate?.playerPlaybackStateDidChange(self)
                        return
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    if self.asset.isPlayable == false
                    {
                        self.playbackState = .failed
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
    
    fileprivate func setupPlayerItem(_ playerItem: AVPlayerItem?)
    {
        if self.playerItem != nil
        {
            self.playerItem?.removeObserver(self, forKeyPath: PlayerEmptyBufferKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerKeepUp, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerStatusKey, context: &PlayerItemObserverContext)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.playerItem)
        }
        
        self.playerItem = playerItem
        
        if self.playerItem != nil
        {
            self.playerItem?.addObserver(self, forKeyPath: PlayerEmptyBufferKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerKeepUp, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            self.playerItem?.addObserver(self, forKeyPath: PlayerStatusKey, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerItemObserverContext)
            mTimeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: nil, using: {_ in
                self.weakSelf?.reachedHalfWayPoint()
            }) as AnyObject?
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.playerItem)
            
            self.player.replaceCurrentItem(with: self.playerItem)
            
            if self.playbackLoops == true
            {
                self.player.actionAtItemEnd = .none
            }
                
            else
            {
                self.player.actionAtItemEnd = .pause
            }
            
        }
        
    }
    
    fileprivate func setupPlayer()
    {
        passedHalfWayTime = false
        self.playerView = PlayerView(frame: CGRect.zero)
        self.playerView.fillMode = AVLayerVideoGravityResizeAspect
        self.playerView.playerLayer.isHidden = true
        self.playerView.layer.addObserver(self, forKeyPath: PlayerReadyForDisplay, options: ([NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old]), context: &PlayerLayerObserverContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
    }
    
    // MARK: NSNotifications
    
    open func playerItemDidPlayToEndTime(_ aNotification: Notification)
    {
        if self.playbackLoops == true || self.playbackFreezesAtEnd == true
        {
            self.player.seek(to: kCMTimeZero)
            passedHalfWayTime = false
        }
        
        if self.playbackLoops == false
        {
            self.stop()
        }
    }
    
    open func playerItemFailedToPlayToEndTime(_ aNotification: Notification)
    {
        self.playbackState = .failed
        self.delegate?.playerPlaybackStateDidChange(self)
    }
    
    open func applicationWillResignActive(_ aNotificaiton: Notification)
    {
        if self.playbackState == .playing
        {
            self.pause()
        }
    }
    
    open func applicationDidEnterBackground(_ aNotification: Notification)
    {
        if self.playbackState == .playing
        {
            self.pause()
        }
    }
    
    open func applicationWillEnterForeground(_ aNotificaiton: Notification)
    {
        if self.playbackState == .paused
        {
            self.player.play()
        }
    }
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // This needs to changed to a if statements
        if context == &PlayerItemObserverContext
        {
            if keyPath == PlayerRateKey{
                true
            }
            
            else if keyPath == PlayerStatusKey{
                true
            }
            
            else if keyPath == PlayerKeepUp{
                if let item = self.playerItem
                {
                    self.bufferingState = .ready
                    self.delegate?.playerBufferingStateDidChange(self)
                    
                    if item.isPlaybackLikelyToKeepUp && self.playbackState == .playing
                    {
                        self.playFromCurrentTime()
                    }
                }
                
                let status = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).intValue as AVPlayerStatus.RawValue
                
                switch status {
                case AVPlayerStatus.readyToPlay.rawValue:
                    self.playerView.playerLayer.player = self.player
                    self.playerView.playerLayer.isHidden = false
                case AVPlayerStatus.failed.rawValue:
                    self.playbackState = PlaybackState.failed
                    self.delegate?.playerPlaybackStateDidChange(self)
                default:
                    break
                }
            }
            
            else if keyPath == PlayerEmptyBufferKey{
                if let item = self.playerItem
                {
                    if item.isPlaybackBufferEmpty
                    {
                        self.bufferingState = .delayed
                        self.delegate?.playerBufferingStateDidChange(self)
                    }
                }
                
                let status = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).intValue as AVPlayerStatus.RawValue
                
                switch status {
                case AVPlayerStatus.readyToPlay.rawValue:
                    self.playerView.playerLayer.player = self.player
                    self.playerView.playerLayer.isHidden = false
                case AVPlayerStatus.failed.rawValue:
                    self.playbackState = PlaybackState.failed
                    self.delegate?.playerPlaybackStateDidChange(self)
                default:
                    break
                }
            }
        }
        
        else if context == &PlayerLayerObserverContext
        {
            if keyPath == PlayerReadyForDisplay{
                if self.playerView.playerLayer.isReadyForDisplay
                {
                    self.delegate?.playerReady(self)
                }
            }
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

open class PlayerView: UIView
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
    
    override open class var layerClass : AnyClass
    {
        return AVPlayerLayer.self
    }
    
    // MARK: object lifecycle
    
    public convenience init()
    {
        self.init(frame: CGRect.zero)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
