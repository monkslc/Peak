//
//  ConvertingSongType.swift
//  Peak
//
//  Created by Cameron Monks on 5/12/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import MediaPlayer

class ConvertingSongType {
    
    static func getAppleMusicId(songTitle: String, authourName: String, completion: @escaping (Song) -> Void) {
        
        var alreadySent = false
        
        ConnectingToInternet.getSongs(searchTerm: "\(songTitle) \(authourName)", limit: 7, sendSongsAlltogether: false, completion: {
            (songs) -> Void in
            
            if !alreadySent {
                for song in songs {
                    
                    print("\(song.trackName) \(song.artistName)")
                    
                    if song.getTrackName() == songTitle && song.getArtistName() == authourName {
                        completion(song)
                        
                        print("BLAH 4592 SONG: \(song)")
                        alreadySent = true
                        
                        return
                    }
                }
            }

            //completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
            
        }, error: {
            () -> Void in
            
            if !alreadySent {
                //completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
                
            }
        })
        
    }
    
    
}
