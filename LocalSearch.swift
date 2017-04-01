//
//  LocalSearch.swift
//  Peak
//
//  Created by Cameron Monks on 4/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import MediaPlayer

class LocalSearch {
    
    static private func getPositionIn(character: Character, set: [[Character]]) -> (x: Int, y: Int)? {
        
        for x in 0..<set.count {
            for y in 0..<set[x].count {
                if set[x][y] == character {
                    return (x,y)
                }
            }
        }
        
        return nil
    }
    
    static private func differanceBetweenTwoLetters(c1: Character, c2: Character) -> Double {
        
        if c1 == c2 {
            return 0
        }
        
        let letters: [[Character]] = [["q","w","e","r","t","y","u","i","o","p"], ["a","s","d","f","g","h","j","k","l"], ["\n","z","x","c","v","b","n","m"], ["\n","\n","\n", "\n"," "," "," "," ","\n","\n"]]
        
        if let c1Pos = getPositionIn(character: c1, set: letters), let c2Pos = getPositionIn(character: c2, set: letters) {
            
            let difX = c1Pos.x - c2Pos.x
            let difY = c1Pos.y - c2Pos.y
            
            let dif = sqrt(Double(difX * difX + difY * difY))
            
            return (dif > 5) ? 5: dif
        }
        
        return 5
    }
    
    static private func differanceBetweenTwoWords(word1: String, word2: String) -> Double {
        
        var dif = 0.0
        
        let minLength = (word1.length > word2.length) ? word2.length : word1.length
        
        for i in 0..<minLength {
            dif += differanceBetweenTwoLetters(c1: word1[i], c2: word2[i])
        }
        
        return dif
    }
    
    static func differanceBetweenTwoPhrases(searchTerm: String, songAndAuthour: String) -> Double {
        let searchTermWords = searchTerm.components(separatedBy: " ")
        let songAndAuthourWords = songAndAuthour.components(separatedBy: " ")
        
        var scoreForWords = [Double](repeating: 1000, count: searchTermWords.count)
        
        for i in 0..<searchTermWords.count {
            for w in songAndAuthourWords {
                let dif = differanceBetweenTwoWords(word1: searchTermWords[i], word2: w)
                
                if scoreForWords[i] > dif {
                    scoreForWords[i] = dif
                }
            }
        }
        
        var total = 0.0
        for s in scoreForWords {
            total += s
        }
        
        return total
    }
    
    static func search(_ search: String, library: [MPMediaItem]) -> [MPMediaItem] {
        
        var songs: [MPMediaItem] = []
        var points: [Int: Double] = [:]
        
        var index = 0
        for s in library {
            
            let dif = differanceBetweenTwoPhrases(searchTerm: search.lowercased(), songAndAuthour: "\(s.title!) \(s.artist!)".lowercased())
            
            points[index] = dif
            
            songs.append(s)
            
            index += 1
            
            /*
            if s.title!.lowercased().contains(search.lowercased()) || s.albumArtist!.lowercased().contains(search.lowercased()) {
                
                var point = 1
                var multilier = 1
                
                var i = s.title!.lowercased().indexOf(target: search.lowercased())
                if i >= 0 {
                    point += i
                } else {
                    multilier += 1
                }
                
                i = s.albumArtist!.lowercased().indexOf(target: search.lowercased())
                if i >= 0 {
                    point += i
                } else {
                    multilier += 1
                }
                
                points[index] = point * multilier
                
                songs.append(s)
                
                index += 1
            }
 */
        }
        
        let sorted = points.sorted(by: {
            (a,b) in
                
            return a.value < b.value
        })
        
        var top : [MPMediaItem] = []
        
        for (key, _) in sorted {
            top.append(songs[key])
        }
        
        
        return top
    }
}
