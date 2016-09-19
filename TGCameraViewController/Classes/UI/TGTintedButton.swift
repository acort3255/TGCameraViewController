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
    
    override open func setBackgroundImage(_ image: UIImage?, for state: UIControlState) {
        if state != .normal{
            return
        }
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .alwaysOriginal : .alwaysTemplate
        super.setBackgroundImage(image!.withRenderingMode(renderingMode), for: state)
    }
    
    override open func setImage(_ image: UIImage?, for state: UIControlState) {
        if state != .normal {
           return
        }
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .alwaysOriginal : .alwaysTemplate
        super.setImage(image!.withRenderingMode(renderingMode), for: state)
        super.setImage(image!, for: state)
    }
    
    func updateTintIfNeeded() {
        let color: UIColor =  TGCameraColor.tintColor()
        let renderingMode: UIImageRenderingMode = (self.disableTint != nil) ? .alwaysOriginal : .alwaysTemplate
        if self.tintColor != color {
            self.tintColor = color
            let backgroundImage = self.backgroundImage(for: .normal)?.withRenderingMode(renderingMode)
            if backgroundImage != nil
            {
                self.setBackgroundImage(backgroundImage, for: .normal)
            }
            let image: UIImage? = self.image(for: .normal)!.withRenderingMode(renderingMode)
            if image != nil
            {
                self.setImage(image, for: .normal)
            }
        }
    }
    
    
}
