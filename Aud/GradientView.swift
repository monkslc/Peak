//
//  GradientView.swift
//  Peak
//
//  Created by Cameron Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
   
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.startPoint = CGPoint.zero
        layer.endPoint = CGPoint(x: 1, y: 1) //CGPoint(x: 1, y: 0.5)
    }
}
