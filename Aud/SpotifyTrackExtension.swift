//
//  SpotifyTrackExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

extension SPTTrack: BasicSong{
    
    func getId() -> String{
        
        return identifier
    }
    
    func getTrackName() -> String{
        
        return name
    }
    
    func getCollectionName() -> String{
        
        return album.name
    }
    
    func getArtistName() -> String{
        
        if artists.count > 0{
            
            return (artists[0] as! SPTPartialArtist).name
        }
        
        return "Artist could not be found"
    }
    
    func getTrackTimeMillis() -> Int{
        
        return Int(duration)
    }
    
    func getImage() -> UIImage?{
        
        return album.covers[0] as? UIImage
    }
    
    func getDateAdded() -> Date?{
        
        return nil
    }
    
    func isEqual(to song: BasicSong) -> Bool{
        
        if name == song.getTrackName(){
            return true
        } else{
            
            return false
        }
    }
}


extension SPTPlaybackTrack: BasicSong{
    
    func getId() -> String{
        
        return "Spotify Playback Track"
    }
    
    func getTrackName() -> String{
        
        return name
    }
    
    func getCollectionName() -> String{
        
        return albumName
    }
    
    func getArtistName() -> String{
        
        return artistName
    }
    
    func getTrackTimeMillis() -> Int{
        
        return Int(duration)
    }
    
    func getImage() -> UIImage?{
        
        /*THIS IS WHERE WE WANT TO FETCH THE IMAGE USING self.albumURL or something like that*/
        return #imageLiteral(resourceName: "ProperPeakyAlbumView")
    }
    
    func getDateAdded() -> Date?{
        
        return nil
    }
    
    func isEqual(to song: BasicSong) -> Bool{
        
        if name == song.getTrackName(){
            return true
        } else{
            
            return false
        }
    }
}
