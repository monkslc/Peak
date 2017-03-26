//
//  MusicInfoDisplay.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class MusicInfoDisplay: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var library = UITableView()
    var displayController = UISegmentedControl()
    var infoDisplay = UIView()
    let visualQueueCont = VisualQueueController()
    
    /*SET UP METHODS*/
    func setUp(){
        //set up the displayController and the displayView
        setUpController()
        setUpDisplay()
        visualQueueCont.library = library
        
        //add action listener here
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplay), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: peakMusicController.systemMusicPlayer)
    }
    
    func setUpController(){
        
        displayController = UISegmentedControl(frame: CGRect(x: bounds.minX + 40, y: bounds.minY, width: bounds.width - 80, height: 35))
        displayController.tintColor = UIColor.peakColor
        displayController.insertSegment(withTitle: "Queue", at: 0, animated: false)
        displayController.insertSegment(withTitle: "Lyrics", at: 0, animated: false)
        displayController.insertSegment(withTitle: "Info", at: 0, animated: false)
        displayController.addTarget(self, action: #selector(updateDisplay), for: .valueChanged)
        displayController.selectedSegmentIndex = 0
        addSubview(displayController)
    }
    
    func setUpDisplay(){
        
        infoDisplay = UIView(frame: CGRect(x: bounds.minX, y: bounds.minY + 40, width: bounds.width, height: bounds.height - 50))
        addSubview(infoDisplay)
    }
    
    
    /*DISPLAY UPDATE METHODS*/
    func updateDisplay(){

        //First Remove the current views from the display
        for view in infoDisplay.subviews {
            
            view.removeFromSuperview()
        }
        
        //Next Figure out what we should update the display with, and call the appropriate function
        if displayController.selectedSegmentIndex == 0 {
            
            updateWithSongInfo()
        } else if displayController.selectedSegmentIndex == 1{
            
            updateWithLyrics()
        } else if displayController.selectedSegmentIndex == 2 {
            
            updateWithQueue()
        }
        
    }
    
    private func updateWithSongInfo(){
        //Show the title, album and artist of the song
      
        if let song = peakMusicController.systemMusicPlayer.nowPlayingItem {
            
            let heightLarge = max(infoDisplay.frame.height * 0.05, 30)
            let heightSmall = max(infoDisplay.frame.height * 0.03, 25)
            
            //Show the title of the song
            let titleLabel = UILabel(frame: CGRect(x: bounds.minX, y: bounds.minY + 10, width: bounds.width, height: heightLarge))
            titleLabel.text = song.title
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
            titleLabel.adjustsFontForContentSizeCategory = true
            infoDisplay.addSubview(titleLabel)
            
            //Show the Album
            let albumLabel = UILabel(frame: CGRect(x: bounds.minX, y: titleLabel.frame.maxY + 10, width: bounds.width, height: heightSmall))
            albumLabel.text = song.albumTitle
            albumLabel.textAlignment = .center
            albumLabel.font = UIFont.systemFont(ofSize: 16)
            albumLabel.adjustsFontForContentSizeCategory = true
            infoDisplay.addSubview(albumLabel)
            
            //Show the Artist
            let artistLabel = UILabel(frame: CGRect(x: bounds.minX, y: albumLabel.frame.maxY + 10, width: bounds.width, height: heightLarge))
            artistLabel.text = song.artist
            artistLabel.textColor = UIColor.artistColor
            artistLabel.textAlignment = .center
            artistLabel.font = UIFont.systemFont(ofSize: 20, weight: 0.1)
            artistLabel.adjustsFontForContentSizeCategory = true
            artistLabel.backgroundColor = UIColor.clear
            infoDisplay.addSubview(artistLabel)
            
            /*Maybe add a show on Apple Music Here*/
        }
        
    }
    
    private func updateWithLyrics(){
        //show the lyrics to the song
        
    }
    
    private func updateWithQueue(){
        //show the queue of the current play queue
        
        //Delegate and Data Source
        
        let queue = UITableView(frame: infoDisplay.bounds)
        queue.rowHeight = 75
        queue.backgroundColor = UIColor.clear
        queue.delegate = visualQueueCont
        queue.dataSource = visualQueueCont
        infoDisplay.addSubview(queue)
        
    }
}
