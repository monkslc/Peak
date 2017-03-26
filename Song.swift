//
//  Song.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit

struct Song {
    var id: Int
    var trackName: String
    var collectionName: String // same as album name
    var artistName: String
    var trackTimeMillis: Int
    var image: UIImage?
}
