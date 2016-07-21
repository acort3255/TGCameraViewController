//
//  TGCameraGridView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

public class TGCameraGridView: UIView {
    public var lineWidth: CGFloat = 0.0
    public var numberOfColumns: Int = 0
    public var numberOfRows: Int = 0
    
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
    
    override public func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetLineWidth(context, self.lineWidth)
        CGContextSetStrokeColorWithColor(context, TGCameraColor.grayColor().colorWithAlphaComponent(0.7).CGColor)
        let columnWidth: CGFloat = self.frame.size.width / (CGFloat(numberOfColumns) + 1.0)
        let rowHeight: CGFloat = self.frame.size.height / (CGFloat(numberOfRows) + 1.0)
        
        for i in 1 ... self.numberOfColumns {
            var startPoint = CGPoint()
            startPoint.x = columnWidth * CGFloat(i)
            startPoint.y = 0.0
            var endPoint = CGPoint()
            endPoint.x = startPoint.x
            endPoint.y = self.frame.size.height
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
            CGContextStrokePath(context)
        }
        
        for i in 1 ... self.numberOfRows {
            var startPoint = CGPoint()
            startPoint.x = 0.0
            startPoint.y = rowHeight * CGFloat(i)
            var endPoint = CGPoint()
            endPoint.x = self.frame.size.width
            endPoint.y = startPoint.y
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
            CGContextStrokePath(context)
        }


    }
    
    
    // MARK: - Private methods
    
    
    func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.lineWidth = 0.8;
    }
    
    
}