//
//  TGCameraFilterView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

class TGCameraFilterView: UIView {
    
    convenience init() {
        self.init()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    func addToView(view: UIView, aboveView: UIView) {
        var frame: CGRect = self.frame
        frame.origin.y = CGRectGetMaxY(view.frame) - CGRectGetHeight(aboveView.frame)
        self.frame = frame
        view.addSubview(self)
        frame.origin.y -= CGRectGetHeight(self.frame)
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            self.frame = frame
            }, completion: {(finished: Bool) -> Void in
        })

    }
    
    func removeFromSuperviewAnimated() {
        var frame: CGRect = self.frame
        frame.origin.y += CGRectGetHeight(self.frame)
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            self.frame = frame
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
        })

    }
    
    // MARK: - Private methods
    
    
    func setup() {
        var frame: CGRect = self.frame
        frame.size.width = CGRectGetWidth(UIScreen.mainScreen().applicationFrame)
        self.frame = frame
    }
}