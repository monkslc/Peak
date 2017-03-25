//
//  RecentlyAddedView.swift
//  Peak
//
//  Created by Connor Monks on 3/16/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class RecentlyAddedView: UIScrollView {


    override func draw(_ rect: CGRect) {
        
        //Draw A border at the bottom
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY - 1))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - 1))
        
        path.lineWidth = 2.0
        UIColor.lightGray.set()
        path.stroke()
    }
 
    func setUp(){
        
        isScrollEnabled = true
        alwaysBounceHorizontal = true
        backgroundColor = UIColor.clear
        indicatorStyle = .black
    }
}
