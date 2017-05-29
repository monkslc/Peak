//
//  RoundedButton.swift
//  Peak
//
//  Created by Connor Monks on 3/19/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable var layerColor: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    
    override func draw(_ rect: CGRect) {
        
        backgroundColor = UIColor.clear
        layer.cornerRadius = 20
        layer.backgroundColor = layerColor.cgColor
        
        
        layer.shadowOffset = CGSize(width: frame.width/56.2, height: frame.height/8.14)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        clipsToBounds = true
    }

    
  
}
