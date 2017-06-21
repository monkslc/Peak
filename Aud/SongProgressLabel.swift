//
//  SongProgressLabel.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SongProgressLabel: UILabel {

    
    /*MARK: Initializers*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Add the listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabelTime), name: .updateSongTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerTypeChanged), name: .playerTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicTypeChanged), name: .musicTypeChanged, object: nil)
    
        //if we are a guest we want to hide this
        if peakMusicController.musicType == .Guest{
            
            self.isHidden = true
        }
    }
    
    
    /*MARK: Properties*/
    enum ProgressType{
        //Enum to determine which label it is
        
        case Beg
        case End
    }
    
    var progressType: ProgressType = .Beg
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    /*MARK: Listener Methods*/
    @objc func updateLabelTime(){
        //Get's called from the notification that indicates we should update our song labels

        //See what label we are updating so we know which one to set
        if progressType == .Beg{
            
            var currentTime = peakMusicController.systemMusicPlayer.getCurrentPlaybackTime()
            currentTime = currentTime > 0 ? currentTime : 0
            text = formatTime(currentTime)
        }else {
            
            let duration = peakMusicController.systemMusicPlayer.nowPlaying?.getTrackTimeMillis() ?? Int(0.0)
            text = formatTime(TimeInterval(duration))
        }
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
    
    /*MARK: MODEL METHODS*/
    private func formatTime(_ time: TimeInterval) -> String{
        //Takes a time and formats it as a string for easy display
        
        if !time.isNaN {
            
            let minutes = Int(floor((time / 60)))
            let seconds = (time - ((Double(minutes) * 60))) / 100
            let secondsFormat = String(format: "%.2f", seconds)
            let timeFormatted = String(minutes) + ":" + String(secondsFormat).replacingOccurrences(of: "0.", with: "")
            return timeFormatted
        } else {
            
            return "0:00"
        }
        
        
    }
}
