//
//  SpotifyTrackExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

extension SPTPartialTrack: BasicSong {
    var type: PeakMusicController.MusicType {
        return .Spotify
    }
    
    /*PRIVATE STRUCT TO STORE PROPERTIES*/
    private struct customProperties{
        
        static var cover: UIImage?
    }
    
    
    /*PROPERTIES*/
    var albumCover: UIImage?{
        
        get{
            
            return objc_getAssociatedObject(self, &customProperties.cover) as? UIImage ?? nil
        }
        set{
            
            if let unwrappedValue = newValue{
                
                objc_setAssociatedObject(self, &customProperties.cover, unwrappedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    func getId() -> String{
        
        return playableUri.absoluteString
    }
    
    func getTrackName() -> String{
        
        return name ?? "MEME LIKE BUTHOLE"
    }
    
    func getCollectionName() -> String{
        
        return album.name
    }
    
    func getArtistName() -> String{
        
        if artists.count > 0 {
            
            return (artists[0] as! SPTPartialArtist).name
        }
        
        return "Artist could not be found"
    }
    
    func getTrackTimeMillis() -> Int{
        
        return Int(duration)
    }
    
    func getImage() -> UIImage?{
        
        if albumCover != nil{
        
            return albumCover
        } else{
            
            //We've got to fetch it here
            var albumImage = UIImage()
            
            do{
                try albumImage = UIImage(data: Data(contentsOf: album.largestCover.imageURL))!
            } catch{
                
                print("Error getting the album image")
            }
            
            albumCover = albumImage
            return albumImage
            
        }
        
        
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

extension SPTPlaybackTrack: BasicSong {
    var type: PeakMusicController.MusicType {
        return .Spotify
    }

    
    
    /*PRIVATE STRUCT TO STORE PROPERTIES*/
    private struct customProperties{
        
        static var cover: UIImage?
    }
    
    
    /*PROPERTIES*/
    var albumCover: UIImage?{
        
        get{
            
            return objc_getAssociatedObject(self, &customProperties.cover) as? UIImage ?? nil
        }
        set{
            
            if let unwrappedValue = newValue{
                
                objc_setAssociatedObject(self, &customProperties.cover, unwrappedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    func getId() -> String{
        
        return uri
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
        
         if albumCover != nil{
         
         return albumCover
         } else{
         
         //We've got to fetch it here
         var albumImage = UIImage()
         
         do{
            
            try albumImage = UIImage(data: Data(contentsOf: URL(string: albumCoverArtURL!)!))!
         } catch{
         
         print("Error getting the album image")
         }
         
         albumCover = albumImage
         return albumImage
         
         }
        
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
