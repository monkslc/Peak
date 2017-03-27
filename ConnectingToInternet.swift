//
//  ConnectingToInternet.swift
//  Peak
//
//  Created by Cameron Monks on 3/26/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit

class ConnectingToInternet {
    
    static func getLyrics(songID: String, completion: @escaping (String) -> Void) {
        
        ConnectingToInternet.getJSON(url: "http://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=\(songID)&apikey=cfd3476032d5a320c990029163e1d621", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
                if let messageJSON = json["message"] as? [String: Any] {
                    if let songsJSON = messageJSON["body"] as? [String: Any] {
                        if let lyricsBody = songsJSON["lyrics"] as? [String: Any] {
                            if let lyrics = lyricsBody["lyrics_body"] as? String {
                                completion(lyrics)
                            }
                        }
                    }

                }
            }
        })

    }
    
    static func getSongs(searchTerm: String, limit: Int = 5, sendSongsAlltogether: Bool = true, completion: @escaping ([Song]) -> Void) {
        
        ConnectingToInternet.getJSON(url: "https://itunes.apple.com/search?term=\(searchTerm)&country=US&media=music&limit=\(limit)", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
                
                if let songsJSON = json["results"] as? [[String: Any]] {
                    
                    var songs: [Song] = []
                    
                    for songJSON in songsJSON {
                    
                        let imageURL = songJSON["artworkUrl100"]! as! String
                        
                        ConnectingToInternet.getImage(url: imageURL, completion: {
                            (image) -> Void in
                            
                            songs.append(Song(id: songJSON["trackId"] as! String, trackName: songJSON["trackName"]! as! String, collectionName: songJSON["collectionName"]! as! String, artistName: songJSON["artistName"] as! String, trackTimeMillis: Int(songJSON["trackTimeMillis"]! as! String)!, image: image))
                            
                            if songs.count == limit || !sendSongsAlltogether {
                                completion(songs)
                            }
                        })
                    }
                    
                }
            }
        })
    }
    
    static func getSong(id: String, completion: @escaping (Song) -> Void) {
        
        ConnectingToInternet.getJSON(url: "https://itunes.apple.com/lookup?id=\(id)", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
    
                if let songJSON = json["results"] as? [[String: Any]] {
                    
                    let imageURL = songJSON[0]["artworkUrl100"]! as! String
                    
                    ConnectingToInternet.getImage(url: imageURL, completion: {
                        (image) -> Void in
                        
                        completion(Song(id: id, trackName: songJSON[0]["trackName"]! as! String, collectionName: songJSON[0]["collectionName"]! as! String, artistName: songJSON[0]["artistName"]! as! String, trackTimeMillis: Int(songJSON[0]["trackTimeMillis"]! as! String)!, image: image))
                    })
                    
                }
            }
        })
    }
    
    static func getImage(url urlAsString: String, completion: @escaping (UIImage?) -> Void) {
        
        let url = URL(string: urlAsString)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let e = error {
                print("Error downoading Image in ImageGetter getImage line 23: \(e)")
            } else if let imageData = data {
                
                let image = UIImage(data: imageData)
                
                completion(image)
                
            }
            else {
                print("Error downoading Image in ImageGetter getImage line 33")
            }
        }.resume()
    }
    
    static func getJSON(url urlAsString:String, completion : @escaping (Any) -> Void) {
        let url = URL(string: urlAsString)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            //print(json)
            
            completion(json)
            
        }.resume()
        
    }
    

}
