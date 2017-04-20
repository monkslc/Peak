//
//  GettingTopCharts.swift
//  Peak
//
//  Created by Cameron Monks on 4/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class GettingTopCharts {
    
    static var defaultGettingTopCharts = GettingTopCharts()
    
    var completion: ([Song]) -> Void = {_ in }
    
    var lastTopCharts: [Song]?
    
    init() {
        searchTopCharts()
    }
    
    func searchTopCharts() {
        
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
                            
                            let songStuff = ConnectingToInternet.takeOutTags(htmlCode: songSection, sectionCharacter: "|")
                            
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
                                        self.completion(s)
                                        self.lastTopCharts = s
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
                    self.completion([])
                    self.lastTopCharts = []
                }
            }
            else {
                self.completion([])
                self.lastTopCharts = []
            }
        }.resume()
    }
}
