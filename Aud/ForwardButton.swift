//
//  ForwardButton.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class ForwardButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setUp(){
        
        setImage(#imageLiteral(resourceName: "Forward Filled-50"), for: .normal)
        addTarget(self, action: #selector(nextSong), for: .touchUpInside)
    }
    
    func nextSong(){
        
        peakMusicController.systemMusicPlayer.skipToNextItem()
    }
}
