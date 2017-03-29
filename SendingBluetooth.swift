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
    
    static func sendSongIdsWithPeerId(ids: [String], peerID: MCPeerID) {
        var messageDictionary: [String: String] = [:]
        
        for (index, id) in ids.enumerated() {
            messageDictionary["\(index)"] = id
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if peers == peerID {
                if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                    print("Sent")
                }
                else {
                    print("ERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient")
                }
            }
        }
    }
    
    static func sendSongIds(ids: [String]) {
        print("\n\nSendingBluetooth->sendSongIdsToClient:\nSENDING SONG ID TO CLIENT \(ids)\n")
        
        var messageDictionary: [String: String] = [:]
        
        for (index, id) in ids.enumerated() {
            messageDictionary["\(index)"] = id
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                print("Sent")
            }
            else {
                print("ERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient")
            }
        }
    }

    static func getSongIds(songs: [MPMediaItem], completion: @escaping ([String: String]) -> Void) {
    
        var songIds: [String: String] = [:]
        
        for (index, song) in songs.enumerated() {
            
            ConnectingToInternet.getSongs(searchTerm: "\(song.artist!) \(song.title!)".replacingOccurrences(of: " ", with: "%20"), limit: 2, sendSongsAlltogether: true, completion: {
                (sentSongs) -> Void in
                
                songIds["\(index)"] = sentSongs[0].id
                
                if songIds.count == songs.count {
                    completion(songIds)
                }
            })
        }
    }

    static func sendSongIdsFromHost(songs: [MPMediaItem]) {
        getSongIds(songs: songs, completion: {
            (songIds) -> Void in
            
            for peers in MPCManager.defaultMPCManager.session.connectedPeers {
                if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: songIds, toPeer: peers as MCPeerID) {
                    
                    print("Sent")
                }
                else {
                    print("ERROR SENDING DATA COULD HAPPEN MultipeerConnectivity -> sendSongIdsFromHost")
                }
            }

        })
    }
}
