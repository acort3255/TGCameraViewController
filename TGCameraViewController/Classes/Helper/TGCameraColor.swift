//
//  TGCameraColor.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGCameraColor: UIColor {
    
    public static var staticTintColor: UIColor?
    
    public static func setTintColor(tintColor: UIColor) {
        staticTintColor = tintColor
    }
    
    override public static func grayColor() -> UIColor {
        let divisor: CGFloat = 255.0
        return super.init(red: 200/divisor, green: 200/divisor, blue: 200/divisor, alpha: 1)
    }
    
    public static func tintColor() -> UIColor {
        let divisor: CGFloat = 255.0
        return staticTintColor != nil ? staticTintColor! : super.init(red: 255/divisor, green: 91/divisor, blue: 1/divisor, alpha: 1)
    }
    
    /*required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    /*
    required convenience public init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        super.init(red: red, green: green, blue: blue, alpha: 1)
        //fatalError("init(colorLiteralRed:green:blue:alpha:) has not been implemented")
    }*/
}