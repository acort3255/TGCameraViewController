//
//  TGCameraSlideView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraSlideView: UIView, TGCameraSlideViewProtocol {
    
    let kExceptionName: String = "TGCameraSlideViewException"
    let kExceptionMessage: String = "Invoked abstract method"
    
    open static func showSlideUpView(_ slideUpView: TGCameraSlideView, slideDownView: TGCameraSlideView, atView view: UIView, completion: @escaping () -> Void) {
        slideUpView.addSlideToView(view, withOriginY: slideUpView.finalPosition())
        slideDownView.addSlideToView(view, withOriginY: slideDownView.finalPosition())
        slideUpView.removeSlideFromSuperview(false, withDuration: 0.15, originY: slideUpView.initialPositionWithView(view), completion: { _ in })
        slideDownView.removeSlideFromSuperview(false, withDuration: 0.15, originY: slideDownView.initialPositionWithView(view), completion: completion)
    }
    
    open static func hideSlideUpView(_ slideUpView: TGCameraSlideView, slideDownView: TGCameraSlideView, atView view: UIView, completion: @escaping () -> Void) {
        slideUpView.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: { _ in })
        slideDownView.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: completion)
    }
    
    func showWithAnimationAtView(_ view: UIView, completion: @escaping () -> Void) {
        self.addSlideToView(view, withOriginY: self.finalPosition())
        self.removeSlideFromSuperview(false, withDuration: 0.15, originY: self.initialPositionWithView(view), completion: completion)
    }
    
    func hideWithAnimationAtView(_ view: UIView, completion: @escaping () -> Void) {
        self.hideWithAnimationAtView(view, withTimeInterval: 0.6, completion: completion)
    }
    
    // MARK: - TGCameraSlideViewProtocol
    
    
    open func initialPositionWithView(_ view: UIView) -> CGFloat {
        let emptyPointer: UnsafeMutablePointer<Int8>? = nil
        
        NSException.raise(NSExceptionName(rawValue: kExceptionName), format: kExceptionMessage, arguments: CVaListPointer.init(_fromUnsafeMutablePointer: emptyPointer!))
        
        return 0.0
    }
    
    open func finalPosition() -> CGFloat {
        let emptyPointer: UnsafeMutablePointer<Int8>? = nil
        NSException.raise(NSExceptionName(rawValue: kExceptionName), format: kExceptionMessage, arguments: CVaListPointer.init(_fromUnsafeMutablePointer: emptyPointer!))
        return 0.0
    }
    
    // MARK: Private
    
    
    func addSlideToView(_ view: UIView, withOriginY originY: CGFloat) {
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.frame.height / 2
        var frame: CGRect = self.frame
        frame.size.width = width
        frame.size.height = height
        frame.origin.y = originY
        self.frame = frame
        view.addSubview(self)

    }
    
    func hideWithAnimationAtView(_ view: UIView, withTimeInterval timeInterval: CGFloat, completion: @escaping () -> Void) {
        self.addSlideToView(view, withOriginY: self.initialPositionWithView(view))
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {() -> Void in
            Thread.sleep(forTimeInterval: Double(timeInterval))
            DispatchQueue.main.async(execute: {() -> Void in
                self.removeSlideFromSuperview(true, withDuration: 0.5, originY: self.finalPosition(), completion: completion)
            })
        })

    }
    
    func removeSlideFromSuperview(_ remove: Bool, withDuration duration: CGFloat, originY: CGFloat, completion: @escaping () -> Void) {
        
        var frame: CGRect = self.frame
        frame.origin.y = originY
        UIView.animate(withDuration: Double(duration), animations: {() -> Void in
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
