//
//  BasicSong.swift
//  Peak
//
//  Created by Cameron Monks on 5/2/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

protocol BasicSong {
    
    var type: PeakMusicController.MusicType { get }
    
    func getId() -> String
    func getTrackName() -> String
    func getCollectionName() -> String // same as album name
    func getArtistName() -> String
    func getTrackTimeMillis() -> Int
    func getImage() -> UIImage?
    func getDateAdded() -> Date?
    func isEqual(to song: BasicSong) -> Bool
}
