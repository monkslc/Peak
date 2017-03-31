//
//  DiscAnimation.swift
//  Peak
//
//  Created by Connor Monks on 3/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class DiscAnimation: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    func animateMe(){
        
        isHidden = false
        
        UIView.animate(withDuration: 0.4, animations: {
        
            
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: {(finished) in
        
        
            UIView.animate(withDuration: 0.4, animations: {
                
                
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
            }, completion: {(finished) in
                
                
                self.animateMe()
            })
        })
    }
    
    func stopMyAnimation(){
        
        isHidden = true
        layer.removeAllAnimations()
    }
}
