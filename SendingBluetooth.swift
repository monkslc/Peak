//
//  SendingBluetooth.swift
//  Peak
//
//  Created by Cameron Monks on 3/28/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import MediaPlayer
import MultipeerConnectivity

class SendingBluetooth {
    
    
    /* Public Functions */
    
    // from contributor
    
    static func sendSongIdToHost(song: BasicSong, error: () -> Void) {
        
        print("SENT TO \(MPCManager.defaultMPCManager.getDjName())")
        
        let messageDictionary: [String: String] = ["id": song.getId(), "type": "\(song.type.hashValue)"]
        
        if MPCManager.defaultMPCManager.session.connectedPeers.count > 0 {
            
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: MPCManager.defaultMPCManager.getDj()) {
                
                print("SENT")
            }
            
        }
        else {
            error()
        }
        
    }
    
    
    // from host
    
    static func sendFullQue() {
        switch peakMusicController.musicType {
        case .AppleMusic:
            SendingBluetooth.sendSongIds(songs: peakMusicController.currPlayQueue)
        case .Spotify:
            break
        default:
            break
        }
    }
    
    /*
    static func sendSongIdsFromHost(songs: [BasicSong]) {
        getSongIds(songs: songs, completion: {
            (songIds) -> Void in
            
            for peers in MPCManager.defaultMPCManager.session.connectedPeers {
                if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: songIds, toPeer: peers as MCPeerID) {
                    
                    
                }
                else {
                    print("\n\nERROR SENDING DATA COULD HAPPEN MultipeerConnectivity -> sendSongIdsFromHost\n\n")
                }
            }
            
        })
    }
    */
    
    static func sendSongsToPeer(songs: [BasicSong], peerID: MCPeerID) {
        
        var messageDictionary: [String: String] = [:]
        
        for (index, song) in songs.enumerated() {
            messageDictionary["\(index)-id"] = song.getId()
            messageDictionary["\(index)-type"] = "\(song.type)"
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if peers == peerID {
                if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                    //SPTTrack().playableUri
                    
                }
                else {
                    print("\n\nERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient\n\n")
                }
            }
        }
    }
    
    
    /* Private Functions */
    
    // from host
    
    static private func sendSongIds(songs: [BasicSong]) {
        
        var messageDictionary: [String: String] = [:]
        
        for (index, song) in songs.enumerated() {
            messageDictionary["\(index)-id"] = song.getId()
            messageDictionary["\(index)-type"] = "\(song.type.hashValue)"
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                
            }
            else {
                print("\n\nERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient\n\n")
            }
        }
    }
    
    static private func getSongIds(songs: [BasicSong], completion: @escaping ([String: String]) -> Void) {
        
        var songIds: [String: String] = [:]
        
        for (index, song) in songs.enumerated() {
            
            ConnectingToInternet.getSongs(searchTerm: "\(song.getArtistName()) \(song.getTrackName())".replacingOccurrences(of: " ", with: "%20"), limit: 2, sendSongsAlltogether: true, completion: {
                (sentSongs) -> Void in
                
                songIds["\(index)"] = sentSongs[0].id
                
                if songIds.count == songs.count {
                    completion(songIds)
                }
            })
        }
    }

}
