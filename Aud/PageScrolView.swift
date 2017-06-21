//
//  PageScrolVIew.swift
//  Aud
//
//  Created by Cameron Monks on 6/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

protocol PageScrolViewDelagate {
    func changeInTouches(currentScrollView: PageScrolView, change: CGFloat)
    func useVelocityAtEndOfSwipe(currentScrollView: PageScrolView, velocity: CGFloat)
    func swipeHorizontally(currentScrollView: PageScrolView, translation: CGFloat)
    func swipeHorizontally(currentScrollView: PageScrolView, velocity: CGFloat)
}

class PageScrolView: UIScrollView {
    
    var pageScrolViewDelagate: PageScrolViewDelagate?
    
    private var oldPosition: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for g in gestureRecognizers! {
            removeGestureRecognizer(g)
        }
        
        gestureRecognizers = []
        
        //UITouch.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(PageScrolView.panGesture(sender:)))
        //gesture.minimumNumberOfTouches = 1
        //gesture.maximumNumberOfTouches = 2
        
        addGestureRecognizer(gesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.translation(in: self)
        
        let changeX = location.x - oldPosition.x
        let changeY = location.y - oldPosition.y
        
        oldPosition = location
        if sender.state == .began {
            return
        }
        
        let velocity = sender.velocity(in: self)
        if abs(velocity.x) > abs(velocity.y) {
            
            if sender.state == .ended {
                if let pageScrolViewDelagate = pageScrolViewDelagate {
                    pageScrolViewDelagate.swipeHorizontally(currentScrollView: self, velocity: sender.velocity(in: self).x)
                }
            }
            else {
                if let pageScrolViewDelagate = pageScrolViewDelagate {
                    pageScrolViewDelagate.swipeHorizontally(currentScrollView: self, translation: changeX)
                }
            }
        }
        else {
            if sender.state == .ended {
                if let pageScrolViewDelagate = pageScrolViewDelagate {
                    let velocity = sender.velocity(in: self).y
                    pageScrolViewDelagate.useVelocityAtEndOfSwipe(currentScrollView: self, velocity: velocity)
                }
                return
            }
            
            if let pageScrolViewDelagate = pageScrolViewDelagate {
                pageScrolViewDelagate.changeInTouches(currentScrollView: self, change: changeY)
            }
        }
    }
    
}
