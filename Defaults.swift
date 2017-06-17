//
//  Defaults.swift
//  Aud
//
//  Created by Connor Monks on 6/17/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class Defaults{
    
    
    static var musicType: MusicTypeManager.MusicType{
        
        get{
            
            return getMusicType()
        }
        
        set (newValue){
            
            setMusicType(newValue)
        }
    }
    
    private static func getMusicType() -> MusicTypeManager.MusicType{
        
        let defaults = UserDefaults.standard
        if let musicType = defaults.string(forKey: "Music Type"){
            
            return MusicTypeManager.convertStringToMusicType(musicType)
        }else{
            
            return .Guest
        }
        
    }
    
    private static func setMusicType(_ musicType: MusicTypeManager.MusicType){
        
        let defaults = UserDefaults.standard
        defaults.set(MusicTypeManager.convertMusicTypeToString(musicType), forKey: "Music Type")
    }
}
