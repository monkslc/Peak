//
//  Alerts.swift
//  Peak
//
//  Created by Connor Monks on 3/31/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import CoreData

class Alerts {
    
    static func playNowAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Now", style: .default){ alert in
            
            if let mySong: Song = song as? Song{
                
                peakMusicController.currPlayQueue.removeAll()
                peakMusicController.systemMusicPlayer.setQueueIds([mySong.getId()])
                peakMusicController.systemMusicPlayer.startPlaying()
                
            } else{
                
                peakMusicController.play([song])
            }
        }
    }
    
    
    static func playNextAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Next", style: .default){ alert in

            peakMusicController.delegate?.showSignifier()
            peakMusicController.playNext([song])
        }
    }
    
    static func playLastAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Last", style: .default){ alert in
            
            peakMusicController.delegate?.showSignifier()
            peakMusicController.playAtEndOfQueue([song])
        }
    }
    
    
    static func playAlbumAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Album", style: .default){ alert in
            
            peakMusicController.play(album: [song])
        }
    }
    
    
    static func playArtistAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Artist", style: .default){ alert in

            peakMusicController.play(artist: [song])
        }
    }
    
    
    
    static func shuffleAlert(_ songs: [BasicSong], isLibrary: Bool) -> UIAlertAction{
        
        if isLibrary{
            
            return UIAlertAction(title: "Shuffle Library", style: .default){ alert in
                
                
                peakMusicController.play(peakMusicController.shuffleQueue(shuffle: songs))
            }
        } else{
            
            return UIAlertAction(title: "Shuffle Recents", style: .default){ alert in
                
                peakMusicController.play(peakMusicController.shuffleQueue(shuffle: songs))
            }
            
        }
        
    }
    
    
    
    static func sendToGroupQueueAlert(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Add to Group Queue", style: .default){ alert in
            
            (peakMusicController.delegate as! BeastController).showSignifier()
            
            SendingBluetooth.sendSongIdToHost(song: song){
                
                print("\n\nWe got an error, I think\n\n")
            }
        }
    }
    
    
    static func createDeleteAction(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Delete Song", style: .default){ alert in
            
            //now delete it
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredSong")
            request.returnsObjectsAsFaults = false
            
            do{
                
                let results = try context.fetch(request)
                
                for result in results{
                    
                    let songInCD = result as! StoredSong
                    
                    //check if our songs match and if so delete
                    if songInCD.storedID == song.getId(){
                        
                        context.delete(result as! NSManagedObject)
                        break
                    }
                }
                
                try context.save()
                
            } catch {
                
                print("To dance beneath the diamond sky with one hand waving free")
            }
            
            
            
            (peakMusicController.delegate as! BeastController).showSignifier()
            (peakMusicController.delegate as! BeastController).libraryViewController.userLibrary.fetchLibrary()
        }
    }
    
    
    static func addToLibraryAlerts(_ song: BasicSong) -> UIAlertAction{
        
        return UIAlertAction(title: "Add to Library", style: .default){ alert in
            
            (peakMusicController.delegate as! BeastController).showSignifier()
            
            if peakMusicController.musicType == .AppleMusic{
                
                MPMediaLibrary().addItem(withProductID: song.getId()){ ent, err in

                    if err != nil{
                        
                        print("We had an error adding items to the library: \(err!)")
                    }
                    
                }
            } else if peakMusicController.musicType == .Guest{
                
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                newSong.setValue(song.getId(), forKey: "storedID")
                newSong.setValue(Date(), forKey: "downloaded")
                
                
                
                //now try to save it
                do{
                    try context.save()
                }catch{
                    
                    print("The fiddler he now steps to the road")
                }
            } else if peakMusicController.musicType == .Spotify{
                
                /*UPDATE: WE NEED TO ADD THE ADD TO SPOTIFY CODE*/
            }
            
            
            
            (peakMusicController.delegate as! LibraryViewController).userLibrary.fetchLibrary()
        }
    }
    
}
