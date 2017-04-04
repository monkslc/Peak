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
      
        
        //if let song = peakMusicController.systemMusicPlayer.nowPlayingItem {
            
        let heightLarge = max(infoDisplay.frame.height * 0.05, 30)
        let heightSmall = max(infoDisplay.frame.height * 0.03, 25)
            
        //Show the title of the song
        let titleLabel = UILabel(frame: CGRect(x: bounds.minX, y: bounds.minY + 10, width: bounds.width, height: heightLarge))
        //titleLabel.text = song.title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.adjustsFontForContentSizeCategory = true
        infoDisplay.addSubview(titleLabel)
            
        //Show the Album
        let albumLabel = UILabel(frame: CGRect(x: bounds.minX, y: titleLabel.frame.maxY + 10, width: bounds.width, height: heightSmall))
        //albumLabel.text = song.albumTitle
        albumLabel.textAlignment = .center
        albumLabel.font = UIFont.systemFont(ofSize: 16)
        albumLabel.adjustsFontForContentSizeCategory = true
        infoDisplay.addSubview(albumLabel)
            
        //Show the Artist
        let artistLabel = UILabel(frame: CGRect(x: bounds.minX, y: albumLabel.frame.maxY + 10, width: bounds.width, height: heightLarge))
        //artistLabel.text = song.artist
        artistLabel.textColor = UIColor.artistColor
        artistLabel.textAlignment = .center
        artistLabel.font = UIFont.systemFont(ofSize: 20, weight: 0.1)
        artistLabel.adjustsFontForContentSizeCategory = true
        artistLabel.backgroundColor = UIColor.clear
        infoDisplay.addSubview(artistLabel)
            
        //Update the text depending on the player type
        if peakMusicController.playerType == .Contributor{
            
            if peakMusicController.groupPlayQueue.count > 0 {
                
                artistLabel.text = peakMusicController.groupPlayQueue[0].artistName
                albumLabel.text = peakMusicController.groupPlayQueue[0].collectionName
                titleLabel.text = peakMusicController.groupPlayQueue[0].trackName
            }
            
        }else {
            
            if let song = peakMusicController.systemMusicPlayer.nowPlayingItem {
                artistLabel.text = song.artist
                albumLabel.text = song.albumTitle
                titleLabel.text = song.title
            }
            
        }
        
    }
    
    private func updateWithLyrics(){
        
        //Create the text view
        let lyricOffset: CGFloat = 0.05
        let lyricsView = UITextView(frame: CGRect(x: bounds.width * lyricOffset, y: 0, width: bounds.width * (1-(2*lyricOffset)), height: infoDisplay.frame.height))
        lyricsView.isEditable = false
        lyricsView.backgroundColor = UIColor.clear
        lyricsView.font = UIFont.systemFont(ofSize: 15)
        infoDisplay.addSubview(lyricsView)
        
        
        
    
        
        if peakMusicController.playerType != .Contributor {
            //The player is not a contributor so the currently playing song will be in the system music player
            
            //First check if there is an item playing
            if let currentlyPlayingSong = peakMusicController.systemMusicPlayer.nowPlayingItem {
                
                //Use song struct to fetch the lyrics
                let song = Song(id: "", trackName: currentlyPlayingSong.title!, collectionName: "", artistName: currentlyPlayingSong.artist!, trackTimeMillis: 0, image: nil, dateAdded: nil)
               

                
                //get and pug lyrics into lyrics view
                ConnectingToInternet.getFullLyrics(song: song, completion: {(lyrics) in
                
                    
                    DispatchQueue.main.async {
                
                        //Add more spacing
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 5
                        let attributes = [NSParagraphStyleAttributeName : style]
                        lyricsView.attributedText = NSAttributedString(string: lyrics, attributes:attributes)
                        lyricsView.font = UIFont.systemFont(ofSize: 14)
                        //lyricsView.text = lyrics
                    }
                })
                
            }
            
    
        } else {
            //The player is a contributor so the currently playing song will be in the groupPlayQueue
            
            //First check if there is an item playing
            if peakMusicController.groupPlayQueue.count > 0 {
                
                let currentlyPlayingSong = peakMusicController.groupPlayQueue[0]
                
                //Fetch the lyrics and plug them into the lyrics view
                ConnectingToInternet.getFullLyrics(song: currentlyPlayingSong, completion: {(lyrics) in
                
                    DispatchQueue.main.async {
                        
                        lyricsView.text = lyrics
                    }
                })
                
            }
            
        }
        
    }
    
    private func updateWithQueue(){
        //show the queue of the current play queue
        
        
        let queue = UITableView(frame: infoDisplay.bounds)
        queue.rowHeight = 75
        queue.backgroundColor = UIColor.clear
        queue.delegate = visualQueueCont
        queue.dataSource = visualQueueCont
        infoDisplay.addSubview(queue)
        
    }
}
