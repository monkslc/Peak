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

                    
                    if ConvertingSongType.isCloseEnough(songTitle1: song.getTrackName(), authour1: song.getArtistName(), songTitle2: songTitle, authour2: song.artistName) {
                        
                        completion(song)
                        
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
    
    static func isCloseEnough(songTitle1: String, authour1: String, songTitle2: String, authour2: String) -> Bool {
        
        var songNameNoParenthesis = songTitle1.lowercased()
        var artistNameNoParenthesis = authour1.lowercased()
        
        var originalSongName = songTitle2.lowercased()
        var orginalArtistName = authour2.lowercased()
        
        
        for c in ["(", ")", "-", "[", "]", ",", "'", "\"", " "] {
            songNameNoParenthesis = songNameNoParenthesis.replacingOccurrences(of: c, with: "")
            artistNameNoParenthesis = artistNameNoParenthesis.replacingOccurrences(of: c, with: "")
            
            originalSongName = originalSongName.replacingOccurrences(of: c, with: "")
            orginalArtistName = orginalArtistName.replacingOccurrences(of: c, with: "")
        }

        
        return songNameNoParenthesis == originalSongName && artistNameNoParenthesis == orginalArtistName
    }
}
