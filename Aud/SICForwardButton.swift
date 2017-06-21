//
//  SICForwardButton.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SICForwardButton: UIButton {

    /*MARK: Initializers*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Add the target
        addTarget(self, action: #selector(skipSong), for: .touchUpInside)
        
        //Add notification listener
        NotificationCenter.default.addObserver(self, selector: #selector(playerTypeChanged), name: .playerTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicTypeChanged), name: .musicTypeChanged, object: nil)
        
        //if we are a guest we want to hide this
        if peakMusicController.musicType == .Guest{
            
            self.isHidden = true
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    /*MARK: Target Method*/
    
    @objc func skipSong(){
        //Called when the button gets pressed
        
        peakMusicController.systemMusicPlayer.skipSong()
    }
    
    /*MARK: NOTIFICATION METHODS*/
    @objc func playerTypeChanged(){
        
        DispatchQueue.main.async {
            
            if peakMusicController.playerType == .Contributor{
                self.isHidden = true
            } else{
                
                self.isHidden = false
            }
        }
        
    }
    
    @objc func musicTypeChanged(){
        
        DispatchQueue.main.async {
            
            if peakMusicController.musicType == .Guest{
                
                self.isHidden = true
            } else{
                self.isHidden = false
            }
        }
        
    }
    
}
