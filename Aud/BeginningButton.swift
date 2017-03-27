//
//  BeginningButton.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class BeginningButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    func setUp(){
        
        setImage(#imageLiteral(resourceName: "Backward Filled-50"), for: .normal)
        addTarget(self, action: #selector(restartSong), for: .touchUpInside)
    }
    
    func restartSong(){
        
        peakMusicController.systemMusicPlayer.skipToBeginning()
    }
}
