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

    
    enum SenderType {
        
        case Library
        case Search
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    /*MARK: METHOD TO DETERMINE WHAT ALERTS NEED TO BE ADDED*/
    func addAlerts(song: BasicSong, inLibrary: Bool, library: [BasicSong]?, recents: [BasicSong]?){
        
        if peakMusicController.playerType == .Contributor{
            
            addContributorAlerts(song)
            
        }else{
            
            if let theSong: Song = song as? Song{
                
                if peakMusicController.musicType == .Guest && inLibrary == true{
                    
                    addGuestAlerts(theSong)
                    
                } else if peakMusicController.musicType != .Guest{
                    
                    
                    addAppleMusicStoreAlerts(theSong)
                }
                
            } else{
                
                addPlaybackAlerts(song)
            }
        }
        
        
        
        if library != nil && peakMusicController.musicType != .Guest && peakMusicController.playerType != .Contributor{
            
            addShuffleAlerts(shuffle: library!, isLibrary: true)
        } else if recents != nil && peakMusicController.musicType != .Guest && peakMusicController.playerType != .Contributor {
            
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
        
        if peakMusicController.currPlayQueue.count != 0{
            
            if peakMusicController.musicType != .Spotify{
                
                addAction(Alerts.playNextAlert(song))
            }
            
            addAction(Alerts.playLastAlert(song))
            
        }
        
        addAction(Alerts.playAlbumAlert(song))
        addAction(Alerts.playArtistAlert(song))
    }
    
    private func addShuffleAlerts(shuffle songs: [BasicSong], isLibrary: Bool){
        
        addAction(Alerts.shuffleAlert(songs, isLibrary: isLibrary))
    }
    
    private func addToLibraryAlerts(_ song: BasicSong){
        
        addAction(Alerts.addToLibraryAlerts(song))
    }
    
    
    /*MARK: */
    func presentMe(_ sender: UILongPressGestureRecognizer, presenterViewController: UIViewController){
        
        modalPresentationStyle = .popover
        let ppc = popoverPresentationController
        ppc?.sourceRect = (sender.view?.bounds)!
        ppc?.sourceView = sender.view
        presenterViewController.present(self, animated: true, completion: nil)
    }

}
