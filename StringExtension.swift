//
//  StringExtension.swift
//  Cam Clock
//
//  Created by Cameron Monks on 1/7/17.
//  Copyright © 2017 Cameron Monks. All rights reserved.
//

import Foundation

extension String
{
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = self.index(self.startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            
            return self.substring(with: startIndex..<endIndex)
        }
    }
    
    func subString(toIndex: Int) -> String {
        let end = self.index(self.startIndex, offsetBy: toIndex)
        return substring(to: end)
    }
    
    func subString(startIndex: Int) -> String {
        let begining = self.index(self.startIndex, offsetBy: startIndex)
        return substring(from: begining)
    }
    
    func subString(startIndex: Int, endIndex: Int) -> String
    {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        return self.substring(with: start..<end)
    }
    
    func indexOf(target: String) -> Int
    {
        let range = self.range(of: target)
        if let range = range {
            return distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        let startRange = self.index(self.startIndex, offsetBy: startIndex)
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: startRange..<self.endIndex)
        
        if let range = range {
            return distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target: target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target: target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func lastCharacter() -> Character {
        return self[length - 1]
    }

}
