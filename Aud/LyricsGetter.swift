//
//  LyricsGetter.swift
//  Peak
//
//  Created by Cameron Monks on 3/25/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class LyricsGetter {
    
    func getLyrics() -> String {
        
        let url = URL(string: "")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            self.isReloadingData = false
            
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
            
            if let json = json as? [[String: String]] {
                for rallyAsJson in json {
                    newRallies.append(Rally(id: Int(rallyAsJson["id"]!)!, name: rallyAsJson["nameOfEvent"]!, cityName: rallyAsJson["nameOfLocation"]!, lattitude: Double(rallyAsJson["lattitude"]!)!, longitude: Double(rallyAsJson["longitude"]!)!, likes: Int(rallyAsJson["votes"]!)!, distanceAway: Double(rallyAsJson["distance"]!)!, date: Double(rallyAsJson["timeInMillis"]!)!, details: rallyAsJson["additionalComments"]!))
                }
                
                self.rallies = newRallies
            }
            
            self.completion()
        }
        
        task.resume()
    }
    
}
