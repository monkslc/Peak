//
//  BackButton.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SICBackButton: UIButton {

    /*MARK: Initializers*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("Back Button initialization")
        //Add the target
        addTarget(self, action: #selector(restartSong), for: .touchUpInside)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    /*MARK: Target Methods*/
    func restartSong(){
        //Get's called when the button gets pressed
        
        peakMusicController.systemMusicPlayer.skipToBeginning()
    }
}
