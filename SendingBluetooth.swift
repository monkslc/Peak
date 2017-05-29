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
    
    // from host
    
    static func sendFullQue() {
        //print(peakMusicController.currPlayQueue)
        SendingBluetooth.sendSongIds(songs: peakMusicController.currPlayQueue)
    }
    
    static func sendSongsToPeer(songs: [BasicSong], peerID: MCPeerID) {
        
        print("SEND SONG IDS \(songs) TO \(peerID)")
        
        var messageDictionary: [String: String] = [:]
        
        for (index, song) in songs.enumerated() {
            messageDictionary["\(index)-id"] = song.getId()
            messageDictionary["\(index)-type"] = "\(song.type.rawValue)"
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
    
    
    // from contributor
    
    static func sendSongIdToHost(song: BasicSong, error: () -> Void) {
        
        print("SENT TO \(MPCManager.defaultMPCManager.getDjName())")
        
        var messageDictionary: [String: String] = ["id": song.getId(), "type": "\(song.type.rawValue)"]
        
        if peakMusicController.musicType == .Spotify {
            messageDictionary["token"] = auth?.session.accessToken
        }
        
        if MPCManager.defaultMPCManager.session.connectedPeers.count > 0 {
            
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: MPCManager.defaultMPCManager.getDj()) {
                
                print("SENT")
            }
            
        }
        else {
            error()
        }
        
    }
    
    
    /* Private Functions */
    
    // from host
    
    static private func sendSongIds(songs: [BasicSong]) {
        
        var messageDictionary: [String: String] = [:]
        
        if peakMusicController.musicType == .Spotify {
            messageDictionary["token"] = auth?.session.accessToken
        }
        
        for (index, song) in songs.enumerated() {
            print(song)
            
            messageDictionary["\(index)-id"] = song.getId()
            print("SENDING URI: \(song.getId())")
            messageDictionary["\(index)-type"] = "\(song.type.rawValue)"
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                
            }
            else {
                print("\n\nERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient\n\n")
            }
        }
    }
    
}
