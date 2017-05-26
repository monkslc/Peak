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
    
    static func getSpotifySongs(query: String, completion: @escaping ([SPTPartialTrack]) -> Void, error: @escaping () -> Void) {
        
        DispatchQueue.global().async {
            let searchType = [SPTSearchQueryType.queryTypeTrack, SPTSearchQueryType.queryTypeArtist] //[SPTSearchQueryType.queryTypeAlbum, SPTSearchQueryType.queryTypeArtist, SPTSearchQueryType.queryTypeTrack, SPTSearchQueryType.queryTypePlaylist]
            
            
            var songsBySearchType = [[SPTPartialTrack]?].init(repeating: nil, count: searchType.count)
            
            for (index, sType) in searchType.enumerated() {
                
                let index = index
                
                SPTSearch.perform(withQuery: query, queryType: sType, accessToken: nil) {
                    err, callback in
                    
                    DispatchQueue.global().async {
                        
                        if let err = err {
                            print(err)
                            error()
                            return
                        }
                        
                        if let page = callback as? SPTListPage {
                            
                            var songs: [SPTPartialTrack] = []
                            
                            if page.items == nil {
                                print("Page items is nil")
                                completion([])
                                return
                            }
                            
                            for item in page.items {
                                if let song = item as? SPTPartialTrack {
                                    songs.append(song)
                                }
                            }
                            songsBySearchType[index] = songs
                            
                            if let allSongsMultiArray = songsBySearchType as? [[SPTPartialTrack]] {
                                var allSongs: [SPTPartialTrack] = []
                                
                                for groupOfSongs in allSongsMultiArray {
                                    allSongs.append(contentsOf: groupOfSongs)
                                }
                                
                                completion(allSongs)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    static func getSongs(searchTerm: String, limit: Int = 5, sendSongsAlltogether: Bool = true, completion: @escaping ([Song]) -> Void, error: @escaping () -> Void = {}) {
        
        let search = searchTerm.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!//searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        
        //print("Searching: \(search)")
        ConnectingToInternet.getJSON(url: "https://itunes.apple.com/search?term=\(search)&country=US&media=music&limit=\(limit)", completion: {
            (json) -> Void in
    
            if let json = json as? [String:Any] {
                
                if let songsJSON = json["results"] as? [[String: Any]] {
                    
                    var songs: [Song] = []
        
                    //let serialQueue = DispatchQueue(label: "myqueue")
                    
                    var badSongs = 0
                    for songJSON in songsJSON {
                    
                        let imageURL = songJSON["artworkUrl100"]! as! String
                        
                        ConnectingToInternet.getImage(url: imageURL, completion: {
                            (image) -> Void in
                            
                            guard let id = songJSON["trackId"] as? Int, let name = songJSON["trackName"] as? String, let album = songJSON["collectionName"] as? String, let artist = songJSON["artistName"] as? String, let time = songJSON["trackTimeMillis"] as? Int, let streamable = songJSON["isStreamable"] as? Bool else {
                                
                                print("\n\nERROR: THIS SHOULD NEVER HAPPEN: ConnectingToInternet.getSongs\n\n")
                                
                                error()
                                return
                            }
                            
                            //print("SONG: \(name) STREAMABLE: \(streamable)")
                            
                            if streamable {
                            
                                //serialQueue.sync {
                                    songs.append(Song(id: "\(id)", trackName: name, collectionName: album, artistName: artist, trackTimeMillis: time, image: image, dateAdded: nil))
                                //}
                                
                                
                                if songs.count == (songsJSON.count - badSongs) || !sendSongsAlltogether {
                                    completion(songs)
                                }
                            }
                            else {
                                if limit == 1 {
                                    error()
                                }
                                else {
                                    badSongs += 1
                                }
                            }
                        })
                    }
                } else { error() }
            } else { error() }
        }, errorCompletion: error)
    }
    
    static func getSong(id: String, completion: @escaping (Song) -> Void) {
        
        ConnectingToInternet.getJSON(url: "https://itunes.apple.com/lookup?id=\(id)", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
    
                if let songJSON = json["results"] as? [[String: Any]] {
                    
                    let imageURL = songJSON[0]["artworkUrl100"]! as! String
                    
                    ConnectingToInternet.getImage(url: imageURL, completion: {
                        (image) -> Void in
                        
                        completion(Song(id: id, trackName: "\(songJSON[0]["trackName"]!)", collectionName: "\(songJSON[0]["collectionName"]!)", artistName: "\(songJSON[0]["artistName"]!)", trackTimeMillis: Int("\(songJSON[0]["trackTimeMillis"]!)")!, image: image, dateAdded: nil))
                    })
                    
                }
            }
        })
    }
    
    static func getImage(url urlAsString: String, completion: @escaping (UIImage?) -> Void, errorCompletion: @escaping () -> Void = {}) {
    
        let url = URL(string: urlAsString)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let e = error {
                errorCompletion()
                print("\n\nError: THIS SHOULD NEVER HAPPEN: downoading Image in ConnectingToInternet getImage line 192: \(e)\n\n")
            } else if let imageData = data {
                
                let image = UIImage(data: imageData)
                
                completion(image)
                
            }
            else {
                errorCompletion()
                print("\n\nError: THIS SHOULD NEVER HAPPEN: THIS SHOULD NEVER HAPPEN: downoading Image in ConnectingToInternet getImage line 206\n\n")
            }
        }.resume()
    }
    
    static func getJSON(url urlAsString:String, completion : @escaping (Any) -> Void, errorCompletion: @escaping () -> Void = {}) {
        let url = URL(string: urlAsString)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print("\n\nERROR: THIS SHOULD NEVER HAPPEN: ConnectingToInternet.getJSON: Error \(String(describing: error)) \n\n")
                print(error!)
                errorCompletion()
                return
            }
            guard let data = data else {
                print("\n\nERROR: THIS SHOULD NEVER HAPPEN: ConnectingToInternet.getJSON: Data is empty\n\n")
                errorCompletion()
                return
            }
            
            /*TRY CATCH ADDED BY CONNOR, NOT SURE HOW TO HANDLE ERRORS*/
            do{
                
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                //print(json)
                completion(json)
            } catch {
                
                print("\n\nERROR: THIS SHOULD NEVER HAPPEN: ConnectingToInternet.getJSON failed to get JSON\n\n")
                errorCompletion()
            }
            /*End of Try Catch added by Connor, Cam might want to check errors*/
            //print(json)
            
            
            
        }.resume()
        
    }
    
    static func takeOutTags(htmlCode: String, sectionCharacter: String = "") -> String {
        var str = ""
        
        var beginingIndex = 0
        while beginingIndex != -1 {
            
            let endingIndex = htmlCode.indexOf(target: "<", startIndex: beginingIndex)
            if endingIndex != -1 {
                let newSection = htmlCode.subString(startIndex: beginingIndex, endIndex: endingIndex).trimmingCharacters(in: .whitespacesAndNewlines)
                if newSection.length > 0 {
                    str.append("\(newSection)\(sectionCharacter)")
                }
                beginingIndex = htmlCode.indexOf(target: ">", startIndex: endingIndex) + 1
            }
            else {
                beginingIndex = -1
            }
        }
        
        let replacingCharacters: [String: String] = ["&quot;": "\"", "â": "’"]
        for (key, value) in replacingCharacters {
            str = (str as NSString).replacingOccurrences(of: key, with: value)
        }
        return str
    }
}
