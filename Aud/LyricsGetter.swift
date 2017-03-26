//
//  LyricsGetter.swift
//  Peak
//
//  Created by Cameron Monks on 3/25/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class LyricsGetter {
    
    func getLyrics(completion: @escaping (String) -> Void) {
        
        let url = URL(string: "")
        
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
            print(json)
            
            if let json = json as? [[String: String]] {
                for part in json {
                    
                }
                
            }
            
            completion("cs")
        }.resume()
    }
    
}
