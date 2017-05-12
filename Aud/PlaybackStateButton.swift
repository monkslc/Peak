//
//  PlaybackStateButton.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaybackStateButton: UIButton {

    /*MARK: Initializers*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //set the inital image
        if peakMusicController.systemMusicPlayer.getPlayerState() == MusicPlayerState.playing {
            
            setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        }else {
            
            setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
        
        //Add the listeners
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateChanged), name: .systemMusicPlayerStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicOrPlayerTypeChanged), name: .musicTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicOrPlayerTypeChanged), name: .playerTypeChanged, object: nil)
        
        
        //Add the gestures
        addTarget(self, action: #selector(changePlaybackState), for: .touchUpInside)
        
        //Check if we want to be visible or not
        if peakMusicController.musicType == .Guest || peakMusicController.playerType == .Contributor{
            
            isHidden = true
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /*Mark: Notifcaiton Methods*/
    
    func playbackStateChanged(){
        //Change the button's image to the appropriate playback state
        
        if peakMusicController.systemMusicPlayer.getPlayerState() == MusicPlayerState.playing{
            
            setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        }else{
            
            setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
    }
    
    func musicOrPlayerTypeChanged(){
        //Check if the play pause button should be hidden or visible
        
        if peakMusicController.musicType == .Guest || peakMusicController.playerType == .Contributor{
            
            isHidden = true
        }
    }
    
    /*Mark: Gesture Recognizer Methods*/
    
    func changePlaybackState(){
        //Change the playback state of the system music player accordingly
        
        if peakMusicController.systemMusicPlayer.getPlayerState() == MusicPlayerState.playing{
            
            peakMusicController.systemMusicPlayer.stopPlaying()
        } else {
            
            peakMusicController.systemMusicPlayer.startPlaying()
        }
    }
    
    

}
