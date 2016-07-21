//
//  TGCameraSlideView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGCameraSlideView: UIView, TGCameraSlideViewProtocol {
    
    let kExceptionName: String = "TGCameraSlideViewException"
    let kExceptionMessage: String = "Invoked abstract method"
    
    public static func showSlideUpView(slideUpView: TGCameraSlideView, slideDownView: TGCameraSlideView, atView view: UIView, completion: () -> Void) {
        slideUpView.addSlideToView(view, withOriginY: slideUpView.finalPosition())
        slideDownView.addSlideToView(view, withOriginY: slideDownView.finalPosition())
        slideUpView.removeSlideFromSuperview(false, withDuration: 0.15, originY: slideUpView.initialPositionWithView(view), completion: { _ in })
        slideDownView.removeSlideFromSuperview(false, withDuration: 0.15, originY: slideDownView.initialPositionWithView(view), completion: completion)
    }
    
    public static func hideSlideUpView(slideUpView: TGCameraSlideView, slideDownView: TGCameraSlideView, atView view: UIView, completion: () -> Void) {
        slideUpView.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: { _ in })
        slideDownView.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: completion)
    }
    
    func showWithAnimationAtView(view: UIView, completion: () -> Void) {
        self.addSlideToView(view, withOriginY: self.finalPosition())
        self.removeSlideFromSuperview(false, withDuration: 0.15, originY: self.initialPositionWithView(view), completion: completion)
    }
    
    func hideWithAnimationAtView(view: UIView, completion: () -> Void) {
        self.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: completion)
    }
    
    // MARK: - TGCameraSlideViewProtocol
    
    
    public func initialPositionWithView(view: UIView) -> CGFloat {
        NSException.raise(kExceptionName, format: kExceptionMessage, arguments: CVaListPointer.init(_fromUnsafeMutablePointer: nil))
        
        return 0.0
    }
    
    public func finalPosition() -> CGFloat {
        NSException.raise(kExceptionName, format: kExceptionMessage, arguments: CVaListPointer.init(_fromUnsafeMutablePointer: nil))
        return 0.0
    }
    
    // MARK: Private
    
    
    func addSlideToView(view: UIView, withOriginY originY: CGFloat) {
        let width: CGFloat = CGRectGetWidth(view.frame)
        let height: CGFloat = CGRectGetHeight(view.frame) / 2
        var frame: CGRect = self.frame
        frame.size.width = width
        frame.size.height = height
        frame.origin.y = originY
        self.frame = frame
        view.addSubview(self)

    }
    
    func hideWithAnimationAtView(view: UIView, withTimeInterval timeInterval: CGFloat, completion: () -> Void) {
        self.addSlideToView(view, withOriginY: self.initialPositionWithView(view))
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {() -> Void in
            NSThread.sleepForTimeInterval(Double(timeInterval))
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                self.removeSlideFromSuperview(true, withDuration: 0.5, originY: self.finalPosition(), completion: completion)
            })
        })

    }
    
    func removeSlideFromSuperview(remove: Bool, withDuration duration: CGFloat, originY: CGFloat, completion: () -> Void) {
        
        var frame: CGRect = self.frame
        frame.origin.y = originY
        UIView.animateWithDuration(Double(duration), animations: {() -> Void in
            self.frame = frame
            }, completion: {(finished: Bool) -> Void in
                if finished {
                    if remove {
                        self.removeFromSuperview()
                    }
                    completion()
                }
        })

    }
}