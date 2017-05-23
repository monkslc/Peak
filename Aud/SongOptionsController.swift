//
//  SongOptionsController.swift
//  Peak
//
//  Created by Connor Monks on 4/15/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class SongOptionsController: UIAlertController {

    /**************NOTES: 
 
 
 What changes how we handle a song?
     
     - If the player is a guest, well they can't play so check for the item in the cell being a Song
        - If it's a song though, the player might be Apple Music but they are searching the Apple Music Store
     
     - If the player does not have the item in the library, they need an option to add it
     - We want to check if the player is a contributor or not
     - 
     
Let's go through all the different use cases
     
     - Apple Music User Library (MPMediaItem)
        - Play Now
        - Play Next
        - Play Last
        - Play Album
        - Play Artist
        - Shuffle Library (or Recents)
     
     - Apple Music User Searching Store (Song - Play with Song id)
        - Play Now
        - Add to Library
     
     - Apple Music Library Contributor (MP Media Item)
        - Send to Group Queue
     
     
     - Apple Music Search Contributor (Song)
        - Send to Group Queue
     
     - Spotify Library (SPTTrack)
        - Play Now
        - Play Next
        - Play Last
        - Play Album
        - Play Artist
        - Shuffle Library (or Recents)
     
     
     - Spotify Search Store (SPTTrack)
        - Play Now 
        - Play NExt
        - Play Last
        - Play Album
        - Play Artist
        - Add to Library
     
     - Spotify Library Contributor (SPTTrack)
        - Send to Group Queue
     
     - Spotify Search Controibutor (SPTTrack)
        - Send to Group Queue
        - Add to Library
     
     - Guest Library (Song)
        -
     
     - Guest Search Store (Song)
        -
     
     - Guest Library Contributor (Song)
        - Send to Group Queue
     
     - Guest Search Contributor (Song)
        - Send to Group QUeue
        - Add to Library
 
 
    - Contributor we need an add to group queue
    - Library we need to add all the library options
        - *****UNLESS WE ARE A GUEST
     
    
     
What do we need to check?:
     
     - If we are receiving a Song
        - This could mean we are Apple Music Searching a store or...
        - We are a GUEST
     
     - If we are a Contributor
        - Because the Contributor is going to have different options
     
     - If the song is not in our library
     
     
     Sudo:
     - If we are not a contributor and we are not receiving a song [And the song is not in our library]:
        - Normal Options 
     
     - If we are receiving a song and are not a Guest [the song isn't in our library so add to library]:
        - Apple Music Store Options
     
     -If we are a contributor [If the song is not in our library, add an add to library option]:
        - Show Contributor Options
     
     - If the song is not in our library: 
        - Add to library option
     
     
     Adjustments we need to make: 
        - Method getting called needs, to pass whether the song is in the library or not
        - Pass a Basic Song into the method 
     
     
     - Method Call (Song, In Library?)
        - If we are a contributor:
            - Show Contributor Options
     
        - Else: 
            - If we are a song: 
                - If we are a Guest:
                    - Show Guest Options
     
                - Else:
                    - Show Apple Music Store Options
     
            - Else: 
                - Show Music Options
     
        - If the song is not in our library:
            - Show add to library options
     
     
 
 
 
 **********************/
    
    
    
    
    enum SenderType {
        
        case Library
        case Search
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    //We only want to be able to delete if it is in our library
    //We don't want to be able to shuffle if we are a guest
    
    /*MARK: METHOD TO DETERMINE WHAT ALERTS NEED TO BE ADDED*/
    func addAlerts(song: BasicSong, inLibrary: Bool, library: [BasicSong]?, recents: [BasicSong]?){
        
        if peakMusicController.playerType == .Contributor{
            
            addContributorAlerts(song)
            
        }else{
            
            if let theSong: Song = song as? Song{
                
                if peakMusicController.musicType == .Guest && inLibrary == true{
                    
                    addGuestAlerts(theSong)
                    
                } else{
                    
                    addAppleMusicStoreAlerts(theSong)
                }
                
            } else{
                
                addPlaybackAlerts(song)
            }
        }
        
        
        
        if library != nil && peakMusicController.musicType != .Guest{
            
            addShuffleAlerts(shuffle: library!, isLibrary: true)
        } else if recents != nil && peakMusicController.musicType != .Guest{
            
            addShuffleAlerts(shuffle: recents!, isLibrary: false)
        }
        
        
        if inLibrary == false{
            
            addToLibraryAlerts(song)
        }
        
        //Now add the cancel buttom
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    
    /*MARK: METHODS TO ADD ALERTS*/
    private func addContributorAlerts(_ song: BasicSong){
        
        addAction(Alerts.sendToGroupQueueAlert(song))
    }
    

    private func addGuestAlerts(_ song: Song){
        
        addAction(Alerts.createDeleteAction(song))
    }
    
    private func addAppleMusicStoreAlerts(_ song: Song){
        
        addAction(Alerts.playNowAlert(song))
    }
    
    
    private func addPlaybackAlerts(_ song: BasicSong){
        
        addAction(Alerts.playNowAlert(song))
        addAction(Alerts.playNextAlert(song))
        addAction(Alerts.playLastAlert(song))
        addAction(Alerts.playAlbumAlert(song))
        addAction(Alerts.playArtistAlert(song))
    }
    
    private func addShuffleAlerts(shuffle songs: [BasicSong], isLibrary: Bool){
        
        addAction(Alerts.shuffleAlert(songs, isLibrary: isLibrary))
    }
    
    private func addToLibraryAlerts(_ song: BasicSong){
        
        addAction(Alerts.addToLibraryAlerts(song))
    }
    
    
    
    /*MARK: Methods that determine what alerts to add*/
    /*func addLibraryAlerts(sender: UILongPressGestureRecognizer, library: [BasicSong], recents: [BasicSong]){
        
        //Check the user's Music Type
        if peakMusicController.musicType == .AppleMusic{
            
            //Change what appears based on the user's type
            if peakMusicController.playerType != .Contributor {
                
                addAppleMusicNonContributor(library: library as! [MPMediaItem], recents: recents as! [MPMediaItem], sender, comingFrom: .Library)
                
            } else { //User is a contributor so display those methods
                
                addContributor(sender)
            }
            
            
        } else if peakMusicController.musicType == .Guest{
            //If here we are a guest so display the guest options
            
            if peakMusicController.playerType == .Contributor{
                
                addContributor(sender)
            }
            
            
            addGuest(sender)
            
        }else if peakMusicController.musicType == .Spotify{
            
            if peakMusicController.playerType == .Contributor{
                
                addContributor(sender)
            }else{
                
                addSpotify(sender)
            }
        }
        
        
        //Add a cancel action
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    
    /*NEEDS TO BE UPDATED: Why is Delegate View Controller a param?*/
    func addSearchAlerts(_ sender: UILongPressGestureRecognizer,delegateViewController: BeastController){
        
        if peakMusicController.playerType != .Contributor {
            
            //Get the cell
            if let _: SongCell = sender.view as? SongCell{
                
            
                //We need to fetch the library and we need to fetch the recents
                
                //We want to check if the user is a contributor or not and give the song options accordingly
                
                //This is wrong here, we want to see if we are receiving as Song
                if peakMusicController.musicType == .AppleMusic{
                    
                    if let library: [MPMediaItem] = delegateViewController.libraryViewController?.userLibrary.itemsInLibrary as? [MPMediaItem]{
                        
                        let recents: [MPMediaItem] = delegateViewController.libraryViewController?.userLibrary.recents as! [MPMediaItem]
                        
                        addAppleMusicNonContributor(library: library, recents: recents, sender, comingFrom: .Search)
                    }
                    
    
                } else{ //Searching
                    
                    addSearchingAppleMusicOptionsNonContributor(sender)
                }
            }
            
        } else { //User is a contributor so display those methods
            
            //User is a contributor so add those actions
            addContributor(sender)
            
            if let cell: SongCell = sender.view as? SongCell {
                
                if let _: MPMediaItem = cell.itemInCell as? MPMediaItem{
                    addSearchingAppleMusicOptionsNonContributor(sender)
                }
    
            }
        }
        
        //Add a cancel action
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    
    /*MARK: The Methods that add the alerts*/
    func addSearchingAppleMusicOptionsNonContributor(_ sender: UILongPressGestureRecognizer){
    
        //Check if the user is a guest
        if peakMusicController.musicType != .Guest{
            
            addAction(Alerts.playNowAlert(sender))
        }
        
        addAction(Alerts.addToLibraryAlert(sender))
        
    }
    
    func addSearchingAppleMusicOptionsContributor(_ sender: UILongPressGestureRecognizer){
        
        addAction(Alerts.addToLibraryAlert(sender))
    }
    
    func addAppleMusicNonContributor(library: [MPMediaItem], recents: [MPMediaItem],_ sender: UILongPressGestureRecognizer, comingFrom musicType: SenderType){
        
        //Library Alerts
        addAction(Alerts.playNowAlert(sender))
        addAction(Alerts.playNextAlert(sender))
        addAction(Alerts.playLastAlert(sender))
        addAction(Alerts.playAlbumAlert(sender))
        addAction(Alerts.playArtistAlert(sender))
        
        //if we are not coming from search add
        if musicType != .Search{
            
            addAction(Alerts.shuffleAlert(sender, library: library, recents: recents))
        }
   
    }
    
    func addContributor(_ sender: UILongPressGestureRecognizer){
        
        
        addAction(Alerts.sendToGroupQueueAlert(sender))
    }
    
    func addGuest(_ sender: UILongPressGestureRecognizer){
        
        addAction(Alerts.createDeleteAction(sender))
    }
    
    
    /*SPOTIFY ALERTS*/
    func addSpotify(_ sender: UILongPressGestureRecognizer){
        
        addAction(Alerts.playNowAlert(sender))
        addAction(Alerts.playNextAlert(sender))
        addAction(Alerts.playLastAlert(sender))
        addAction(Alerts.playAlbumAlert(sender))
        addAction(Alerts.playArtistAlert(sender))
    }*/
    
    /*MARK: */
    func presentMe(_ sender: UILongPressGestureRecognizer, presenterViewController: UIViewController){
        
        modalPresentationStyle = .popover
        let ppc = popoverPresentationController
        ppc?.sourceRect = (sender.view?.bounds)!
        ppc?.sourceView = sender.view
        presenterViewController.present(self, animated: true, completion: nil)
    }

}
