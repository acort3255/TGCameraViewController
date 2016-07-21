//
//  TGCameraSlideViewProtocol.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public protocol TGCameraSlideViewProtocol: class
{
    func initialPositionWithView(view: UIView) -> CGFloat
    
    func finalPosition() -> CGFloat
}