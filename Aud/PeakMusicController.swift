//
//  PeakMusicPlayer.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PeakMusicControllerDelegate{
    
    func showSignifier()
    func updateDisplay()
    func playerTypeDidChange()
}

class PeakMusicController {

    
    init(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(songChanged(_:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: systemMusicPlayer)
    }
    
    var delegate: PeakMusicControllerDelegate?
    
    enum PlayerType {
        //Enum to determine what the connection status is for the music player
        //will determine how the program responds
        
        case Host //Device connected to the audio player
        case Contributor //Connected to a host
        case Individual //Just playing indivdually
    }
    
    var playerType = PlayerType.Individual {
        didSet {
            
            //send the notification
            NotificationCenter.default.post(Notification(name: .playerTypeChanged))
            
            
            if playerType == .Host {
                
                systemMusicPlayer.beginGeneratingPlaybackNotifications()
                
                MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
                (delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "Host-Icon"), for: .normal)
                delegate?.updateDisplay()
            }
            else {
                MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
                
            }
            
            if playerType == .Contributor {
                MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
                
                systemMusicPlayer.endGeneratingPlaybackNotifications()
                
                DispatchQueue.main.async {
                    (self.delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "CommIconBig"), for: .normal)
                }
            }
            else {
                MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            }
            
            if playerType == .Individual{
                
                systemMusicPlayer.beginGeneratingPlaybackNotifications()
                
                (delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "IndieBigIcon"), for: .normal)
            }
            
