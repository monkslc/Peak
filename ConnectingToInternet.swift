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
    
    static func getFullLyrics(endingURL: String, completion : @escaping (String) -> Void) {
        
        let url = URL(string: "http://www.azlyrics.com/lyrics/\(endingURL)") // chancetherapper/acidrain
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil, let data = data {
                
                if let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as NSString! {
                    
                    if let urlContent = urlContent as? String {
                        
                        var lyrics = ""
                        let beginingLine = "!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->"
                        let beginingIndex = urlContent.indexOf(target: beginingLine) + beginingLine.length
                        let endingIndex = urlContent.indexOf(target: "</div>", startIndex: beginingIndex)
                        
                        let lyricsSection = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                        
                        
                        var lastIndex = 0
                        
                        while (lastIndex != -1) {
                            let indexOfNextTag = lyricsSection.indexOf(target: "<", startIndex: lastIndex)
                            if indexOfNextTag != -1 {
                                let newLine = lyricsSection.subString(startIndex: lastIndex, endIndex: indexOfNextTag)
                                lyrics = "\(lyrics)\(newLine)"
                                
                                lastIndex = lyricsSection.indexOf(target: ">", startIndex: indexOfNextTag) + 1
                                
                            }
                            else {
                                lastIndex = -1
                            }
                        }
 
                        let replacingCharacters: [String: String] = ["&quot;": "\""]
                        for (key, value) in replacingCharacters {
                            lyrics = (lyrics as NSString).replacingOccurrences(of: key, with: value)
                        }
                            
                        completion(lyrics)
                    }
                }
            }
        }.resume()
    }
    
    static func getFullLyrics(song: Song, completion : @escaping (String) -> Void) {
        let creatingURL = "http://search.azlyrics.com/search.php?q=\(song.trackName) \(song.artistName)"
        let urlNew:String = creatingURL.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: urlNew)
        
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil, let data = data {
                
                if let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as NSString! {
                    
                    if let urlContent = urlContent as? String {
                     
                        let beginingOfUrl = "http://www.azlyrics.com/lyrics/"
                        let beginingIndex = urlContent.indexOf(target: beginingOfUrl) + beginingOfUrl.length
                        let endingIndex = urlContent.indexOf(target: "\"", startIndex: beginingIndex)
                        
                        let lyricsUrl = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                        
                        ConnectingToInternet.getFullLyrics(endingURL: lyricsUrl, completion: completion)
                    }
                    
                }
                
            }
            
        }.resume()
        
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
                            
                            songs.append(Song(id: "\(songJSON["trackId"]!)", trackName: "\(songJSON["trackName"]!)", collectionName: "\(songJSON["collectionName"]!)", artistName: "\(String(describing: songJSON["artistName"]))", trackTimeMillis: Int("\(songJSON["trackTimeMillis"]!)")!, image: image))
                            
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
