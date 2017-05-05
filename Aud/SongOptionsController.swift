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
    
    /*MARK: Methods that determine what alerts to add*/
    func addLibraryAlerts(sender: UILongPressGestureRecognizer, library: [MPMediaItem], recents: [MPMediaItem]){
        
        //Check the user's Music Type
        if peakMusicController.musicType == .AppleMusic{
            
            //Change what appears based on the user's type
            if peakMusicController.playerType != .Contributor {
                
                addAppleMusicNonContributor(library: library, recents: recents, sender, comingFrom: .Library)
                
            } else { //User is a contributor so display those methods
                
                addContributor(sender)
            }
            
            
        } else if peakMusicController.musicType == .Guest{
            //If here we are a guest so display the guest options
            
            if peakMusicController.playerType == .Contributor{
                
                addContributor(sender)
            }
            
            
            addGuest(sender)
            
        }
        
        
        //Add a cancel action
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    
    /*NEEDS TO BE UPDATED: Why is Delegate View Controller a param?*/
    func addSearchAlerts(_ sender: UILongPressGestureRecognizer,delegateViewController: BeastController){
        
        if peakMusicController.playerType != .Contributor {
            
            //Get the cell
            if let _: SongCell = sender.view as? SongCell{
                
            
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
    
    
    
    /*MARK: */
    func presentMe(_ sender: UILongPressGestureRecognizer, presenterViewController: UIViewController){
        
        modalPresentationStyle = .popover
        let ppc = popoverPresentationController
        ppc?.sourceRect = (sender.view?.bounds)!
        ppc?.sourceView = sender.view
        presenterViewController.present(self, animated: true, completion: nil)
    }

}
