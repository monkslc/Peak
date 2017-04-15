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
                    
                    let urlContent = urlContent as String
                        
                    var lyrics = ""
                    let beginingLine = "!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->"
                    let beginingIndex = urlContent.indexOf(target: beginingLine) + beginingLine.length
                    let endingIndex = urlContent.indexOf(target: "</div>", startIndex: beginingIndex)
                    
                    let lyricsSection = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                    
                    
                    var lastIndex = 0
                    
                    while (lastIndex != -1) {
                        var indexOfNextTag = lyricsSection.indexOf(target: "<", startIndex: lastIndex)
                        
                        if indexOfNextTag == -1 {
                            indexOfNextTag = lyricsSection.length
                        }
                        
                        let newLine = lyricsSection.subString(startIndex: lastIndex, endIndex: indexOfNextTag)
                        lyrics = "\(lyrics)\(newLine)"
                            
                        lastIndex = lyricsSection.indexOf(target: ">", startIndex: indexOfNextTag)
                        if lastIndex != -1 {
                            lastIndex += 1
                        }
                        
                    }
                    
                    let replacingCharacters: [String: String] = ["&quot;": "\"", "â": "’", "Ã©": "é", "&amp;": "&", "&apos;": "\'", "&lt;": "<", "&gt;": ">", "&nbsp;": "\u{00a0}", "&diams;": "♦"]
                    for (key, value) in replacingCharacters {
                        lyrics = (lyrics as NSString).replacingOccurrences(of: key, with: value)
                    }
                    
                    if lyrics.contains("AZLyrics - Song Lyrics from A to Z") {
                        lyrics = "Sorry we don't have these lyrics"
                    }
                    
                    completion(lyrics)
                }
            }
        }.resume()
    }
    
    static func getFullLyrics(song: Song, completion : @escaping (String) -> Void) {
        
        var songName = song.trackName
        if songName.contains("(") {
            songName = songName.subString(toIndex: songName.indexOf(target: "(")).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let search = ("\(songName) \(song.artistName)").addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        let urlNew = "http://search.azlyrics.com/search.php?q=\(search!)"
        
        let url = URL(string: urlNew)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil, let data = data {
                
                if let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as NSString! {
                    
                    let urlContent = urlContent as String
                     
                    let beginingOfUrl = "http://www.azlyrics.com/lyrics/"
                    let beginingIndex = urlContent.indexOf(target: beginingOfUrl) + beginingOfUrl.length
                    let endingIndex = urlContent.indexOf(target: "\"", startIndex: beginingIndex)
                    
                    let lyricsUrl = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                    
                    ConnectingToInternet.getFullLyrics(endingURL: lyricsUrl, completion: completion)
                    
                }
                
            }
            
        }.resume()
        
    }
    
    static func getSongs(searchTerm: String, limit: Int = 5, sendSongsAlltogether: Bool = true, completion: @escaping ([Song]) -> Void, error: @escaping () -> Void = {}) {
        
        let search = searchTerm.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!//searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        
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
                completion(json)
            } catch {
                
                print("\n\nERROR: THIS SHOULD NEVER HAPPEN: ConnectingToInternet.getJSON failed to get JSON\n\n")
                errorCompletion()
            }
            /*End of Try Catch added by Connor, Cam might want to check errors*/
            //print(json)
            
            
            
        }.resume()
        
    }
    
    static func searchTopCharts(completion: @escaping ([Song]) -> Void) {
        
        let url = URL(string: "http://www.apple.com/itunes/charts/songs/")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil, let data = data {
                
                if let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as NSString! {
                    
                    let urlContent = urlContent as String
                    
                    let beginingIndex = urlContent.indexOf(target: "<strong>1.</strong>")
                    let endingIndex = urlContent.indexOf(target: "<strong>51.</strong>", startIndex: beginingIndex)
                    let section = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                    
                    var songs : [Song?] = []//(repeating: nil, count: 50)
                    
                    var startIndex = 0
                    var songIndex = 1
                    while startIndex != -1 && songIndex < 50 {
                        
                        let endSongSectionIndex = section.indexOf(target: "<strong>\(songIndex).</strong>", startIndex: startIndex)
                        
                        if endSongSectionIndex == -1 {
                            startIndex = -1
                        }
                        else {
                            let songSection = section.subString(startIndex: startIndex, endIndex: endSongSectionIndex)
                        
                            let songStuff = takeOutTags(htmlCode: songSection, sectionCharacter: "|")
                        
                            let thisSongIndex = songIndex - 2
                            let sectionsOfSong = songStuff.components(separatedBy: "|")
                            if sectionsOfSong.count > 2 {
                                songs.append(nil)
                                ConnectingToInternet.getSongs(searchTerm: "\(sectionsOfSong[1]) \(sectionsOfSong[2])".replacingOccurrences(of: "’", with: ""), limit: 1, sendSongsAlltogether: true, completion: {
                                    (newSong) -> Void in
                                
                                    songs[thisSongIndex] = newSong[0]
                                    
                                    if var s = songs as? [Song] {
                                        var i = 0
                                        while i < s.count {
                                            if s[i].image == nil {
                                                s.remove(at: i)
                                            }
                                            else {
                                                i += 1
                                            }
                                        }
                                        completion(s)
                                    }
                                    
                                }, error: {
                                    
                                    songs[thisSongIndex] = Song(id: "", trackName: "", collectionName: "", artistName: "", trackTimeMillis: 0, image: nil, dateAdded: nil)
                                })
                            }
                            
                            songIndex += 1
                            
                            startIndex = endSongSectionIndex
                        }
                    }
                }
                else {
                    completion([])
                }
            }
            else {
                completion([])
            }
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
