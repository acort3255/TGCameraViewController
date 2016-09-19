//
//  TGCameraFunctions.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation

open class TGCameraFunctions: NSObject
{
    static var bundle: Bundle?
    private static var __once: () = {
            let path = Bundle(for: TGCameraViewController.self).path(forResource: "TGCameraViewController", ofType: "bundle")!
            //print(path)
            bundle = Bundle(path: path)
        }()
    open static func TGLocalizedString(_ key: String) -> String
    {
        _ = self.__once
        
        return (bundle?.localizedString(forKey: key, value: key, table: nil))!
    }
}
