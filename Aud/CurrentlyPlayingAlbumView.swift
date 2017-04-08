//
//  CurrentlyPlayingAlbumView.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class CurrentlyPlayingAlbumView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var pausePlayButton = UIButton()
    
    func setUp(){
        //sets up the view for the image
        
        clipsToBounds = true
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        isUserInteractionEnabled = true
        
        if peakMusicController.systemMusicPlayer.nowPlayingItem == nil{
            image = #imageLiteral(resourceName: "ProperPeakyAlbumView")
        }
        
    }
    
    func addListeners(){
        //add a listener to change the image when the song changes, and to change the pauseplayButton when playback state changes
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumImage),name: .MPMusicPlayerControllerNowPlayingItemDidChange , object: peakMusicController.systemMusicPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playBackStateChanged(_:)), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: peakMusicController.systemMusicPlayer)
    }
    
    func updateAlbumImage(_ notification: NSNotification){
        
        image = peakMusicController.systemMusicPlayer.nowPlayingItem?.artwork?.image(at: CGSize()) ?? #imageLiteral(resourceName: "ProperPeakyAlbumView")
    }
    
    
    /*PAUSE PLAY METHODS*/
    func addPausePlay(){
        
        pausePlayButton = UIButton(frame: bounds)
        pausePlayButton.addTarget(self, action: #selector(userChangedPlayBackState), for: .touchUpInside)
        
        //set the intial image
        if peakMusicController.systemMusicPlayer.playbackState == .playing {
            pausePlayButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        }else{
            
            pausePlayButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
        
        pausePlayButton.alpha = 0.85
        pausePlayButton.isUserInteractionEnabled = true
        addSubview(pausePlayButton)
    }
    
    func userChangedPlayBackState(){
        //change the playback state to the opposite of what it is
        
        if peakMusicController.systemMusicPlayer.playbackState == .playing {
            
            peakMusicController.systemMusicPlayer.pause()
        } else {
            
            peakMusicController.systemMusicPlayer.play()
        }
    }
    
    func playBackStateChanged(_ notification: NSNotification){
        //change the image accordingly
        
        if peakMusicController.systemMusicPlayer.playbackState == .playing {
            
            pausePlayButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        } else {
            
            pausePlayButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
    }
    
    /*END OF PAUSE PLAY METHODS*/
}
