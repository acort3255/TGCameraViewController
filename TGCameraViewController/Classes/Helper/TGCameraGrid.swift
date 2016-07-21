//
//  TGCameraGrid.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGCameraGrid: NSObject {
    public static func disPlayGridView(gridView: TGCameraGridView)
    {
        var newAlpha: Int = (gridView.alpha == 0) ? 1 : 0
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {() -> Void in
            gridView.alpha = CGFloat(newAlpha)
            }, completion: { _ in })

    }
}