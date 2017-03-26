//
//  SongGetter.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit

class SongGetter {
    
    static func getSong(with id: Int, completion: @escaping (Song) -> Void) {
        
        JSONGetter.getJSON(url: "https://itunes.apple.com/lookup?id=\(id)", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
                if let songJSON = json["results"] as? [[String: String]] {
                    print(songJSON[0])
                    
                    let imageURL = songJSON[0]["artworkUrl30"]!
                    
                    ImageGetter.getImage(url: imageURL, completion: {
                        (image) -> Void in
                        
                        completion(Song(id: id, trackName: songJSON[0]["trackName"]!, collectionName: songJSON[0]["collectionName"]!, image: image))
                    })
                
                }
            }
        })
        
    }

}
