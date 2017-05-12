//
//  ConvertingSongType.swift
//  Peak
//
//  Created by Cameron Monks on 5/12/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import MediaPlayer

class ConvertingSongType {
    
    static func getAppleMusicId(songTitle: String, authourName: String, completion: @escaping (String) -> Void) {
        
        let searchQuery = "\(songTitle) \(authourName)".addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        
        let searchingAppleMusic = SearchingAppleMusicApi()
        searchingAppleMusic.addSearch(term: searchQuery, completion: {
            (songs) -> Void in
            
            for song in songs {
                if song.getTrackName() == songTitle && song.getArtistName() == authourName {
                    
                    completion(song.getId())
                    
                    break
                }
            }
            
        })
    }
    
    
}
