//
//  TGTintedButton.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGTintedButton: UIButton {
    var customTintColorOverride: UIColor!
    var disableTint: Bool!
    
    
    override public func setNeedsLayout() {
        super.setNeedsLayout()
        self.updateTintIfNeeded()
    }
    
    override public func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
        if state != .Normal{
            return
        }
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .AlwaysOriginal : .AlwaysTemplate
        super.setBackgroundImage(image!.imageWithRenderingMode(renderingMode), forState: state)
    }
    
    override public func setImage(image: UIImage?, forState state: UIControlState) {
        if state != .Normal {
           return
        }
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .AlwaysOriginal : .AlwaysTemplate
        super.setImage(image!.imageWithRenderingMode(renderingMode), forState: state)
    }
    
    func updateTintIfNeeded() {
        let color: UIColor =  TGCameraColor.tintColor()
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .AlwaysOriginal : .AlwaysTemplate
        if self.tintColor != color {
            self.tintColor = color
            let backgroundImage = self.backgroundImageForState(.Normal)?.imageWithRenderingMode(renderingMode)
            if backgroundImage != nil
            {
                self.setBackgroundImage(backgroundImage, forState: .Normal)
            }
            let image: UIImage? = self.imageForState(.Normal)!.imageWithRenderingMode(renderingMode)
            if image != nil
            {
                self.setImage(image, forState: .Normal)
            }
        }
    }
    
    
}
