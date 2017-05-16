//
//  SicSongProgress.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class SicSongProgress: UISlider {

    /*Mark: Initializations*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Start the timer in order to continuously update the slider
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateSongTime), userInfo: nil, repeats: true)
        
        //Add the listeners
        NotificationCenter.default.addObserver(self, selector: #selector(songTimeChanged), name: .updateSongTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(songChanged), name: .systemMusicPlayerNowPlayingChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerTypeChanged), name: .playerTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicTypeChanged), name: .musicTypeChanged, object: nil)
        
        //Add target
        addTarget(self, action: #selector(changeSongTime), for: .valueChanged)
        
        //turn off constant notifications
        self.isContinuous = false
        
        minimumValue = 0
        maximumValue = 100
        value = 0
        
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

    /*Mark: Timer Method*/
    func updateSongTime(){
        //Get's called from the timer, post the notification
        
        //Post a notification
        NotificationCenter.default.post(Notification(name: .updateSongTime))
    }
    
    
    /*Mark: Listener Methods*/
    func songTimeChanged(){
        //Get's called from the notification
        
        value = Float(peakMusicController.systemMusicPlayer.getCurrentPlaybackTime())
    }
    
    func songChanged(){
        //Get's called when the song changes on the system music player
        
        maximumValue = Float((peakMusicController.systemMusicPlayer.getNowPlayingItem()?.getTrackTimeMillis()) ?? Int(0.0))
    }
    
    func playerTypeChanged(){
        
        DispatchQueue.main.async {
            
            if peakMusicController.playerType == .Contributor{
                
                self.isHidden = true
                
            } else{
                
                self.isHidden = false
            }
        }
        
    }
    
    func musicTypeChanged(){
        
        DispatchQueue.main.async {
            
            if peakMusicController.musicType == .Guest{
                
                self.isHidden = true
            } else{
                
                self.isHidden = false
            }
        }
    }
    
    
    /*Mark: Target Methods*/
    func changeSongTime(){
        //Get's called when the user changes the song time, update the time of the current song playing in peak music controller
        
        peakMusicController.systemMusicPlayer.setCurrentPlayTime(Double(value))
    }
}
