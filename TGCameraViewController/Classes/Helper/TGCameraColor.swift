//
//  TGCameraColor.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraColor: UIColor {
    
    open static var staticTintColor: UIColor?
    
    open static func setTintColor(_ tintColor: UIColor) {
        staticTintColor = tintColor
    }
    
    override open static var gray: UIColor {
        let divisor: CGFloat = 255.0
        return UIColor(red: 200/divisor, green: 200/divisor, blue: 200/divisor, alpha: 1)
    }
    
    open static func tintColor() -> UIColor {
        let divisor: CGFloat = 255.0
        
        return staticTintColor != nil ? staticTintColor! : UIColor(red: 255.0/divisor, green: 91.0/divisor, blue: 1.0/divisor, alpha: 1.0)
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
