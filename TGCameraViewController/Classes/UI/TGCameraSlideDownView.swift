//
//  TGCameraSlideDownView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGCameraSlideDownView: TGCameraSlideView
{
    // MARK: - TGCameraSlideViewProtocol
    
    
    public override func initialPositionWithView(view: UIView) -> CGFloat {
        return CGRectGetHeight(view.frame) / 2
    }
    
    public override func finalPosition() -> CGFloat {
        return CGRectGetMaxY(self.frame)
    }
}