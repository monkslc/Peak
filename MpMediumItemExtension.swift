//
//  MpMediumItemExtension.swift
//  Peak
//
//  Created by Cameron Monks on 5/2/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPMediaItem: BasicSong {
    var type: PeakMusicController.MusicType {
        return .AppleMusic
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
    
    func getId() -> String { return "\(self.playbackStoreID)" }
    func getTrackName() -> String { return self.title! }
    func getCollectionName() -> String { return albumTitle! }
    func getArtistName() -> String { return artist ?? "No Artist" }
    func getTrackTimeMillis() -> Int {return Int(self.playbackDuration); }
    func getImage() -> UIImage? {
        
        if albumCover != nil{ //Check if we already have the album cover
            
            return albumCover
        }else{
            
            //We don't have the album cover so let's see if we can get it
            if let image = artwork?.image(at: CGSize()){
                
                albumCover = image
                return image
            }else{
                
                //Let's try fetching it from the internet
                ConnectingToInternet.getSong(id: getId()){
                    
                    self.albumCover = $0.getImage()
                    
                    //Now let's try going through this again to return the new albumCover
                    DispatchQueue.main.async {
                        
                        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
                    }
                    
                }
            }
        }
        
        return artwork?.image(at: CGSize());
    }
    
    func getDateAdded() -> Date? { return dateAdded }
    
    func isEqual(to song: BasicSong) -> Bool {
        
        if playbackStoreID == song.getId(){
            return true
        }
        
        return false
    }
}
