//
//  HeaderView.swift
//  Peak
//
//  Created by Connor Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

@IBDesignable
class HeaderView: UIView {

    //Border Variables
    @IBInspectable var borderWidth: CGFloat = 3.0
    @IBInspectable var borderColor: UIColor = UIColor.darkGray
    
    //Shadow Variables
    @IBInspectable var shOpacity: Float = 0.85
    @IBInspectable var shOffset: Double = 3
    @IBInspectable var shColor: UIColor = UIColor.darkGray
    
    
    override func draw(_ rect: CGRect) {
        
        //Draw a bottom border
        let bottomBorder = UIBezierPath()
        bottomBorder.move(to: CGPoint(x: frame.minX, y: frame.maxY))
        bottomBorder.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        
        bottomBorder.lineWidth = borderWidth
        borderColor.set()
        
        bottomBorder.stroke()
        bottomBorder.fill()
        
        //Create a shadow here
        layer.shadowOpacity = shOpacity
        layer.shadowOffset = CGSize(width: 0, height: shOffset)
        layer.shadowColor = shColor.cgColor
    }
 

}
