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
    
    static func getSong(with id: Int, completion: @escaping (Song) -> Void) {
        
        ConnectingToInternet.getJSON(url: "https://itunes.apple.com/lookup?id=\(id)", completion: {
            (json) -> Void in
            
            if let json = json as? [String:Any] {
                if let songJSON = json["results"] as? [[String: String]] {
                    print(songJSON[0])
                    
                    let imageURL = songJSON[0]["artworkUrl30"]!
                    
                    ConnectingToInternet.getImage(url: imageURL, completion: {
                        (image) -> Void in
                        
                        completion(Song(id: id, trackName: songJSON[0]["trackName"]!, collectionName: songJSON[0]["collectionName"]!, image: image))
                    })
                    
                }
            }
        })
    }
    
    static func getImage(url urlAsString: String, completion: @escaping (UIImage) -> Void) {
        
        let url = URL(string: urlAsString)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let e = error {
                print("Error downoading Image in ImageGetter getImage line 23: \(e)")
            } else if let imageData = data {
                
                let image = UIImage(data: imageData)
                
                completion(image!)
                
            }
            else {
                print("Error downoading Image in ImageGetter getImage line 33")
            }
            }.resume()
    }
    
    static func getJSON(url urlAsString:String, completion : @escaping (Any) -> Void) {
        let url = URL(string: urlAsString)
        
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
            //print(json)
            
            completion(json)
            
        }.resume()
        
    }

}
