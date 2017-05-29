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
}

class PeakMusicController {

    
    init(){
        
        print("We are initalizing it")
        NotificationCenter.default.addObserver(self, selector: #selector(songChanged(_:)), name: .systemMusicPlayerNowPlayingChanged, object: nil)
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
            
            switch playerType{
                
            case .Contributor:
                systemMusicPlayer?.stopGeneratingNotifications()
                systemMusicPlayer?.stopPlaying()
                peakMusicController.currPlayQueue = []
                
                
            default:
                print("Gonna try to generate Notifications here")
                systemMusicPlayer?.generateNotifications()
                
            }

        }
        
    }
    
    enum MusicType: Int {
        //enum to determine how the user is going to listen to music
        
        case AppleMusic = 0
        case Guest
        case Spotify
    }
    
    var musicType = MusicType.Guest {
        
        didSet{
            
            //Send a notification
            NotificationCenter.default.post(Notification(name: .musicTypeChanged))
        }
    }
    
    var systemMusicPlayer: SystemMusicPlayer!   //MPMusicPlayerController.systemMusicPlayer()
    
    var currPlayQueue = [BasicSong](){
        
        didSet{ //When we set the queue, we want to update the musicPlayer
            
            NotificationCenter.default.post(Notification(name: .currPlayQueueChanged))
            
            systemMusicPlayer?.setPlayerQueue(songs: currPlayQueue)
            systemMusicPlayer?.preparePlayerToPlay()
            
            if playerType == .Host{
                SendingBluetooth.sendFullQue()
            }
           
        }
    }

    
    //play queue for a contributor
    var groupPlayQueue = [BasicSong](){
        
        didSet{
            
            NotificationCenter.default.post(Notification(name: .groupQueueChanged))
        }
    }
    
    
    /*QUEUE METHODS*/
    func play(_ songs: [BasicSong]){
        
        //Check if there are currently items in the users queue, to warn them that they will no longer be there
        if currPlayQueue.count > 1 {
            
            warnUserOfRemovingQueueItems(songs)
        } else {
            
            currPlayQueue = songs
            systemMusicPlayer?.startPlaying() //Need to play here in case the music player is paused
        }
    }
    
    func play(artist: [BasicSong]){
        //Fetch the artists songs async and use play() to play the results
        
        //check if we are playing an apple music or spotify artist
        if let song: MPMediaItem = artist[0] as? MPMediaItem{
            
            let artistToPlay = song.getArtistName()
            var mediaItemsToPlay = [BasicSong]()
            
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
        } else if let artistSong: SPTTrack = artist[0] as? SPTTrack{
            
            //Get the user's spotify library
            SPTYourMusic.savedTracksForUser(withAccessToken: auth?.session.accessToken){ err, callback in
                
                //check if we got an error
                if err != nil{
                    print(err!)
                    return
                }
                
                //holder variable for items in the album
                var artistItems = [SPTTrack]()
                
                //No error so let's fetch the songs
                if let songPage: SPTListPage = callback as? SPTListPage{
                    
                    for song in songPage.items{
                        
                        
                        if let songCheck: SPTTrack = song as? SPTTrack{
                            
                            //check if the song is in the correct artist
                            if songCheck.getArtistName() == artistSong.getArtistName(){
                                
                               
                                artistItems.append(songCheck)
                            }
                        }
                    }
                }
                
                //Let's shuffle the items and then play them
                artistItems = self.shuffleQueue(shuffle: artistItems) as! [SPTTrack]
                
                //Now let's play the artist
                self.play(artistItems)
                
            }
            
        } else{
            
            print("\n\nWARNING WE DID NOT GET APPLE MUSIC OR SPOTIFY\n\n")
        }
        
    }
    
