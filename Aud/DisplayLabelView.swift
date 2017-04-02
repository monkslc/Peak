//
//  DisplayLabelView.swift
//  Peak
//
//  Created by Connor Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class DisplayLabelView: UIView {

    
    override func draw(_ rect: CGRect) {
        
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.85
        
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5
    }


}
