//
//  AddToLibrary.swift
//  Aud
//
//  Created by Connor Monks on 6/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import MediaPlayer
import CoreData

class AddToLibrary{
    
    static func addToAppleMusicLibrary(_ songID: String, completion: @escaping (Bool) -> Void ){
        
        MPMediaLibrary().addItem(withProductID: songID, completionHandler: {(ent, err) in
            
            if err != nil{
                
                completion(false)
            }
        
            completion(true)
        })
    }
    
    static func addToSpotifyLibrary(_ song: BasicSong, completion: @escaping (Bool) -> Void){
        
        DispatchQueue.global().async {
            
            if let track = song as? SPTPartialTrack {
                
                SPTYourMusic.saveTracks([track], forUserWithAccessToken: auth?.session.accessToken){ err, callback in
                    
                    if err != nil{
                        
                        completion(false)
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    static func addToGuestLibrary(_ songID: String, completion: @escaping (Bool) -> Void){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
        newSong.setValue(songID, forKey: "storedID")
        newSong.setValue(Date(), forKey: "downloaded")
        
        //now try to save it
        do{
            try context.save()
        }catch{
            
            completion(false)
        }
        
        completion(true)
    }
}
