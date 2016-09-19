//
//  TGCameraGridView.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/21/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraGridView: UIView {
    open var lineWidth: CGFloat = 0.0
    open var numberOfColumns: Int = 0
    open var numberOfRows: Int = 0
    
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
    
    override open func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(self.lineWidth)
        context.setStrokeColor(TGCameraColor.gray.withAlphaComponent(0.7).cgColor)
        let columnWidth: CGFloat = self.frame.size.width / (CGFloat(numberOfColumns) + 1.0)
        let rowHeight: CGFloat = self.frame.size.height / (CGFloat(numberOfRows) + 1.0)
        
        for i in 1 ... self.numberOfColumns {
            var startPoint = CGPoint()
            startPoint.x = columnWidth * CGFloat(i)
            startPoint.y = 0.0
            var endPoint = CGPoint()
            endPoint.x = startPoint.x
            endPoint.y = self.frame.size.height
            context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            context.strokePath()
        }
        
        for i in 1 ... self.numberOfRows {
            var startPoint = CGPoint()
            startPoint.x = 0.0
            startPoint.y = rowHeight * CGFloat(i)
            var endPoint = CGPoint()
            endPoint.x = self.frame.size.width
            endPoint.y = startPoint.y
            context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            context.strokePath()
        }


    }
    
    
    // MARK: - Private methods
    
    
    func setup() {
        self.backgroundColor = UIColor.clear
        self.lineWidth = 0.8;
    }
    
    
}
