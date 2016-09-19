//
//  TGTintedLabel.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

class TGTintedLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateTintIfNeeded()
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        self.updateTintIfNeeded()
    }
    
    fileprivate  func updateTintIfNeeded() {
        if self.tintColor != TGCameraColor.tintColor() || self.textColor != self.tintColor {
            self.tintColor = TGCameraColor.tintColor()
            self.textColor = self.tintColor
        }
    }
}
