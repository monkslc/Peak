//
//  SICDisplay.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SICDisplay: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    /*MARK: Inspectable Properties*/
    @IBInspectable var borderColor: UIColor = UIColor.lightGray
    @IBInspectable var borderWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //Draw a bezier path at the top
        let topBorder = UIBezierPath()
        
        topBorder.move(to: CGPoint(x: rect.minX, y: rect.minY))
        topBorder.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        topBorder.lineWidth = borderWidth
        borderColor.set()
        topBorder.stroke()
        
    }

}
