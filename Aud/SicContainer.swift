//
//  SicContainer.swift
//  Peak
//
//  Created by Connor Monks on 5/2/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SicContainer: UIView {

    /*MARK: PROPERTIES*/
    var isPoppedUp = false
    
    /*MARK: INITIALIZERS*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Add the gestures
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnSic)))
        
        
        /*SWIPE GESTURES*/
        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(swipeSIC(_:)))
        swipeUP.direction = .up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeSIC(_:)))
        swipeDown.direction = .down
        
        addGestureRecognizer(swipeDown)
        addGestureRecognizer(swipeUP)
    }
    
    /*MARK: GESTURE RECOGNIZERS*/
    @objc func swipeSIC(_ gesture: UISwipeGestureRecognizer){
        
        if gesture.direction == .up{
            
            if !isPoppedUp {
                
                animateSic(up: true)
            }
        } else if gesture.direction == .down{
            
            if isPoppedUp {
                
                animateSic(up: false)
            }
        }
    }
    
    @objc func tappedOnSic(){
        
        if isPoppedUp{
            
            animateSic(up: false)
            
        } else {
            
            animateSic(up: true)
        }
    }
    
    
    /*MARK: ANIMATION METHOD*/
    func animateSic(up: Bool){
        
        if up{
            
            //Animate it up
            UIView.animate(withDuration: 0.5, animations: {
                
                self.transform = CGAffineTransform(translationX: 0, y: ((self.frame.height - 135) * -1))
            }, completion: {(finished) in
                
                self.isPoppedUp = true
            })
        } else {
            
            //Animate it down
            UIView.animate(withDuration: 0.5, animations: {
                
                self.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: {(finished) in
                
                self.isPoppedUp = false
            })
        }
    }
    

}