    func play(album: [BasicSong]){
        //Fetch the album songs async and use play() to play the results
        
        
        //Check if we are playing Apple Music or Spotify 
        if let song: MPMediaItem = album[0] as? MPMediaItem{
            //APPLE MUSIC
            
            let albumTitleToPlay = song.getCollectionName()
            var mediaItemsToPlay = [BasicSong]()
            
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
        } else if let albumSong: SPTTrack = album[0] as? SPTTrack{
            
            //Get the user's spotify library
            SPTYourMusic.savedTracksForUser(withAccessToken: auth?.session.accessToken){ err, callback in
                
                //check if we got an error
                if err != nil{
                    print(err!)
                    return
                }
                
                //holder variable for items in the album
                var albumItems = [SPTTrack]()
                
                //No error so let's fetch the songs
                if let songPage: SPTListPage = callback as? SPTListPage{
                    
                    for song in songPage.items{
                        
                        
                        if let songCheck: SPTTrack = song as? SPTTrack{
                            
                            //check if the song is in the correct albums
                            if songCheck.getCollectionName() == albumSong.album.name{
                                
                                //it does equal so add it to the album
                                albumItems.append(songCheck)
                            }
                        }
                    }
                }
                
                //Let's shuffle the items and then play them
                albumItems = self.shuffleQueue(shuffle: albumItems) as! [SPTTrack]
                
                //Now let's play the album
                self.play(albumItems)
                
            }
            
        } else{
            
            print("\n\nWARNING NEITHER APPLE MUSIC NOR SPOTIFY\n\n")
        }
        
        
    }
    
    func playNext(_ songs: [BasicSong]){
        
        //Append if the the systemMusicPlayer is at the end of the queue, or the queue is equal to 0
        if systemMusicPlayer.getNowPlayingItemLoc() == currPlayQueue.count - 1 || currPlayQueue.count == 0 || currPlayQueue.count == 1 {
            
            currPlayQueue.append(contentsOf: songs)
        } else {
            
            for song in songs{
                
                currPlayQueue.insert(song, at: systemMusicPlayer.getNowPlayingItemLoc() + 1)
            }
            
        }
        
    }
    
    func playAtEndOfQueue(_ songs: [BasicSong]) {
        
        //Just to be sure the player isn't a contributor
        if playerType != .Contributor {
            
            currPlayQueue.append(contentsOf: songs)
        }
        
    }
    
    func shuffleQueue(shuffle songs: [BasicSong]) -> [BasicSong]{
        
        var songsToShuffle = songs
        
        var placeHolderQueue = [BasicSong]()
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
            
            if (systemMusicPlayer.getNowPlayingItem()?.isEqual(to: currPlayQueue[1])) == true{
                
                currPlayQueue.remove(at: 0)
            }
        }
    }
    
    
    func setUp(){
        //called when initially created to set up the music player for playing
        
        if musicType == .AppleMusic{
            
            //Set the initally playing song and queue
            if peakMusicController.systemMusicPlayer.getNowPlayingItem() != nil {
                
                currPlayQueue = [peakMusicController.systemMusicPlayer.getNowPlayingItem()!]
            }
            
            //Now set the suffle mode to off so we can control the queue
            peakMusicController.systemMusicPlayer.setShuffleState(state: .off)
            
            //Now set the notifications
            peakMusicController.systemMusicPlayer.generateNotifications()
            
        } else if peakMusicController.musicType == .Guest{
            
            currPlayQueue = []
            systemMusicPlayer.setNowPlayingItemToNil()
        } else if peakMusicController.musicType == .Spotify{
            
            systemMusicPlayer.generateNotifications()
        }
        
    }
    
    func warnUserOfRemovingQueueItems(_ songs: [BasicSong]){
        
        //Check if the user is adding an artist or just one song
        if songs.count > 1 {
            //We are adding multiple songs
            
            let alert = UIAlertController(title: "Warning", message: "You currently have items in your queue. How would you like to proceed?", preferredStyle: .alert)
            
            //Give a play now option
            alert.addAction(UIAlertAction(title: "Play Songs Now", style: .default, handler: {(alert) in
            
                self.currPlayQueue = songs
                self.systemMusicPlayer.startPlaying()
            }))
            
            //Give a play next option
            alert.addAction(UIAlertAction(title: "Play Songs Next", style: .default, handler: {(alert) in
            
                self.delegate?.showSignifier()
                self.playNext(songs)
            }))
            
            //Give a play last option
            alert.addAction(UIAlertAction(title: "Play Songs Last", style: .default, handler: {(alert) in
            
                self.delegate?.showSignifier()
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
                self.systemMusicPlayer.startPlaying()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            
            if let alertDelegate:UIViewController = delegate as? UIViewController {
                
                alertDelegate.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}
