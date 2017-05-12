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
    
    //Method to perform an action on an MPMediaItem
    private static func performSongAction(_ sender: UILongPressGestureRecognizer, _ method: ([BasicSong]) -> Void){
        
        if let holder: BasicSongHolder = sender.view as? BasicSongHolder{
            
            method([holder.getBasicSong()])
        }
    }
    
    private static func performCollectionAction(_ sender: UILongPressGestureRecognizer, _ method: (BasicSong) -> Void){
        //Difference is in the type of method being called
        
        //check if we have a cell or a recents
        if let cell: SongCell = sender.view as? SongCell {
            
            method(cell.itemInCell)
        
        }
    }
    
    static func playNowAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Now", style: .default, handler: {(alert) in
        
            if let holder: BasicSongHolder = sender.view as? BasicSongHolder{
                
                if let song: Song = holder.getBasicSong() as? Song{
                    
                    peakMusicController.currPlayQueue.removeAll()
                    peakMusicController.systemMusicPlayer.setQueueIds([song.getId()])
                    peakMusicController.systemMusicPlayer.startPlaying()
                } else {
                    
                    peakMusicController.play([holder.getBasicSong()])
                }
                
            }
        })
        
    }
    
    static func playNextAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        

        
        return UIAlertAction(title: "Play Next", style: .default, handler: {(alert) in
        
            peakMusicController.delegate?.showSignifier()
            performSongAction(sender, peakMusicController.playNext(_:))
        })
    }
    
    
    static func playLastAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        

        return UIAlertAction(title: "Play Last", style: .default, handler: {(alert) in
        
            peakMusicController.delegate?.showSignifier()
            performSongAction(sender, peakMusicController.playAtEndOfQueue(_:))
        })
    }
    
    
    static func playAlbumAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        return UIAlertAction(title: "Play Album", style: .default, handler: {(alert) in
            
            performSongAction(sender, peakMusicController.play(album:))
        })
    }
    
    static func playArtistAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        return UIAlertAction(title: "Play Artist", style: .default, handler: {(alert) in
        
            performSongAction(sender, peakMusicController.play(artist:))
        })
    }
    
    
    static func shuffleAlert(_ sender: UILongPressGestureRecognizer, library: [BasicSong], recents: [BasicSong]) -> UIAlertAction{
        
        //check whether we want to shuffle library or recents
        if let _: SongCell = sender.view as? SongCell{
            //shuffle library
            
            return UIAlertAction(title: "Shuffle Library", style: .default, handler: {(alert) in
            
                peakMusicController.play(peakMusicController.shuffleQueue(shuffle: library))
            })
            
        }else if let _: RecentsAlbumView = sender.view as? RecentsAlbumView{
            //shuffle recents
            
            return UIAlertAction(title: "Shuffle Recents", style: .default, handler: {(alert) in
            
                peakMusicController.play(peakMusicController.shuffleQueue(shuffle: recents))
            })
            
            
        }
        
        return UIAlertAction()
    }
    
    static func sendToGroupQueueAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        return UIAlertAction(title: "Add to Group Queue", style: .default, handler: {(alert) in
            
            (peakMusicController.delegate as! BeastController).showSignifier()
            
            if let holder: BasicSongHolder = sender.view as? BasicSongHolder{
                
                SendingBluetooth.sendSongIdToHost(song: holder.getBasicSong(), error:{})
            }
        })
    }
    
    
    static func createDeleteAction(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        //Create the alert here and return it
        return UIAlertAction(title: "Delete Song", style: .default, handler: {(alert) in
            
            if let holder: BasicSongHolder = sender.view as? BasicSongHolder{
                
                let songToDelete = holder.getBasicSong()
                
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
                        if songInCD.storedID == songToDelete.getId(){
                            
                            context.delete(result as! NSManagedObject)
                            break
                        }
                    }
                    
                    try context.save()
                    
                } catch {
                    
                    print("To dance beneath the diamond sky with one hand waving free")
                }
                
                
                
                (peakMusicController.delegate as! BeastController).showSignifier()
                (peakMusicController.delegate as! BeastController).libraryViewController?.userLibrary.fetchLibrary()
                
            }
        })
    }
    
    static func addToLibraryAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        
        return UIAlertAction(title: "Add to Library", style: .default, handler: {(alert) in
            
            (peakMusicController.delegate as! BeastController).showSignifier()
            
            
            let cell:SongCell = (sender.view as? SongCell)!
            
            if peakMusicController.musicType == .AppleMusic{
                
                
                MPMediaLibrary().addItem(withProductID: (cell.itemInCell.getId()), completionHandler: {(ent, err) in
                    
                    /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                    /*******DO SOMETHING WITH THE ERROR******/
                })
                
                
            } else if peakMusicController.musicType == .Guest{
                
                    
                //Add the song to core data here, and to the users current library
                    
                //check if the user has already downloaded it
                    
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                    
                let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                newSong.setValue(cell.itemInCell.getId(), forKey: "storedID")
                newSong.setValue(Date(), forKey: "downloaded")
                    
                    
                    
                //now try to save it
                do{
                    try context.save()
                }catch{
                        
                    print("The fiddler he now steps to the road")
                }
                
            }
            
            
            (peakMusicController.delegate as! LibraryViewController).userLibrary.fetchLibrary()
            
        })
    }
    
}
