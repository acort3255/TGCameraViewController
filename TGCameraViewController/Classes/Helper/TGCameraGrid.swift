//
//  TGCameraGrid.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraGrid: NSObject {
    open static func disPlayGridView(_ gridView: TGCameraGridView)
    {
        let newAlpha: Int = (gridView.alpha == 0) ? 1 : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {() -> Void in
            gridView.alpha = CGFloat(newAlpha)
            }, completion: { _ in })

    }
}
