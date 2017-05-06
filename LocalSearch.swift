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
    
    static private func getPositionIn(character: Character, set: [[Character]]) -> (x: Double, y: Double)? {
        
        for y in 0..<set.count {
            for x in 0..<set[y].count {
                if set[y][x] == character {
                    return (Double(x),Double(y))
                }
            }
        }
        
        return nil
    }
    
    static private func differanceBetweenTwoLetters(c1: Character, c2: Character) -> Double {
        
        if c1 == c2 {
            return 0
        }
        
        let letters: [[Character]] = [["q","w","e","r","t","y","u","i","o","p"], ["a","s","d","f","g","h","j","k","l"], ["z","x","c","v","b","n","m"]]
        
        if var c1Pos = getPositionIn(character: c1, set: letters), var c2Pos = getPositionIn(character: c2, set: letters) {
            
            switch c1Pos.y {
            case 1:
                c1Pos.x += 0.5
            case 2:
                c1Pos.x += 1.5
            default:
                print("")
            }
            
            switch c2Pos.y {
            case 1:
                c2Pos.x += 0.5
            case 2:
                c2Pos.x += 1.5
            default:
                print("")
            }
            
            let difX = c1Pos.x - c2Pos.x
            let difY = c1Pos.y - c2Pos.y
            
            let dif = sqrt(Double(difX * difX + difY * difY))
            
            return (dif > 5) ? 5: dif
        }
        
        return 5
    }
    
    static private func differanceBetweenTwoWords(searchTermWord: String, songAndAuthourWord: String) -> Double {
        
        var totalDif = 0.0
        
        var newSongAndAuthourWord = songAndAuthourWord
        while searchTermWord.length > newSongAndAuthourWord.length {
            newSongAndAuthourWord.append(" ")
        }
        
        for i in 0..<searchTermWord.length {
            var cDif = 5.0
            
            var j = i - 2
            while j <= i + 2 {
                
                if j + i >= 0 && i + j < newSongAndAuthourWord.length {
                    let newDif = differanceBetweenTwoLetters(c1: searchTermWord[i], c2: newSongAndAuthourWord[i + j]) + Double(abs(j))
                    if cDif > newDif {
                        cDif = newDif
                    }
                }
                
                j += 1
            }
            
            
            totalDif += cDif
        }
        
        return totalDif
    }
    
    static private func differanceBetweenTwoPhrases(searchTerm: String, songAndAuthour: String) -> Double {
        let searchTermWords = searchTerm.components(separatedBy: " ")
        let songAndAuthourWords = songAndAuthour.components(separatedBy: " ")
        
        var scoreForWords = [Double](repeating: 1000, count: searchTermWords.count)
        
        for i in 0..<searchTermWords.count {
            for w in songAndAuthourWords {
                let dif = differanceBetweenTwoWords(searchTermWord: searchTermWords[i], songAndAuthourWord: w)
                
                if scoreForWords[i] > dif {
                    scoreForWords[i] = dif
                }
            }
        }
        
        var total = 0.0
        for s in scoreForWords {
            total += s
        }
        
        return total //(total * Double(songAndAuthourWords.count + 10)) / 10
    }
    

 
    static func search(_ search: String, library: [BasicSong]) -> [BasicSong] {
        var songs: [BasicSong] = []
        var points: [Int: Double] = [:]
        
        var index = 0
        for s in library {
            
            let dif = differanceBetweenTwoPhrases(searchTerm: search.lowercased(), songAndAuthour: "\(s.getTrackName()) \(s.getArtistName())".lowercased())
            
            let averageDiff = dif / Double(search.length)
            if averageDiff < 3 || dif < 10 {
                points[index] = dif
                
                songs.append(s)
                
                index += 1
            }
            
        }
        
        let sorted = points.sorted(by: {
            (a,b) in
            
            return a.value < b.value
        })
        
        var top : [BasicSong] = []
        
        for (key, _) in sorted {
            top.append(songs[key])
            
            if top.count > 25 {
                break
            }
        }
        
        
        return top
    }
}
