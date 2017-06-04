//
//  GroupiesView.swift
//  Peak
//
//  Created by Connor Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class GroupiesView: UIView {

    
    
    var groupies = [UIImage](){
        
        didSet{
            
            displayGroupies()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    func displayGroupies(){
        
        print("Displaying Groupies")
        
        var count = 0
        for groupie in groupies{
            
            let groupieView = UIImageView(frame: CGRect(x: CGFloat(count) * CGFloat((frame.height + 15)), y: frame.minY, width: frame.height, height: frame.height))
            
            groupieView.image = groupie
            
            count += 1
        }
    }
}
