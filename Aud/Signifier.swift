//
//  Signifier.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class Signifier: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func animationSetUp(){
        
        backgroundColor = UIColor.clear
        image = #imageLiteral(resourceName: "Checkmark-96")
        alpha = 0.0
    }
    
    
    func animate(){
        //Create the animation for the signifier
        

        UIView.animate(withDuration: 0.5, animations: {
            
            self.alpha = 1.0
        }, completion: {(finished) in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.alpha = 0.0
            }, completion: {(finished) in
                
                self.removeFromSuperview()
            })
        })
        
    }
}
