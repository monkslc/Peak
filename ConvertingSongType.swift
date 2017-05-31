//
//  ConvertingSongType.swift
//  Peak
//
//  Created by Cameron Monks on 5/12/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import MediaPlayer

class ConvertingSongType {
    
    static func getAppleMusicId(song searchSong: BasicSong, completion: @escaping (Song) -> Void) {
        
        var alreadySent = false
        
        ConnectingToInternet.getSongs(searchTerm: "\(searchSong.getTrackName()) \(searchSong.getArtistName()) \(searchSong.getCollectionName())", limit: 7, sendSongsAlltogether: false, completion: {
            (songs) -> Void in
            
            if !alreadySent {
                for song in songs {

                    
                    if ConvertingSongType.isCloseEnough(song1: song, song2: searchSong) {
                        
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
    
    static func isCloseEnough(song1: BasicSong, song2: BasicSong) -> Bool {
        
        var points = LocalSearch.differanceBetweenTwoPhrases(searchTerm: "\(song1.getTrackName()) \(song1.getArtistName()) \(song1.getCollectionName())", songAndAuthour: "\(song1.getTrackName()) \(song1.getArtistName()) \(song1.getCollectionName())")
        
        return points < 10
        
        /*
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
 */
    }
}
