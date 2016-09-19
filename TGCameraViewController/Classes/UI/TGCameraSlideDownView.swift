//
//  TGCameraSlideDownView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraSlideDownView: TGCameraSlideView
{
    // MARK: - TGCameraSlideViewProtocol
    
    
    open override func initialPositionWithView(_ view: UIView) -> CGFloat {
        return view.frame.height / 2
    }
    
    open override func finalPosition() -> CGFloat {
        return self.frame.maxY
    }
}
