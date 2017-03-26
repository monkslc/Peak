//  LIKE A ROLLING STONE -- Connor Monks was Here
//  Chad Martin wuz herrre
//  The fiddler he now steps to the road
//  The fiddler the chad martin takes a load
//  SongProgressSlider.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SongProgressSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setUp(){
        
        addTarget(self, action: #selector(updateCurrentTime), for: .valueChanged)
        tintColor = UIColor.peakColor
        setThumbImage(UIImage(), for: .normal)
    }
    
    func updateCurrentTime(){
        
        peakMusicController.systemMusicPlayer.currentPlaybackTime = TimeInterval(value)
    }
    
    
    func updateToSongTime(){
        //Method to update the value of the slider and labels
        
        maximumValue = Float((peakMusicController.systemMusicPlayer.nowPlayingItem?.playbackDuration)!)
        minimumValue = 0
        value = Float(peakMusicController.systemMusicPlayer.currentPlaybackTime)
    }
   
    
    
}
