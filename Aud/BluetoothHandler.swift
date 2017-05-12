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
    func receivedGroupPlayQueue(_ songTitles: [String], songArtists: [String]) {
        
        if peakMusicController.musicType == .Spotify {
            
        
        }
        
        else {
            var tempSongHolder = [Song?].init(repeating: nil, count: songTitles.count)
            for i in 0..<songTitles.count {
                
                
                ConvertingSongType.getAppleMusicId(songTitle: songTitles[i], authourName: songArtists[i], completion: {
                    (song) -> Void in
                    
                    tempSongHolder[i] = song
                    
                    if let songs = tempSongHolder as? [Song] {
                        
                        DispatchQueue.main.async {
                            peakMusicController.groupPlayQueue = songs
                        }
                    }
                })
                
            }
        }
        
    }
    /*CHECK FOR URI OR APPLE MUSIC ID AND TURN INTO SONG*/
    
    func receivedSong(songTitle: String, aristName: String) {
        //Received a song from a contributor
        
        delegate?.showSignifier()
        
        //add the song to the user's library, async
        //Check for the user's system music player
        if peakMusicController.musicType == .Spotify{
            
            //Here we need to add Spotify to queue
            
            
        } else if peakMusicController.musicType == .AppleMusic{
            
            ConvertingSongType.getAppleMusicId(songTitle: songTitle, authourName: aristName){
                
                self.addAppleMusicToQueue(songID: $0.getId())
            }
            
        }
   
        
        
    }
    
    /*MARK: METHODS TO ADD A RECEIVED SONG TO THE PLAY QUEUE*/
    func addAppleMusicToQueue(songID: String){
        
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
        
        if let song = dataDictionary["song"], let artist = dataDictionary["artist"] {
            receivedSong(songTitle: song, aristName: artist)
        }
        else {
            print("\n\nERROR: LibraryViewController.handleMPCDJRecievedSongIDWithNotification THIS SHOULD NEVER HAPPEN: \n\n")
        }
    }
    
    func handleMPCClientReceivedSongIdsWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        
        var songNames: [String] = []
        var artistNames: [String] = []
        
        var index = 0
        while true {
            
            if let song = dataDictionary["\(index)-song"], let artist = dataDictionary["\(index)-artist"] {
                songNames.append(song)
                artistNames.append(artist)
            }
            else {
                break
            }
            
            index += 1
        }
        
        receivedGroupPlayQueue(songNames, songArtists: artistNames)
    }
}
