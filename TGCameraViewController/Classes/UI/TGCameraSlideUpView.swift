//
//  TGCameraSlideUpView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraSlideUpView: TGCameraSlideView
{
    // MARK: - TGCameraSlideViewProtocol
    
    
    open override func initialPositionWithView(_ view: UIView) -> CGFloat {
        return 0
    }
    
    open override func finalPosition() -> CGFloat {
        return -self.frame.maxY
    }
}
