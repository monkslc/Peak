//
//  ScrollPresenterView.swift
//  Peak
//
//  Created by Connor Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class ScrollPresenterView: UIView {

    /*MARK: INSPECTABLE PROPERTIES*/
    @IBInspectable var labelColor: UIColor = UIColor.white
    @IBInspectable var labelHeight: CGFloat = 30
    
    
    /*MARK: OTHER PROPERTIES*/
    var positionOfLabel: CGFloat = 0.0{
        
        didSet{
            
            displayLabelView.frame.origin.y = positionOfLabel
        }
    }
    
    var displayLabelView = DisplayLabelView()
    var displayLabel = UILabel()

    func setUp(){
        
        self.isUserInteractionEnabled = false
        
        //Set up the display label view
        displayLabelView = DisplayLabelView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: labelHeight))
        displayLabelView.backgroundColor = UIColor.clear
        displayLabelView.layer.backgroundColor = labelColor.cgColor
        
        //Set up the displayLabel
        displayLabel = UILabel(frame: CGRect(x: 5, y: 0, width: displayLabelView.frame.width, height: displayLabelView.frame.height))
        displayLabel.textColor = UIColor.artistColor
        
        //Now add them
        displayLabelView.addSubview(displayLabel)
        addSubview(displayLabelView)
        displayLabelView.isHidden = true
        
    }
}
