//
//  GettingLyrics.swift
//  Peak
//
//  Created by Cameron Monks on 4/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class GettingLyrics {
    
    static var defaultGettingLyrics = GettingLyrics()
    
    private var lastSearchForLyrics = ""
    private var lastLyrics = ""
    
    private func getFullLyrics(endingURL: String, completion : @escaping (String) -> Void) {
        
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
                    
                    self.lastLyrics = lyrics
                    completion(lyrics)
                }
            }
            }.resume()
    }
    
    func getFullLyrics(song: Song, completion : @escaping (String) -> Void) {
        
        var songName = song.trackName
        if songName.contains("(") {
            songName = songName.subString(toIndex: songName.indexOf(target: "(")).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let search = ("\(songName) \(song.artistName)").addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        let urlNew = "http://search.azlyrics.com/search.php?q=\(search!)"
        
        if urlNew == lastSearchForLyrics && lastLyrics != "" {
            completion(lastLyrics)
            return
        }
        lastLyrics = ""
        lastSearchForLyrics = urlNew
        
        let url = URL(string: urlNew)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil, let data = data {
                
                if let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) as NSString! {
                    
                    let urlContent = urlContent as String
                    
                    let beginingOfUrl = "http://www.azlyrics.com/lyrics/"
                    let beginingIndex = urlContent.indexOf(target: beginingOfUrl) + beginingOfUrl.length
                    let endingIndex = urlContent.indexOf(target: "\"", startIndex: beginingIndex)
                    
                    let lyricsUrl = urlContent.subString(startIndex: beginingIndex, endIndex: endingIndex)
                    
                    self.getFullLyrics(endingURL: lyricsUrl, completion: completion)
                }
                
            }
            
            }.resume()
        
    }
    
}
