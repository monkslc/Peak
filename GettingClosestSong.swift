//
//  GettingClosestSong.swift
//  Peak
//
//  Created by Cameron Monks on 6/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class GettingClosestSong {
    
    private static func differanceBetweenWords(at index: Int, word1: String, c: Character) -> Int {
        
        for i in 0..<3 {
            if index - i > 0 && word1[index - i] == c {
                return i
            }
            if index + i < word1.length && word1[index + i] == c {
                return i
            }
        }
        
        return 3
    }
    
    private static func differanceBetweenWords(word1: String, word2: String) -> Int {
        
        var score = 0
        
        let minLength = min(word1.length, word2.length)
        
        for i in 0..<minLength {
            score += differanceBetweenWords(at: i, word1: word1, c: word2[i])
        }
        
        score += 3 * (max(word1.length, word2.length) - minLength)
        
        return score
    }
    
    private static func differenceBetweenPhrases(at index: Int, words: [String], word: String) -> Int {
        
        var lowestPoints = differanceBetweenWords(word1: words[index], word2: word)
        
        for i in 1..<3 {
            if index - i > 0 {
                let newPoints = (i * 2) + (i * 2) * differanceBetweenWords(word1: words[index - i], word2: word)
                if newPoints < lowestPoints {
                    lowestPoints = newPoints
                }
            }
            
            if index + i < words.count {
                let newPoints = (i * 2) + (i * 2) * differanceBetweenWords(word1: words[index + i], word2: word)
                if newPoints < lowestPoints {
                    lowestPoints = newPoints
                }
            }
        }
        
        return lowestPoints
    }
    
    static func differenceBetweenPhrases(phrase1: String, phrase2: String) -> Double {
        
        let words1 = phrase1.components(separatedBy: " ")
        let words2 = phrase2.components(separatedBy: " ")
        
        let minWords = min(words1.count, words2.count)
        
        var points = 0.0
        
        for i in 0..<minWords {
            
            if words1[i] != words2[i] {
                points += words1.contains(words2[i]) ? 0.5 : 1
            }
            
            //points += differenceBetweenPhrases(at: i, words: words1, word: words2[i])
        }
        
        let differanceBetweenAmountOfWords = max(words1.count, words2.count) - minWords
        
        return min(1, (points + Double(differanceBetweenAmountOfWords)) / Double(words1.count))
        
        //return Double(points + 3 * (max(words1.count, words2.count) - minWords)) / Double(words1.count)
    }
    
    static func getCloseEnoughPoints(song1: BasicSong, song2: BasicSong) -> Double {
        
        let getTrackName = { (song : BasicSong) -> String in return song.getTrackName() }
        let getCollectionName = { (song : BasicSong) -> String in return song.getCollectionName() }
        let getArtistName = { (song : BasicSong) -> String in return song.getArtistName() }
        
        var totalPoints = 0.0
        
        for getName in [getTrackName, getCollectionName, getArtistName] {
            var search1 = getName(song1).lowercased() //song1.getTrackName().lowercased()
            var search2 = getName(song2).lowercased() //song2.getTrackName().lowercased()
            
            for c in ["(", ")", "-", "[", "]", ",", "'", "\""] {
                search1 = search1.replacingOccurrences(of: c, with: "")
                search2 = search2.replacingOccurrences(of: c, with: "")
            }
            
            search1 = search1.replacingOccurrences(of: "&", with: "and")
            search2 = search2.replacingOccurrences(of: "&", with: "and")
            
            while search1.contains("  ") {
                search1 = search1.replacingOccurrences(of: "  ", with: " ")
            }
            while search2.contains("  ") {
                search2 = search2.replacingOccurrences(of: "  ", with: " ")
            }
            
            let newPoints = differenceBetweenPhrases(phrase1: search1, phrase2: search2)
            
            totalPoints += newPoints
            
        }
        
        return totalPoints
    }
    
    static func getClosestSong(searchSong: BasicSong, songs: [BasicSong]) -> (BasicSong, Double) {
        var bestSong = songs[0]
        var lowestPoints = getCloseEnoughPoints(song1: searchSong, song2: bestSong)
        for i in 1..<songs.count {
            let newPoints = getCloseEnoughPoints(song1: searchSong, song2: songs[i])
            
            if newPoints < lowestPoints {
                bestSong = songs[i]
                lowestPoints = newPoints
            }
        }
        
        return (bestSong, lowestPoints)
    }
    
}
