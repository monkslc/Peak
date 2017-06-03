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
        
        //var alreadySent = false
        
        ConnectingToInternet.getSongs(searchTerm: "\(searchSong.getTrackName()) \(searchSong.getCollectionName())", limit: 7, sendSongsAlltogether: true, completion: {
            (songs) -> Void in
            
            //let song = ConvertingSongType.getClosestSong(searchSong: searchSong, songs: songs)
            //completion(song as! Song)
            
            let (song, _) = GettingClosestSong.getClosestSong(searchSong: searchSong, songs: songs)
            completion(song as! Song)
            //completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
            
        }, error: {
            () -> Void in
            
            print("\n\n\nERRORR: ConvertingSongType->getAppleMusicId:\nError Retrieving SOngs\n\n\n")
            
            //if !alreadySent {
                //completion(Song(id: "-1", trackName: songTitle, collectionName: "", artistName: authourName, trackTimeMillis: 0, image: nil, dateAdded: nil))
                
            //}
        })
        
    }
    
}
