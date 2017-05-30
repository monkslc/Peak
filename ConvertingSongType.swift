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
                    
                    //print("\(song.trackName) \(song.artistName)")
                    
                    var songNameNoParenthesis = song.getTrackName().lowercased()
                    var artistNameNoParenthesis = song.getArtistName().lowercased()
                    
                    var originalSongName = songTitle.lowercased()
                    var orginalArtistName = song.artistName.lowercased()
                    
                    
                    for c in ["(", ")", "-", "[", "]", ",", "'", "\"", " "] {
                        songNameNoParenthesis = songNameNoParenthesis.replacingOccurrences(of: c, with: "")
                        artistNameNoParenthesis = artistNameNoParenthesis.replacingOccurrences(of: c, with: "")
                        
                        originalSongName = originalSongName.replacingOccurrences(of: c, with: "")
                        orginalArtistName = orginalArtistName.replacingOccurrences(of: c, with: "")
                    }
                    
                    if songNameNoParenthesis == originalSongName && artistNameNoParenthesis == orginalArtistName {
                        
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
    
    
}
