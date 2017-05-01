//
//  BeastController.swift
//  Peak
//
//  Created by Connor Monks on 5/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class BeastController: UIViewController {

    /*MARK: Properties*/

    var isPoppedUp = false
    @IBOutlet weak var songInteractionContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Set up the song interaction container (SIC)
        addSicGestures()

    }


    /*MARK: SIC CONTAINER VIEW METHODS*/
    
    func addSicGestures(){
        
        songInteractionContainer.isUserInteractionEnabled = true
        songInteractionContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnSic)))
        
        
        /*SWIPE GESTURES*/
        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(swipeSIC(_:)))
        swipeUP.direction = .up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeSIC(_:)))
        swipeDown.direction = .down
        
        songInteractionContainer.addGestureRecognizer(swipeDown)
        songInteractionContainer.addGestureRecognizer(swipeUP)
    }
    
    func swipeSIC(_ gesture: UISwipeGestureRecognizer){
        
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
    
    func tappedOnSic(){
        
        if isPoppedUp{
            
            animateSic(up: false)
            
        } else {
            
            animateSic(up: true)
        }
    }
    
    func animateSic(up: Bool){
        
        if up{
            
            //Animate it up
            UIView.animate(withDuration: 0.5, animations: {
                
                self.songInteractionContainer.transform = CGAffineTransform(translationX: 0, y: (self.songInteractionContainer.frame.height - 135) * -1)
            }, completion: {(finished) in
                
                self.isPoppedUp = true
            })
        } else {
            
            //Animate it down
            UIView.animate(withDuration: 0.5, animations: {
                
                self.songInteractionContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: {(finished) in
                
                self.isPoppedUp = false
            })
        }
    }
    
    
}
