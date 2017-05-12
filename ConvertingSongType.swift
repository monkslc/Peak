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
        
        ConnectingToInternet.getSongs(searchTerm: "\(songTitle) \(authourName)", limit: 1, sendSongsAlltogether: false, completion: {
            (songs) -> Void in
            
            if songs.count > 0 {
                let song = songs[0]
                
                if song.getTrackName() == songTitle && song.getArtistName() == authourName {
                    completion(song)
                }
                else {
                    completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
                }
            }

            
        }, error: {
            () -> Void in
            
            completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
        })
        
    }
    
    
}
