//
//  TGVideoCacheManager.swift
//  Liveflyr-Swift
//
//  Created by Angel Cortez on 5/24/16.
//  Copyright © 2016 LiveFlyr. All rights reserved.
//

import Foundation

class VideoCacheManager: NSObject
{
    static let sharedVideoCache = NSCache<AnyObject, AnyObject>()
}
