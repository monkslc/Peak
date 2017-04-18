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
    private static func performSongAction(_ sender: UILongPressGestureRecognizer, _ method: ([MPMediaItem]) -> Void){
        
        // check if we have a cell or a recents
        if let cell: SongCell = sender.view as? SongCell{
            //We have a cell
            
            method([cell.mediaItemInCell])
        } else if let recent: RecentsAlbumView = sender.view as? RecentsAlbumView{
            
            method([recent.mediaItemAssocWithImage])
        }
        
    }
    
    private static func performCollectionAction(_ sender: UILongPressGestureRecognizer, _ method: (MPMediaItem) -> Void){
        
        //check if we have a cell or a recents
        if let cell: SongCell = sender.view as? SongCell {
            
            method(cell.mediaItemInCell)
        } else {
            
        }
    }
    
    static func playNowAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        return UIAlertAction(title: "Play Now", style: .default, handler: {(alert) in
        
            //check if we are getting a cell or a recents view
            if let cell: SongCell = sender.view as? SongCell{
                //we have a cell
                
                //check if we have are searching apple MUsic
                if cell.songInCell == nil{
                    //Library
                    
                    peakMusicController.play([cell.mediaItemInCell])
                    
                } else{
                    //Apple Music
                    
                    peakMusicController.systemMusicPlayer.setQueueWithStoreIDs([(cell.songInCell?.id)!])
                    peakMusicController.systemMusicPlayer.play()
                }
                
            } else if let recent: RecentsAlbumView = sender.view as? RecentsAlbumView{
                //we have a recents album
                
                peakMusicController.play([recent.mediaItemAssocWithImage])
            }
        })
        
    }
    
    
    
    static func playNextAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        return UIAlertAction(title: "Play Next", style: .default, handler: {(alert) in
        
            performSongAction(sender, peakMusicController.playNext(_:))
        })
    }
    
    
    static func playLastAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction {
        
        return UIAlertAction(title: "Play Last", style: .default, handler: {(alert) in
        
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
    
    
    static func shuffleAlert(_ sender: UILongPressGestureRecognizer, library: [MPMediaItem], recents: [MPMediaItem]) -> UIAlertAction{
        
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
            
            (peakMusicController.delegate as! LibraryViewController).showSignifier()
            
            var songId = String()
            
            //check if we have a song cell or a recents view and get the song id
            if let cell: SongCell = sender.view as? SongCell {
                //we have a cell
                
                //Check if it is in our library or in Apple Music/Guest Library
                if cell.songInCell == nil{
                    //Library
                    
                    songId = cell.mediaItemInCell.playbackStoreID
                } else {
                    //Apple Music/GuestLibrary
                    
                    songId = (cell.songInCell?.id)!
                }
                
            } else if let recent: RecentsAlbumView = sender.view as? RecentsAlbumView {
                //we have recents
                
                songId = recent.mediaItemAssocWithImage.playbackStoreID
            }
            
            //send the song id
            SendingBluetooth.sendSongIdToHost(id: "\(songId)", error: {
                
                //not sure what to do if we get an error here yet
            })
            
            
            
        })
    }
    
    
    static func createDeleteAction(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        //Create the alert here and return it
        return UIAlertAction(title: "Delete Song", style: .default, handler: {(alert) in
            
            var songToDelete = Song(id: "", trackName: "", collectionName: "", artistName: "", trackTimeMillis: 0, image: nil, dateAdded: nil)
            
            if let cell: SongCell = sender.view as? SongCell{
                
                songToDelete = cell.songInCell!
            } else if let album: RecentsAlbumView = sender.view as? RecentsAlbumView {
                
                songToDelete = album.songAssocWithImage!
            }
            
            
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
                    if songInCD.storedID == songToDelete.id{
                        
                        context.delete(result as! NSManagedObject)
                        break
                    }
                }
                
                try context.save()
                
            } catch {
                
                print("To dance beneath the diamond sky with one hand waving free")
            }
            
            
            
            (peakMusicController.delegate as! LibraryViewController).showSignifier()
            (peakMusicController.delegate as! LibraryViewController).fetchLibrary()
        })
    }
    
    
    static func addToLibraryAlert(_ sender: UILongPressGestureRecognizer) -> UIAlertAction{
        
        
        return UIAlertAction(title: "Add to Library", style: .default, handler: {(alert) in
            
            
            
            (peakMusicController.delegate as! LibraryViewController).showSignifier()
            
            
            
            let cell:SongCell = (sender.view as? SongCell)!
            
            if peakMusicController.musicType == .AppleMusic{
                
                MPMediaLibrary().addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                    
                    /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                    /*******DO SOMETHING WITH THE ERROR******/
                })
                
                
            } else if peakMusicController.musicType == .Guest{
                
                
                
                if let songToAdd = cell.songInCell{
                    
                    //Add the song to core data here, and to the users current library
                    
                    //check if the user has already downloaded it
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                    newSong.setValue(songToAdd.id, forKey: "storedID")
                    newSong.setValue(Date(), forKey: "downloaded")
                    
                    
                    
                    //now try to save it
                    do{
                        try context.save()
                    }catch{
                        
                        print("The fiddler he now steps to the road")
                    }
                    
                }
                
            }
            
            
            (peakMusicController.delegate as! LibraryViewController).fetchLibrary()
            
            //self.searchedSongsTableView.reloadData()
        })
    }
    
}
