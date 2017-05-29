//
//  Song.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit

struct Song: BasicSong {
    
    var type: PeakMusicController.MusicType {
        return .Guest
    }

    var id: String
    var trackName: String
    var collectionName: String // same as album name
    var artistName: String
    var trackTimeMillis: Int
    var image: UIImage?
    var dateAdded: Date?
    
    func getId() -> String { return id }
    func getTrackName() -> String { return trackName }
    func getCollectionName() -> String { return collectionName }
    func getArtistName() -> String { return artistName }
    func getTrackTimeMillis() -> Int { return trackTimeMillis / 1000; }
    func getImage() -> UIImage? { return image }
    func getDateAdded() -> Date? { return dateAdded }
    
    func isEqual(to song: BasicSong) -> Bool {
        
        if id == song.getId(){
            return true
        }
        
        return false
    }
    
}
