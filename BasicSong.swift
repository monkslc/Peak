//
//  BasicSong.swift
//  Peak
//
//  Created by Cameron Monks on 5/2/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

protocol BasicSong {
    func getId() -> String
    func getTrackName() -> String
    func getCollectionName() -> String // same as album name
    func getArtistName() -> String
    func getTrackTimeMillis() -> Int
    func getImage() -> UIImage?
    func getDateAdded() -> Date?
}