            //Update the views here
            delegate?.playerTypeDidChange()
            
        }
        
    }
    
    enum MusicType {
        //enum to determine how the user is going to listen to music
        
        case AppleMusic
        case Guest
    }
    
    var musicType = MusicType.Guest {
        
        didSet{
            
            //Send a notification
            NotificationCenter.default.post(Notification(name: .musicTypeChanged))
        }
    }
    
    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
    
    var currPlayQueue = [MPMediaItem](){
        
        didSet{ //When we set the queue, we want to update the musicPlayer
            
            systemMusicPlayer.setQueue(with: MPMediaItemCollection(items: currPlayQueue))
            systemMusicPlayer.prepareToPlay()
            
            if playerType == .Host{
                SendingBluetooth.sendFullQue()
            }
           
        }
    }

    
    //play queue for a contributor
    var groupPlayQueue = [Song](){
        
        didSet{
            
            //Here we want to update the visuals
            DispatchQueue.main.async {
            
                self.delegate?.updateDisplay()
            }
        }
    }
    
    
    
    
    /*QUEUE METHODS*/
    func play(_ songs: [MPMediaItem]){
        
        //Check if there are currently items in the users queue, to warn them that they will no longer be there
        if currPlayQueue.count > 1 {
            
            warnUserOfRemovingQueueItems(songs)
        } else {
            
            currPlayQueue = songs
            systemMusicPlayer.play() //Need to play here in case the music player is paused
        }
    }
    
    func play(artist: [MPMediaItem]){
        //Fetch the artists songs async and use play() to play the results
        
        let artistToPlay = artist[0].artist
        var mediaItemsToPlay = [MPMediaItem]()
        
        //fetch the songs from the artist and add the to the queue
        DispatchQueue.global().async {
            
            let artistCollection = MPMediaQuery.artists().collections
            for theArtist in artistCollection! {
                
                if theArtist.representativeItem?.artist == artistToPlay {
                    
                    mediaItemsToPlay = theArtist.items
                    break
                }
            }
            
            //shuffle the media items to play
            mediaItemsToPlay = self.shuffleQueue(shuffle: mediaItemsToPlay)
            
            DispatchQueue.main.async {
                
                self.play(mediaItemsToPlay)
            }
        }
    }
    
    func play(album: [MPMediaItem]){
        //Fetch the album songs async and use play() to play the results
        
        
        let albumTitleToPlay = album[0].albumTitle
        var mediaItemsToPlay = [MPMediaItem]()
        
        //fetch the songs from the album and add them to the queue
        DispatchQueue.global().async {
            
            let albumCollection = MPMediaQuery.albums().collections
            for theAlbum in albumCollection! {
                
                if theAlbum.representativeItem?.albumTitle == albumTitleToPlay {
                    mediaItemsToPlay = theAlbum.items
                    break
                }
            }
            
            //shuffle the mediaItems to player
            mediaItemsToPlay = self.shuffleQueue(shuffle: mediaItemsToPlay)
            
            DispatchQueue.main.async {
                
                self.play(mediaItemsToPlay)
            }
        }
        
    }
    
    func playNext(_ songs: [MPMediaItem]){
        
        //insert a song or songs at one after the index of the currently playing view
        //Append if the the systemMusicPlayer is at the end of the queue, or the queue is equal to 0
        if systemMusicPlayer.indexOfNowPlayingItem == currPlayQueue.count - 1 || currPlayQueue.count == 0 || currPlayQueue.count == 1 {
            
            currPlayQueue.append(contentsOf: songs)
        } else {
            
            for song in songs{
                
                currPlayQueue.insert(song, at: systemMusicPlayer.indexOfNowPlayingItem + 1)
            }
            
        }
        
        //update the delegate
        delegate?.showSignifier()
        delegate?.updateDisplay()
    }
    
    func playAtEndOfQueue(_ songs: [MPMediaItem]) {
        
        //Just to be sure the player isn't a contributor
        if playerType != .Contributor {
            
            currPlayQueue.append(contentsOf: songs)
            
            //now update the delegate
            delegate?.showSignifier()
            delegate?.updateDisplay()
        }
        
    }
    
    func shuffleQueue(shuffle songs: [MPMediaItem]) -> [MPMediaItem]{
        
        var songsToShuffle = songs
        
        var placeHolderQueue = [MPMediaItem]()
        for _ in 0..<songs.count {
            
            //Get a random song from songs
            let randomSongIndex = Int(arc4random_uniform(UInt32(songsToShuffle.count)))
            
            //add it to the placeholderqueue
            placeHolderQueue.append(songsToShuffle[randomSongIndex])
            
            //remove it from songs so we don't add it again
            songsToShuffle.remove(at: randomSongIndex)
            
            
        }
        
        return placeHolderQueue
    }
    
    /*END OF QUEUE METHODS*/
    
    /*Notification Methods*/
    @objc func songChanged(_ notification: NSNotification){
        
        /*Pop Songs From the Beginning of the queue after they are done playing*/
        //We do this to make the play queue easy to update
        if peakMusicController.currPlayQueue.count > 1{
            
            if systemMusicPlayer.nowPlayingItem == currPlayQueue[1] {
                
                currPlayQueue.remove(at: 0)
            }
        }
    }
    
    
    func setUp(){
        //called when initially created to set up the music player for playing
        
        if musicType == .AppleMusic{
            
            //Set the initally playing song and queue
            if peakMusicController.systemMusicPlayer.nowPlayingItem != nil {
                
                currPlayQueue = [peakMusicController.systemMusicPlayer.nowPlayingItem!]
            }
            
            
            //Now set the suffle mode to off so we can control the queue
            peakMusicController.systemMusicPlayer.shuffleMode = .off
            
            //Now set the notifications
            
            peakMusicController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        } else if peakMusicController.musicType == .Guest{
            
            currPlayQueue = []
            systemMusicPlayer.nowPlayingItem = nil
        }
        
    }
    
    func warnUserOfRemovingQueueItems(_ songs: [MPMediaItem]){
        
        //Check if the user is adding an artist or just one song
        if songs.count > 1 {
            //We are adding multiple songs
            
            let alert = UIAlertController(title: "Warning", message: "You currently have items in your queue. How would you like to proceed?", preferredStyle: .alert)
            
            //Give a play now option
            alert.addAction(UIAlertAction(title: "Play Songs Now", style: .default, handler: {(alert) in
            
                self.currPlayQueue = songs
                self.systemMusicPlayer.play()
            }))
            
            //Give a play next option
            alert.addAction(UIAlertAction(title: "Play Songs Next", style: .default, handler: {(alert) in
            
                self.playNext(songs)
            }))
            
            //Give a play last option
            alert.addAction(UIAlertAction(title: "Play Songs Last", style: .default, handler: {(alert) in
            
                self.playAtEndOfQueue(songs)
            }))
            
            //Give a cancel option
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            if let alertDelegate: UIViewController = delegate as? UIViewController {
                
                alertDelegate.present(alert, animated: true, completion: nil)
            }
            
        } else{
            
            let alert = UIAlertController(title: nil, message: "You currently have items in your queue, are you sure you want to remove them?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                
                self.currPlayQueue = songs
                self.systemMusicPlayer.play()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            
            if let alertDelegate:UIViewController = delegate as? UIViewController {
                
                alertDelegate.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}
