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

class BluetoothHandler{
    
    /*MARK: PROPERTIES*/
    var delegate: BluetoohtHandlerDelegate?
    
    
    /*MARK: INITIALIZERS*/
    init(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCNotification(notification:)), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }
    
    /*MARK Bluetooth Methods*/
    func receivedGroupPlayQueue(_ songIds: [String]) {
        
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
    
    
    func receivedSong(_ songID: String) {
        //Received a song from a contributor
        
        delegate?.showSignifier()
        
        //add the song to the user's library, async
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
        
        if let id = dataDictionary["id"] {
            
            receivedSong(id)
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
        
        var index = 0
        while (true) {
            
            if let value = dataDictionary["\(index)"] {
                songIDs.append(value)
            }
            else {
                break
            }
            
            index += 1
        }
        
        receivedGroupPlayQueue(songIDs)
    }
}
