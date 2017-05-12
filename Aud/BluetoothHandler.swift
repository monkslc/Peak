//
//  BluetoothHandler.swift
//  Peak
//
//  Created by Connor Monks on 5/3/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer
import MultipeerConnectivity


protocol BluetoohtHandlerDelegate{
    
    func showSignifier()
}

class BluetoothHandler {
    
    /*MARK: PROPERTIES*/
    var delegate: BluetoohtHandlerDelegate?
    
    
    /*MARK: INITIALIZERS*/
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCNotification(notification:)), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }
    
    /*MARK Bluetooth Methods*/
    func receivedGroupPlayQueue(_ songIds: [String], songTypes: [PeakMusicController.MusicType]) {
        
        var tempSongHolder = [Song?].init(repeating: nil, count: songIds.count)
        for i in 0..<songIds.count {
            
            ConnectingToInternet.getSong(id: songIds[i], completion: {(song) in
                tempSongHolder[i] = song
                
                if let songs = tempSongHolder as? [Song] {
                    
                    DispatchQueue.main.async {
                        peakMusicController.groupPlayQueue = songs
                    }
                }
            })
        }
        
    }
    /*CHECK FOR URI OR APPLE MUSIC ID AND TURN INTO SONG*/
    
    func receivedSong(_ songID: String, songType: PeakMusicController.MusicType) {
        //Received a song from a contributor
        
        delegate?.showSignifier()
        
        //add the song to the user's library, async
        //Check for the user's system music player
        if peakMusicController.musicType == .Spotify{
            
            //Check for what song type is received
            if songType == .Spotify{
                
                //Add the spotify song to the playlist
                addSpotifyFromSpotify(playableURI: songID)
                
            } else { //Apple Music or Geust
                
                addSpotifyFromAppleMusic(songID: songID)
            }
            
            
        } else if peakMusicController.musicType == .AppleMusic{
            
            //Check for what type of song was received
            if songType == .Spotify{
                
                addAppleMusicFromSpotify(playableURI: songID)
                
            } else{ //Apple Music or Guest
                
                addAppleMusicFromAppleMusic(songID: songID)
            }
            
        }
        
        switch songType{
            
        case .Spotify:
            break
            
        default:
            break
            
        }
        
        
    }
    
    /*MARK: METHODS TO ADD A RECEIVED SONG TO THE PLAY QUEUE*/
    func addAppleMusicFromAppleMusic(songID: String){
        
        DispatchQueue.global().async {
            
            var song = MPMediaItem()
            let library = MPMediaLibrary()
            
            library.addItem(withProductID: songID, completionHandler: {(ent, err) in
                
                //add the entity to the queue
                if ent.count > 0 {
                    song = ent[0] as! MPMediaItem
                    
                    DispatchQueue.main.async {
                        peakMusicController.playAtEndOfQueue([song])
                    }
                }
                else {
                    print("\n\n\nHUGE ERROR\nSONG \(songID) DID NOT SEND\nI THINK TRACK NOT AVAILABLE THROUGH APPLE MUSIC\n\n")
                }
                
            })
        }
    }
    
    func addSpotifyFromSpotify(playableURI: String){
        
        //Use the URI to fetch a spotify track
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: auth?.session.accessToken, market: "from_token"){ err, callback in
            
            print("In track callback")
            if let page: SPTListPage = callback as? SPTListPage{
                
                print("We let page")
                if page.items.count > 0{
                    
                    print("Count was greater")
                    let song = page.items[0] as! SPTTrack
                    peakMusicController.playAtEndOfQueue([song])
                    print("Should have added")
                }
            }
                
        }
        
        
    }
    
    func addAppleMusicFromSpotify(playableURI: String){
        
        print("Should be adding apple music from spotify")
        
        if auth?.session == nil{
            
            print("Our session was nil")
        }
        
        /*THIS IS WHERE IT'S NIL*/
        if auth?.session.accessToken == nil{
            
            print("OUR ACCESS TOKEN WAS NIL")
        }
        
        //Take the uri and convert it into a spotify song
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: auth?.session.accessToken, market: "nil"){ err, callback in
            
            print("We are in the requeset about to try and let")
            if let page: SPTListPage = callback as? SPTListPage{
                
                print("The page was in fact an SPTListPage")
                if page.items.count > 0{
                    
                    print("Our items count was > 0")
                    let song = page.items[0] as! SPTTrack
                    
                    let songTitle = song.getTrackName()
                    let songArtist = song.getArtistName()
                    
                    //Use the song title and artist to get the Apple Music Song
                    ConvertingSongType.getAppleMusicId(songTitle: songTitle, authourName: songArtist){
                        
                        //Call addAppleMusicFromAPpleMusic to add it to the play queue
                        self.addAppleMusicFromAppleMusic(songID: $0)
                    }
                    
                    
                }
            }
            
        }
        
        
    }
    
    func addSpotifyFromAppleMusic(songID: String){
        
        //Use the songID to fetch a Apple Music Song
        
        //Use the song title and artist to get the spotify song
        
        //Add teh spotify song to the curr play queue
    }
    
    /*RECEIVED */
    
    /*MARK Notification Methods*/
    @objc func handleMPCNotification(notification: NSNotification) {
        
        
        switch peakMusicController.playerType {
        case .Host:
            handleMPCDJRecievedSongIDWithNotification(notification: notification)
        case .Contributor:
            handleMPCClientReceivedSongIdsWithNotification(notification: notification)
        default:
            print("\n\nERROR: THIS SHOULD NEVER HAPPEN LibraryViewController -> handleMPCNotification\n\n")
        }
    }
    
    func handleMPCDJRecievedSongIDWithNotification(notification: NSNotification) {
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        if let id = dataDictionary["id"], let type = Int(dataDictionary["type"]!) {
            receivedSong(id, songType: PeakMusicController.MusicType(rawValue: type)!)
        }
        else {
            print("\n\nERROR: LibraryViewCOntroller.handleMPCDJRecievedSongIDWithNotification THIS SHOULD NEVER HAPPEN: \n\n")
        }
    }
    
    func handleMPCClientReceivedSongIdsWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        
        var songIDs: [String] = []
        var songTypes: [PeakMusicController.MusicType] = []
        
        var index = 0
        while true {
            
            if let id = dataDictionary["\(index)-id"], let type = PeakMusicController.MusicType(rawValue: Int(dataDictionary["\(index)-type"]!)!) {
                songIDs.append(id)
                songTypes.append(type)
            }
            else {
                break
            }
            
            index += 1
        }
        
        receivedGroupPlayQueue(songIDs, songTypes: songTypes)
    }
}
