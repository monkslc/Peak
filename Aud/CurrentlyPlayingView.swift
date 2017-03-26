//
//  CurrentlyPlayingView.swift
//  Aud
//
//  Created by Connor Monks on 3/14/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit

class CurrentlyPlayingView: UIView{

    //variable to pass the library down
    var library = UITableView()
    
    
    /*VISIBLE VIEWS*/
    var albumView = CurrentlyPlayingAlbumView()
    var volumeSlider = MPVolumeView()
    var borderColor = UIColor.lightGray
    var pausePlayButton = UIButton()
    var songProgressSlider = SongProgressSlider()
    
    
    /*HIDDEN VIEWS*/
    var volumeView = VolumeView()
    var musicInfo = MusicInfoDisplay()
    
    
    var isPoppedUp = false
    
    //Test View
    let songLengthSlider = UISlider()
    
    override func draw(_ rect: CGRect) {
       
        //Draw A Top Border
        //The Line
        let path = UIBezierPath()
        path.move(to: CGPoint(x:bounds.minX ,y: bounds.minY + 50))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + 50))
        path.lineWidth = 3.0
        //UIColor(red: 30/255, green: 220/255, blue: 187/255, alpha: 1.0).set()
        borderColor.set()
        path.stroke()
        
    }

    
    func addAllViews(){
        
        addVisibleViews()
        addHiddenViews()
    }
    
    /*Start of Functions to add Views*/
    
    func addVisibleViews(){
        
        
        //Set the background color to clear, then create a view below the top 50 that is white
        backgroundColor = UIColor.clear
        let whiteView = UIView(frame: CGRect(x: bounds.minX, y: bounds.minY + 50, width: bounds.width, height: bounds.height))
        whiteView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.95)
        addSubview(whiteView)
        
        //Only add these views if the user is not a contributor
        if peakMusicController.playerType != .Contributor {
            
            //Add the forward button
            let forwardButton = ForwardButton(frame: CGRect(x: (whiteView.frame.maxX * 0.75), y: whiteView.frame.minY + 5, width: 50, height: 50))
            forwardButton.setUp()
            addSubview(forwardButton)
            
            
            //Add the Previous Button
            let previousButton = BeginningButton(frame: CGRect(x: (whiteView.frame.maxX * 0.25) - 50, y: whiteView.frame.minY, width: 50, height: 50))
            previousButton.setUp()
            addSubview(previousButton)
            
            //Create the Song Progress View
            let progressOfSongView = SongProgressView(frame: CGRect(x: bounds.minX, y: bounds.minY + 97.5, width: bounds.width, height: 40))
            progressOfSongView.setUp()
            addSubview(progressOfSongView)
        }
        
        
        
        
        //Draw the album in the center
        albumView = CurrentlyPlayingAlbumView(frame: CGRect(x: bounds.midX - 50, y: bounds.minY, width: 100, height: 100))
        albumView.setUp()
        addSubview(albumView)
        albumView.addPausePlay()
        albumView.addListeners()
        
        
    }
    
    func addHiddenViews(){
        
        //Add the music info display
        musicInfo = MusicInfoDisplay(frame: CGRect(x: bounds.minX, y: bounds.minY + 145, width: bounds.width, height: frame.height - (145 + 30)))
        musicInfo.library = library
        musicInfo.setUp()
        addSubview(musicInfo)
        
        
        //SET UP VOLUME VIEW, if the user is not a contributor
        if peakMusicController.playerType != .Contributor {
            
            volumeView = VolumeView(frame: CGRect(x: bounds.minX, y: bounds.maxY - 50, width: bounds.width, height: 50))
            volumeView.setUp()
            addSubview(volumeView)
        }
        
        
    }
    
    
    func updateInfoDisplay(){
        
        musicInfo.updateDisplay()
    }
    
    /*End of Functions to add Views*/
    
    
    func animate(){
        //used to animate self in a nd out of view
        
        
        //Check if the view is poppedUp and transform accordingly
        if isPoppedUp {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: {(finished) in
                
                self.isPoppedUp = false
            })
        }else {
            
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.transform = CGAffineTransform(translationX: 0, y: (self.frame.height - 135) * -1)
            }, completion: {(finished) in
                
                self.isPoppedUp = true
            })
        }
    }
 

}
