//
//  TGCameraFunctions.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation

public class TGCameraFunctions: NSObject
{
    public static func TGLocalizedString(key: String) -> String
    {
        var bundle: NSBundle?
        var token: dispatch_once_t = 0
        
        dispatch_once(&token,{
            let path = NSBundle.mainBundle().pathForResource("TGCameraViewController", ofType: "bundle")!
            bundle = NSBundle(path: path)
        })
        
        return (bundle?.localizedStringForKey(key, value: key, table: nil))!
    }
}