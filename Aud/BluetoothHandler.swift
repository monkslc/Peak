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
        
        if peakMusicController.musicType == .Spotify {
            
            //fetch the song based on the title and artist
        }
        
        else {
            
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
        
    }
    
    func receivedSong(songId: String, songType: PeakMusicController.MusicType) {
        //Received a song from a contributor
        
        delegate?.showSignifier()
        
        //Check for the user's system music player
        if peakMusicController.musicType == .Spotify{
            
            switch songType{
            
            case .Spotify:
                addSpotifyToQueue(playableURI: songId)
                
            default: //Apple Music or Guest
                convertAppleMusicIDToURI(songID: songId)
                
                
            }
            
            
        } else if peakMusicController.musicType == .AppleMusic{

            //Switch on songType and add song to the queue
            switch songType{
                
            case .Spotify:
                convertSpotifyToAppleMusicID(playableURI: songId)
                
                
            default: //Apple Music or Guest
                addAppleMusicToQueue(songID: songId)
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
    
    func addSpotifyToQueue(playableURI: String){
        
        print("\n\n\n")
        print(playableURI)
        print("\n\n\n")
        
        //Take the URI and convert it into a track
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: nil, market: nil){ err, callback in
            
            if let song: SPTTrack = callback as? SPTTrack{
                
                print("\n\n\n")
                print(song.playableUri)
                print(song)
                print("\n\n\n")
                peakMusicController.playAtEndOfQueue([song])
            }
            
        }
        
    }
    
    func convertAppleMusicIDToURI(songID: String){
        
        //Take the songID and turn it into a song
        ConnectingToInternet.getSong(id: songID){
            
            //Get the title and artist
            let title = $0.getTrackName()
            let artist = $0.getArtistName()
            
            //Use the title and artist to search Spotify
            SPTSearch.perform(withQuery: title, queryType: SPTSearchQueryType.queryTypeTrack, accessToken: nil){ err, callback in
                
                //Use the callback to get the song
                if let page: SPTListPage = callback as? SPTListPage{
                    
                    for item in page.items{
                        
                        if let song: SPTPartialTrack = item as? SPTPartialTrack {
                            
                            if title == song.getTrackName() && artist == song.getArtistName(){
                                
                                //We have found the correct song so add it to the queue
                                peakMusicController.playAtEndOfQueue([song])
                                
                                break
                                
                            }
                        }
                    }
                }
            }
            
        }
        
        //Use the song title and artist to get a Spotify Song
        
        //Add the Spotify Song to the Queue
        
    
    }
    
    func convertSpotifyToAppleMusicID(playableURI: String){

        
        //Get the track from the URI
        
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: nil, market: nil){ err, callback in
            
            if err != nil{
                print(err!)
                return
            }
            
            if let callback: SPTTrack = callback as? SPTTrack{
                
                let title = callback.getTrackName()
                let artist = callback.getArtistName()
                
                ConvertingSongType.getAppleMusicId(songTitle: title, authourName: artist){
                    
                    
                    print("RECIEVED SONG \($0.getTrackName()) by \($0.getArtistName())")
                    print($0)
                    
                    let id = $0.getId()
                    self.addAppleMusicToQueue(songID: id)
                }
            }
    
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
        
        if let id = dataDictionary["id"], let type = PeakMusicController.MusicType(rawValue: Int(dataDictionary["type"]!)!) {
            receivedSong(songId: id, songType: type)
        }
        else {
            print("\n\nERROR: LibraryViewController.handleMPCDJRecievedSongIDWithNotification THIS SHOULD NEVER HAPPEN: \n\n")
        }
    }
    
    func handleMPCClientReceivedSongIdsWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        
        var songIds: [String] = []
        var songTypes: [PeakMusicController.MusicType] = []
        
        var index = 0
        while true {
            
            if let id = dataDictionary["\(index)-id"], let type = PeakMusicController.MusicType(rawValue: Int(dataDictionary["\(index)-type"]!)!) {
                songIds.append(id)
                songTypes.append(type)
            }
            else {
                break
            }
            
            index += 1
        }
        
        receivedGroupPlayQueue(songIds, songTypes: songTypes)
    }
}
