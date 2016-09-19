//
//  TGCameraFocusView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

let TGCameraFocusSize: CGFloat = 50

open class TGCameraFocusView: UIView {
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.contentMode = .scaleToFill
    
        //
        // create view and subview to focus
        //
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: TGCameraFocusSize, height: TGCameraFocusSize))
        let subview: UIView = UIView(frame: CGRect(x: 0, y: 0, width: TGCameraFocusSize - 20, height: TGCameraFocusSize - 20))
        view.tag = -1
        subview.tag = -1
        view.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        subview.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        view.layer.borderColor = TGCameraColor.tintColor().cgColor
        subview.layer.borderColor = TGCameraColor.tintColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = view.frame.height / 2
        subview.layer.borderWidth = 5
        subview.layer.cornerRadius = subview.frame.height / 2
        
        //
        // add focus view and focus subview to touch viiew
        //
        self.addSubview(view)
        self.addSubview(subview)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Animation Method
    
    open func startAnimation() {
        self.layer.removeAllAnimations()
        self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {() -> Void in
            self.transform = CGAffineTransform.identity
            self.alpha = 1
            }, completion: {(finished: Bool) -> Void in
                UIView.animate(withDuration: 0.4, delay: 0, options: [.curveLinear, .autoreverse, .repeat], animations: {() -> Void in
                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.alpha = 1
                    }, completion: {(finished1: Bool) -> Void in
                })
        })
    }
    
    open func stopAnimation() {
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.alpha = 0
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
        })
    }
}
