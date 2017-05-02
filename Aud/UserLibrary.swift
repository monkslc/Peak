//
//  UserLibrary.swift
//  Peak
//
//  Created by Connor Monks on 5/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import CoreData

protocol UserLibraryDelegate{
    
    func libraryItemsUpdated()
}

enum LibraryItem{
    
    case MediaItem(MPMediaItem)
    case GuestItem(Song)
}

class UserLibrary{
    
    /*MARK: INITIALIZERS*/
    init(){
        
        //Add the listener for a library change
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudLibraryChanged), name: .MPMediaLibraryDidChange, object: MPMediaLibrary.default())
    }
    
    /*MARK: Delegate*/
    var delegate: UserLibraryDelegate?
    
    
    /*MARK: PROPERTIES*/
    
    //Holds all of the items in the user's library
    var itemsInLibrary = [LibraryItem](){
        
        didSet{
            
            delegate?.libraryItemsUpdated()
        }
    }
    
    //Holds the most recently downloaded songs
    var recents = [LibraryItem]()
    
    
    /*MARK: Fetch FUNCITONS*/
    func fetchLibrary(){
        
        if peakMusicController.musicType == .AppleMusic{
            
            fetchAppleMusic()
        } else if peakMusicController.musicType == .Guest{
            
            fetchGuestMusic()
        }
    }
    
    
    private func fetchAppleMusic(){
        
        //Temp Sort Method
        func sort(_ item1: MPMediaItem, _ item2: MPMediaItem) -> Bool {
            
            if item1.dateAdded > item2.dateAdded {
                return true
            } else {
                return false
            }
        }
        
        
        //Do this async
        DispatchQueue.global().async {
            
            //Fetch by artists
            
            let retreivedItems = MPMediaQuery.artists().items
            
            //Retreive the recently played items
            let maxItemsToRetrieve = min(retreivedItems!.count, 20)
            var recentlyPlayedItems = retreivedItems
            recentlyPlayedItems = recentlyPlayedItems?.sorted(by: sort)
            
            
            //Convert our Media Items to Library Items
            var libItems = [LibraryItem]()
            for item in retreivedItems!{
                
                libItems.append(.MediaItem(item))
            }
            
            let recentList = recentlyPlayedItems?[0..<maxItemsToRetrieve]
            
            var recentItems = [LibraryItem]()
            for item in recentList!{
                
                recentItems.append(.MediaItem(item))
            }
            
            
            
            DispatchQueue.main.async {
                
                self.recents = recentItems
                self.itemsInLibrary = libItems
            }
        }
    }
    
    private func fetchGuestMusic(){
        
        //Method for finishing the fetch
        func finishFetchForGuest(_ storedSongs: [Song]){
            
            //Temp Sort Method for Date
            func sort(_ item1: Song, _ item2: Song) -> Bool {
                
                if item1.dateAdded! > item2.dateAdded! {
                    return true
                } else {
                    return false
                }
            }
            
            func sortAlpha(_ item1: Song, _ item2: Song) -> Bool{
                
                var artistOne = item1.artistName
                var artistTwo = item2.artistName
                
                if item1.artistName.hasPrefix("The"){
                    
                    artistOne = item1.artistName.subString(startIndex: 3)
                }
                
                if item2.artistName.hasPrefix("The"){
                    
                    artistTwo = item2.artistName.subString(startIndex: 3)
                }
                
                if artistOne > artistTwo {
                    return false
                }else {
                    return true
                }
            }
            
            //Retreive the recently played items
            
            
            DispatchQueue.global().async {
                
                let maxItemsToRetrieve = min(storedSongs.count, 20)
                
                //Get the recently downloaded Items
                let recentlyDownloadedItems = storedSongs.sorted(by: sort)
                let recentList = recentlyDownloadedItems[0..<maxItemsToRetrieve]
                
                let sortedGuestItems = storedSongs.sorted(by: sortAlpha)
                
                //Convert our songs to library items
                var libItems = [LibraryItem]()
                for item in sortedGuestItems{
                    
                    libItems.append(.GuestItem(item))
                }
                
                var recentItems = [LibraryItem]()
                for item in recentList{
                    
                    recentItems.append(.GuestItem(item))
                }
                
                DispatchQueue.main.async {
                    
                    self.recents = recentItems
                    self.itemsInLibrary = libItems
                }
            }
        }
        
        
        
        //Fetch Songs From Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredSong")
        request.returnsObjectsAsFaults = false
        
        var storedSongs = [Song]()
        
        do{
            
            let results = try context.fetch(request)
            
            let serialQueue = DispatchQueue(label: "myqueue")
            var counter = 0
            //loop through all the song Entities
            for result in results {
                
                let song = result as! StoredSong
                
                //Create Song Entities and add them to the accumulator variable
                ConnectingToInternet.getSong(id: song.value(forKey: "storedID") as! String, completion: {(retSong) in
                    
                    var songToAppend = retSong
                    songToAppend.dateAdded = song.downloaded! as Date
                    
                    
                    
                    serialQueue.sync {
                        storedSongs.append(songToAppend)
                    }
                    
                    
                    counter += 1
                    if counter == results.count{
                        finishFetchForGuest(storedSongs)
                    }
                })
                
                
                
                
            }
            
        } catch {
            
            print("These Visions of Johanna, are now all that remain")
        }
    }
    
    
    
    /*MARK: Notification Methods*/
    @objc func iCloudLibraryChanged(){
        
        fetchLibrary()
    }
    
}
