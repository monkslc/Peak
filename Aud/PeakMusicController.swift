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
            if playerType == .Host {
                MPCManager.defaultMPCManager.advertiser.startAdvertisingPeer()
                (delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "Host-Icon"), for: .normal)
            }
            else {
                MPCManager.defaultMPCManager.advertiser.stopAdvertisingPeer()
                
            }
            
            if playerType == .Contributor {
                MPCManager.defaultMPCManager.browser.startBrowsingForPeers()
                
                    (delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "CommIconBig"), for: .normal)
            }
            else {
                MPCManager.defaultMPCManager.browser.stopBrowsingForPeers()
            }
            
            if playerType == .Individual{
                (delegate as! LibraryViewController).connectButton.setImage(#imageLiteral(resourceName: "IndieBigIcon"), for: .normal)
            }
            
            //Update the views here
            delegate?.playerTypeDidChange()
            
        }
        
    }
    
    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
    
    var currPlayQueue = [MPMediaItem](){
        
        didSet{ //When we set the queue, we want to update the musicPlayer
            
            systemMusicPlayer.setQueue(with: MPMediaItemCollection(items: currPlayQueue))
            systemMusicPlayer.prepareToPlay()
            
            SendingBluetooth.sendFullQue() // @CAM BLAHA HAHHAHA
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
    
    func play(artist: MPMediaItem){
        //Fetch the artists songs async and use play() to play the results
        
        let artistToPlay = artist.artist
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
    
    func play(album: MPMediaItem){
        //Fetch the album songs async and use play() to play the results
        
        
        let albumTitleToPlay = album.albumTitle
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
        
        
        //Check what type of player it is
        if playerType != .Contributor {
            
            currPlayQueue.append(contentsOf: songs)
            
            //now update the delegate
            delegate?.showSignifier()
            delegate?.updateDisplay()
        } else {
            
            /*******NEED: Implmepent sending the songId to another device**********/
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
        
        //Set the initally playing song and queue
        if peakMusicController.systemMusicPlayer.nowPlayingItem != nil {
            
            currPlayQueue = [peakMusicController.systemMusicPlayer.nowPlayingItem!]
        }
        
        
        //Now set the suffle mode to off so we can control the queue
        peakMusicController.systemMusicPlayer.shuffleMode = .off
        
        //Now begin generating playback notifications
        peakMusicController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    func warnUserOfRemovingQueueItems(_ songs: [MPMediaItem]){
        
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
