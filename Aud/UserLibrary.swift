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

class UserLibrary{
    
    /*MARK: INITIALIZERS*/
    init(){
        
        
        //Add the listener for a library change
        NotificationCenter.default.addObserver(self, selector: #selector(libraryItemsChanged), name: .systemMusicPlayerLibraryChanged, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(libraryItemsChanged), name: .musicTypeChanged, object: nil)
    }
    
    /*MARK: Delegate*/
    var delegate: UserLibraryDelegate?
    
    
    /*MARK: PROPERTIES*/
    
    //Holds all of the items in the user's library
    var itemsInLibrary = [BasicSong](){
        
        didSet{
            
            delegate?.libraryItemsUpdated()
        }
    }
    
    //Holds the most recently downloaded songs
    var recents = [BasicSong]()
    
    
    /*MARK: Fetch FUNCITONS*/
    func fetchLibrary(){
        
        //Start the animation here, end it after the fetch has completed
        
        if peakMusicController.musicType == .AppleMusic {
            
            fetchAppleMusic()
        } else if peakMusicController.musicType == .Guest {
            
            fetchGuestMusic()
        } else if peakMusicController.musicType == .Spotify{
            
            fetchSpotifyMusic()
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
            
            let recentList = recentlyPlayedItems?[0..<maxItemsToRetrieve]

            var tempRecent = [BasicSong]()
            for item in recentList!{
                
                tempRecent.append(item)
            }
            
            DispatchQueue.main.async {
                
                
                self.recents = tempRecent
                self.itemsInLibrary = retreivedItems!
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
                
                if artistTwo > artistOne{
                    
                    return true
                }
                
                //Check if the artists are equal so we can sort by album
                if artistTwo == artistOne{
                    
                    let albumOne = item1.collectionName
                    let albumTwo = item2.collectionName
                    
                    //See which one is greater
                    if albumTwo > albumOne{
                        
                        return true
                    }
                    
                    //check to see if the albums are the same so we can sort by song
                    if albumTwo == albumOne{
                        
                        let songTitleOne = item1.getTrackName()
                        let songTitleTwo = item2.getTrackName()
                        
                        if songTitleTwo > songTitleOne{
                            return true
                        }
                    }
                }
                
                return false
            }
            
            //Retreive the recently played items
            
            
            DispatchQueue.global().async {
                
                let maxItemsToRetrieve = min(storedSongs.count, 20)
                
                //Get the recently downloaded Items
                let recentlyDownloadedItems = storedSongs.sorted(by: sort)
                let recentList = recentlyDownloadedItems[0..<maxItemsToRetrieve]
                
                let sortedGuestItems = storedSongs.sorted(by: sortAlpha)
                
                //Convert our recents into an array
                var tempRecent = [BasicSong]()
                for song in recentList{
                    
                    tempRecent.append(song)
                }
                
                DispatchQueue.main.async {
                    

                    self.recents = tempRecent
                    self.itemsInLibrary = sortedGuestItems
                }
            }
        }
        
        
        
        //Fetch Songs From Core Data
        DispatchQueue.main.async {
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
                
                //Check if we have no results so we can make sure everything get's called a-okay
                if results.count < 1{
                    
                    self.delegate?.libraryItemsUpdated()
                }
                
            } catch {
                
                print("These Visions of Johanna, are now all that remain")
            }
        }
    }
    
    func fetchSpotifyMusic(){
    
        //Create a sort method
        func sortArtist(songOne: SPTTrack, songTwo: SPTTrack) -> Bool{
            
            var artistOne = songOne.getArtistName()
            var artistTwo = songTwo.getArtistName()
            
            if artistOne.hasPrefix("The"){
                
                artistOne = artistOne.subString(startIndex: 4)
            }
            
            if artistTwo.hasPrefix("The"){
                
                artistTwo = artistTwo.subString(startIndex: 4)
            }
            
            if artistTwo > artistOne {
                
                return true
            }
            
            //Check if they are the same and sort them by album
            if artistTwo == artistOne{
                
                let albumOne = songOne.getCollectionName()
                let albumTwo = songTwo.getCollectionName()
                
                if albumTwo > albumOne{
        
                    return true
                }
                
                //iF they are the same album, sort them by song
                if albumTwo == albumOne{
                    
                    // sort them by song
                    let songTitleOne = songOne.getTrackName()
                    let songTitleTwo = songTwo.getTrackName()
                    
                    if songTitleTwo > songTitleOne{
                        
                        return true
                    }
                }
                
            }
            
            return false
        }
        
        SPTYourMusic.savedTracksForUser(withAccessToken: auth?.session.accessToken){ err, callback in
            
            //Check if we got an error
            if err != nil{
                
                print(err!)
                return
            }
            var tempStorageForLibItems = [SPTTrack]()
            
            //Create a queue to update the library
            let libraryQueue = DispatchQueue(label: "library")
            
            func getLibraryItems(passingPage: SPTListPage){
                
                //Get the items from the page
                for item in passingPage.items {
                    
                    libraryQueue.sync {
                        tempStorageForLibItems.append(item as! SPTTrack)
                    }
                    
                }
                
                //See if we have another page to go through
                if passingPage.hasNextPage{
                    
                    
                    passingPage.requestNextPage(withAccessToken: auth?.session.accessToken){ err, callback in
                        
                        //recrusion
                        getLibraryItems(passingPage: callback as! SPTListPage)
                    }
                } else {
                    
                    libraryQueue.sync {
                        
                        //get the 20 most recent items
                        var userRecentItems = [SPTTrack]()
                        for songIndex in 0..<20{
                            
                            if tempStorageForLibItems.count > songIndex{
                                
                                userRecentItems.append(tempStorageForLibItems[songIndex])
                            }
                            
                        }
                        
                        self.recents = userRecentItems
                        
                        //Sort the items before we send them
                        tempStorageForLibItems.sort(by: sortArtist)
                        
                        //Now upload our library
                        self.itemsInLibrary = tempStorageForLibItems
                        
                        //Now let's go through and fetch the images for each spotify song
                        self.fetchSpottyImages()
                    }
                    
                }
            }
            
            getLibraryItems(passingPage: callback as! SPTListPage)
            
        }
        
    }
    
    
    //Method to fetch Spotify Images for songs in an attempt to reduce hangability in the library scrolling
    private func fetchSpottyImages(){
        
        //Loop through each item in the library and get the image
        for item in itemsInLibrary{
            _ = item.getImage()
        }
    }
    
    /*MARK: Notification Methods*/
    @objc func libraryItemsChanged(){
        
        print("Our Library Items Are Changing")
        DispatchQueue.global().async {
            
            self.fetchLibrary()
        }
        
    }
    
}
