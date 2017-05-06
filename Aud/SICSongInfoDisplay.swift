//
//  SICSongInfoDisplay.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class SICSongInfoDisplay: UIView {

    
    /*MARK: Properties*/
    var displayingSegment = 0{
        
        didSet{
            updateInfo()
        }
    }
    
    let visualQueueDel = VisualQueueController()
    
    /*MARK: Initializers*/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Add listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: .systemMusicPlayerNowPlayingChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: .groupQueueChanged, object: nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    /*MARK: Listener Method*/
    func updateInfo(){
        //Get's called by notification when the song changes on system music player
        //Get's called when we change which segment we are displaying
        
        //Remove all subviews first
        for view in subviews{
            view.removeFromSuperview()
        }
        
        //Check what we should be displaying
        if displayingSegment == 0{
            
            displaySongInfo()
            
        }else if displayingSegment == 1{
            
            displayQueue()
        }
    }
    
    
    /*MARK: Display Methods*/
    func displaySongInfo(){
        
        let heightLarge = max(frame.height * 0.05, 30)
        let heightSmall = max(frame.height * 0.03, 25)
        
        //Show the title of the song
        let titleLabel = UILabel(frame: CGRect(x: bounds.minX, y: bounds.minY + 10, width: bounds.width, height: heightLarge))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)
        
        //Show the Album
        let albumLabel = UILabel(frame: CGRect(x: bounds.minX, y: titleLabel.frame.maxY + 10, width: bounds.width, height: heightSmall))
        albumLabel.textAlignment = .center
        albumLabel.font = UIFont.systemFont(ofSize: 16)
        albumLabel.adjustsFontForContentSizeCategory = true
        albumLabel.isUserInteractionEnabled = false
        addSubview(albumLabel)
        
        //Show the Artist
        let artistLabel = UILabel(frame: CGRect(x: bounds.minX, y: albumLabel.frame.maxY + 10, width: bounds.width, height: heightLarge))
        artistLabel.textColor = UIColor.artistColor
        artistLabel.textAlignment = .center
        artistLabel.font = UIFont.systemFont(ofSize: 20, weight: 0.1)
        artistLabel.adjustsFontForContentSizeCategory = true
        artistLabel.backgroundColor = UIColor.clear
        artistLabel.isUserInteractionEnabled = false
        addSubview(artistLabel)
        
        //Update the text depending on the player type
        if peakMusicController.playerType == .Contributor{
            
            if peakMusicController.groupPlayQueue.count > 0 {
                
                artistLabel.text = peakMusicController.groupPlayQueue[0].artistName
                albumLabel.text = peakMusicController.groupPlayQueue[0].collectionName
                titleLabel.text = peakMusicController.groupPlayQueue[0].trackName
            }
            
        }else {
            
            if let song = peakMusicController.systemMusicPlayer.getNowPlayingItem() {
                artistLabel.text = song.getArtistName()
                albumLabel.text = song.getCollectionName()
                titleLabel.text = song.getTrackName()
            }
            
        }
    }
    
    func displayQueue(){
        
        let queue = UITableView(frame: bounds)
        queue.rowHeight = 75
        queue.backgroundColor = UIColor.clear
        queue.delegate = visualQueueDel
        queue.dataSource = visualQueueDel
        queue.cellLayoutMarginsFollowReadableWidth = false
        addSubview(queue)
        
    }
}
