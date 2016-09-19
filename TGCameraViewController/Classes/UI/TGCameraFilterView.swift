//
//  TGCameraFilterView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraFilterView: UIView {
    
    public convenience init() {
        self.init()
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    open func addToView(_ view: UIView, aboveView: UIView) {
        var frame: CGRect = self.frame
        frame.origin.y = view.frame.maxY - aboveView.frame.height
        self.frame = frame
        view.addSubview(self)
        frame.origin.y -= self.frame.height
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.frame = frame
            }, completion: {(finished: Bool) -> Void in
        })

    }
    
    open func removeFromSuperviewAnimated() {
        var frame: CGRect = self.frame
        frame.origin.y += self.frame.height
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.frame = frame
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
        })

    }
    
    // MARK: - Private methods
    
    
    func setup() {
        var frame: CGRect = self.frame
        frame.size.width = UIScreen.main.applicationFrame.width
        self.frame = frame
    }
}
