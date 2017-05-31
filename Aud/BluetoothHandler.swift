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
    func receivedGroupPlayQueue(_ songIds: [String], songTypes: [PeakMusicController.MusicType], token: String?) {
        
        print("RECIEVED GROUP PLAY QUE \(songIds)  \(songTypes))")
        
        if songTypes.count > 0 {
            
            switch songTypes[0]{
                
            case .Spotify:
                spotifyReceived(songIds, token: token!)
                
                
            default: //Apple Music or Guest
                appleMusicReceived(songIds)
            }
            
        }
        else {
            print("HUGE ERROR! SONG TYPES RECIEVED NOT GREATER THAN 0 IN BluetoothHandler -> receivedGroupPlayQueue")
        }
        
    }
    
    /*MARK METHODS TO CONVERT SONG ID'S RECEIVED TO THE GROUP PLAY QUEUE*/
    private func spotifyReceived(_ songs: [String], token: String){
        
        print("SPOTIFY RECIEVED \(songs)")
        
        if songs.count > 0{
            
            var spotifyURIArray = [URL]()
            
            //Convert the ids to URIs
            for song in songs{
                
                spotifyURIArray.append(URL(string: song)!)
            }
            
            
            SPTTrack.tracks(withURIs: spotifyURIArray, accessToken: token, market: nil){ err, callback in
                
                if err != nil{
                    
                    print("\n\nError converting me tracks: \(err!) \n\n")
                }
                
                
                if let songsBack: [SPTTrack] = callback as? [SPTTrack]{
                    
                    peakMusicController.groupPlayQueue = songsBack
                }
            }
            
            /*
            if peakMusicController.musicType == .Spotify{
                
                SPTTrack.tracks(withURIs: spotifyURIArray, accessToken: auth?.session.accessToken, market: nil){ err, callback in
                    
                    if err != nil{
                        
                        print("\n\nError converting me tracks: \(err!) \n\n")
                    }
                    
                    
                    if let songsBack: [SPTTrack] = callback as? [SPTTrack]{
                        
                        peakMusicController.groupPlayQueue = songsBack
                    }
                }
            } else{
                
                
                SPTTrack.tracks(withURIs: spotifyURIArray, accessToken: nil, market: nil){ err, callback in
                    
                    if err != nil{
                        
                        print("\n\nError converting me tracks: \(err!) \n\n")
                    }
                    
                    
                    if let songsBack: [SPTTrack] = callback as? [SPTTrack]{
                        
                        peakMusicController.groupPlayQueue = songsBack
                    }
                }

            }*/
            
        }
    
        
    }
    
    private func appleMusicReceived(_ songs: [String]){
        
        print("APPLE MUSIC RECIEVED \(songs)")
        
        var tempSongHolder = [Song?].init(repeating: nil, count: songs.count)
        for i in 0..<songs.count {
            
            ConnectingToInternet.getSong(id: songs[i], completion: {(song) in
                tempSongHolder[i] = song
                
                if let songs = tempSongHolder as? [Song] {
                    
                    DispatchQueue.main.async {
                        peakMusicController.groupPlayQueue = songs
                    }
                }
            })
        }
    }
    
    func receivedSong(songId: String, songType: PeakMusicController.MusicType, token: String?) {
        //Received a song from a contributor
        
        print("RECIEVED SONG \(songId) TYPE: \(songType)")
        
        DispatchQueue.main.async {
            self.delegate?.showSignifier()
        }
        
        //Check for the user's system music player
        if peakMusicController.musicType == .Spotify{
            
            switch songType{
            
            case .Spotify:
                addSpotifyToQueue(playableURI: songId, token: token!)
                
            default: //Apple Music or Guest
                convertAppleMusicIDToURI(songID: songId)
                
                
            }
            
            
        } else if peakMusicController.musicType == .AppleMusic{

            //Switch on songType and add song to the queue
            switch songType{
                
            case .Spotify:
                convertSpotifyToAppleMusicID(playableURI: songId, token: token!)
                
                
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
    
    func addSpotifyToQueue(playableURI: String, token: String) {
        
        
        //Take the URI and convert it into a track
        
        print("URI: \(playableURI)")
        print("TOKEN: \(token)")
        
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: token, market: nil){ err, callback in
            
            if let error = err {
                print(error)
                return
            }
            
            if let song: SPTPartialTrack = callback as? SPTPartialTrack {
                
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
            SPTSearch.perform(withQuery: title, queryType: SPTSearchQueryType.queryTypeTrack, accessToken: auth?.session.accessToken){ err, callback in
                
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
    
    func convertSpotifyToAppleMusicID(playableURI: String, token: String) {

        
        //Get the track from the URI
        
        SPTTrack.track(withURI: URL(string: playableURI), accessToken: token, market: nil){ err, callback in
            
            if err != nil{
                print(err!)
                return
            }
            
            if let callback: SPTTrack = callback as? SPTTrack {
                
                let title = callback.getTrackName()
                let artist = callback.getArtistName()
                
                ConvertingSongType.getAppleMusicId(songTitle: title, authourName: artist){
                    
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
        
        print("RECIEVED BELOW")
        print(dataDictionary)
        
        if let id = dataDictionary["id"], let type = PeakMusicController.MusicType(rawValue: Int(dataDictionary["type"]!)!) {
            
            let token = dataDictionary["token"]
            
            receivedSong(songId: id, songType: type, token: token)
        }
        else {
            print("\n\nERROR: LibraryViewController.handleMPCDJRecievedSongIDWithNotification THIS SHOULD NEVER HAPPEN: \n\n")
        }
    }
    
    func handleMPCClientReceivedSongIdsWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        let token = dataDictionary["token"]
        
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
        
        receivedGroupPlayQueue(songIds, songTypes: songTypes, token: token)
    }
}
