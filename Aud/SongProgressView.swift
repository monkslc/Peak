//
//  SongProgressView.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SongProgressView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var songProgressSlider = SongProgressSlider()
    var currentTimeLabel = UILabel()
    var songDurationLabel = UILabel()
    
    /*Set Up Methods*/
    func setUp(){
        
        isUserInteractionEnabled = true
        addSlider()
        addSongTimeLabels()
        startTimer()
    }
    
    func addSlider(){
        
        //DRAW THE SONG PROGRESS SLIDER
        songProgressSlider = SongProgressSlider(frame:  CGRect(x: bounds.minX + 40 , y: bounds.minY + 6, width: (bounds.width - 80), height: 30))
        songProgressSlider.setUp()
        addSubview(songProgressSlider)
    }
    
    func addSongTimeLabels() {
        
        currentTimeLabel = UILabel(frame: CGRect(x: bounds.minX, y: bounds.minY, width: 40, height: 40))
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(currentTimeLabel)
        
        songDurationLabel = UILabel(frame: CGRect(x: bounds.maxX - 40, y: bounds.minY, width: 40, height: 40))
        songDurationLabel.textAlignment = .center
        songDurationLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(songDurationLabel)
    }
    
    
    /*TIMER METHODS*/
    func startTimer(){
            
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateSongTime), userInfo: nil, repeats: true)
        
    }
    
    func updateSongTime(){
        //Method to update the value of the slider and labels
        
        songProgressSlider.updateToSongTime()
        updateLabels()
    }
    
    private func updateLabels(){
        //method to update the label text to the correct times
        
        let currentTime = peakMusicController.systemMusicPlayer.currentPlaybackTime
        currentTimeLabel.text = formatTime(currentTime)
        
        let duration = peakMusicController.systemMusicPlayer.nowPlayingItem?.playbackDuration ?? 0.0
        songDurationLabel.text = formatTime(duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String{
        
        
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
