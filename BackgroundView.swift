//
//  BackgroundView.swift
//  Peak
//
//  Created by Connor Monks on 3/21/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

@IBDesignable
class BackgroundView: UIView {

    @IBInspectable var lightColor: UIColor = UIColor.lightGray
    @IBInspectable var darkColor: UIColor = UIColor.black
    
    
    override func draw(_ rect: CGRect) {
    
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        
        gradientLayer.colors = [darkColor.cgColor, lightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.15, y: 0.15)
        //gradientLayer.locations = [0.0, 1.0]
        
        layer.addSublayer(gradientLayer)
        
        super.draw(rect)
    }

}
