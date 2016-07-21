//
//  TGCameraFocusView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

let TGCameraFocusSize: CGFloat = 50

class TGCameraFocusView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .ScaleToFill
    
        //
        // create view and subview to focus
        //
        let view: UIView = UIView(frame: CGRectMake(0, 0, TGCameraFocusSize, TGCameraFocusSize))
        let subview: UIView = UIView(frame: CGRectMake(0, 0, TGCameraFocusSize - 20, TGCameraFocusSize - 20))
        view.tag = -1
        subview.tag = -1
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        subview.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        view.layer.borderColor = TGCameraColor.tintColor().CGColor
        subview.layer.borderColor = TGCameraColor.tintColor().CGColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = CGRectGetHeight(view.frame) / 2
        subview.layer.borderWidth = 5
        subview.layer.cornerRadius = CGRectGetHeight(subview.frame) / 2
        
        //
        // add focus view and focus subview to touch viiew
        //
        self.addSubview(view)
        self.addSubview(subview)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Animation Method
    
    func startAnimation() {
        self.layer.removeAllAnimations()
        self.transform = CGAffineTransformMakeScale(1.5, 1.5)
        self.alpha = 0
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {() -> Void in
            self.transform = CGAffineTransformIdentity
            self.alpha = 1
            }, completion: {(finished: Bool) -> Void in
                UIView.animateWithDuration(0.4, delay: 0, options: [.CurveLinear, .Autoreverse, .Repeat], animations: {() -> Void in
                    self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    self.alpha = 1
                    }, completion: {(finished1: Bool) -> Void in
                })
        })
    }
    
    func stopAnimation() {
        self.layer.removeAllAnimations()
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {() -> Void in
            self.transform = CGAffineTransformMakeScale(0.001, 0.001)
            self.alpha = 0
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
        })
    }
}