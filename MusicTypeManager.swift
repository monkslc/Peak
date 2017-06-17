//
//  MusicTypeManager.swift
//  Aud
//
//  Created by Connor Monks on 6/17/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class MusicTypeManager{
    
    enum MusicType: Int{
        //enum to determine how the user is going to listen to music
        
        case AppleMusic = 0
        case Guest
        case Spotify
    }
    
    static func convertMusicTypeToString(_ musicType: MusicType) -> String{
        
        switch musicType{
            
        case .AppleMusic:
            return "Apple Music"
            
        case .Spotify:
            return "Spotify"
            
        case .Guest:
            return "Guest"
        }
    }
    
    static func convertStringToMusicType(_ musicTypeString: String) -> MusicType{
        
        switch musicTypeString{
            
        case "Apple Music":
            return .AppleMusic
            
        case "Spotify":
            return .Spotify
            
        default:
            return .Guest
        }
    }
}
