//
//  ScrollBar.swift
//  Peak
//
//  Created by Connor Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

protocol ScrollBarDelegate {
    
    func scrolling(_ yLoc: CGFloat, _ state: UIGestureRecognizerState)
}

@IBDesignable
class ScrollBar: UIView {

    /*MARK: Inspectable Properties*/
    @IBInspectable var heightOfScrollBar: CGFloat = 50
    @IBInspectable var colorOfScrollBar: UIColor = UIColor.peakColor
    @IBInspectable var barRadius: CGFloat = 5.0
    
    
    /*MARK: Other Properties*/
    var position: CGFloat = 0.0{
        
        didSet{

            setNeedsDisplay()
        }
    }
    
    //var shouldShow = false

    var delegate: ScrollBarDelegate?
    
    override func draw(_ rect: CGRect) {
        
        //Draw the scroll bar
        
        //if shouldShow == true {
        //}
        let scrollBarRect = CGRect(x: 0.0, y: position, width: frame.width/2, height: heightOfScrollBar)
        let scrollBar = UIBezierPath(roundedRect: scrollBarRect, cornerRadius: barRadius)
            
        colorOfScrollBar.withAlphaComponent(0.7).set()
        scrollBar.stroke()
        scrollBar.fill()
        
        
    }
 
    
    //Method to do the set up... Needs to be called in the view controller when it loads
    func setUp(){
        
        isHidden = true
        
        //Add the gesture recognizer
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(isScrolling(_:))))
        
        
        
    }
    
    
    //method that gets called when the scroll bar is scrolling
    func isScrolling(_ pan: UIPanGestureRecognizer){
        
    
        //Get the y location of the pan
        let panLoc = pan.location(in: self).y
        
        //Position to move the scroll bar to
        var newPos: CGFloat = 0.0
        
        //Get the position
        if pan.velocity(in: self).y < 0 {
            //We are scrolling up
            
            newPos = max(heightOfScrollBar/2, panLoc)
        } else {
            //we are scrolling down
            
            newPos = min(frame.height - (heightOfScrollBar / 2), panLoc)
        }
        
        
        newPos -= heightOfScrollBar / 2
        //now do me updates
        position = newPos
        delegate?.scrolling(newPos, pan.state)
        
    }
    
    func setHeight(_ itemsCount: Int){
        
        let height = frame.height - CGFloat((itemsCount * 10))
        if height <= 50{
            heightOfScrollBar = 50
        } else{
            
            heightOfScrollBar = height
        }
    }

}
