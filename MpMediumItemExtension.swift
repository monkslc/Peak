//
//  MpMediumItemExtension.swift
//  Peak
//
//  Created by Cameron Monks on 5/2/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPMediaItem: BasicSong {
    
    func getId() -> String { return "\(self.playbackStoreID)" }
    func getTrackName() -> String { return self.title! }
    func getCollectionName() -> String { return albumTitle! }
    func getArtistName() -> String { return albumArtist! }
    func getTrackTimeMillis() -> Int { return Int(self.playbackDuration) }
    func getImage() -> UIImage? { return self.artwork?.image(at: CGSize())}
    func getDateAdded() -> Date? { return dateAdded }
}
