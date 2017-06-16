//
//  MusicTypeController.swift
//  Aud
//
//  Created by Connor Monks on 6/6/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer
import CloudKit

class MusicTypeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
/*MARK: PROPERTIES*/
    @IBOutlet weak var musicTypeTable: UITableView!
    
    let images = [#imageLiteral(resourceName: "apple-music-app-icon"), #imageLiteral(resourceName: "Spotify_Icon_RGB_Black"), #imageLiteral(resourceName: "Guest Icon")]
    let musicPlayerTitles = ["Apple Music", "Spotify", "Guest"]
    
    var preferredPlayerType = "Guest"
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicTypeTable.delegate = self
        musicTypeTable.dataSource = self
        
        //Find the user's preferred player type
        let defaults = UserDefaults.standard
        
        if let musicType = defaults.string(forKey: "Music Type"){
            
            //The user has a selected type so set it
            preferredPlayerType = musicType
        } else{
            
            //The user doesn't have a selected type yet so set it to be Guest
            preferredPlayerType = "Guest"
        }
        
        
    }
    
    
    
/*MARK: TABLE VIEW DELEGATE METHODS*/
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Music Type", for: indexPath) as! MusicTypeCell
        
        cell.musicPlayerImage.image = images[indexPath.row]
        cell.musicPlayerLabel.text = musicPlayerTitles[indexPath.row]
        
        
        //Check if this is the user's preferred music type
        if musicPlayerTitles[indexPath.row] == preferredPlayerType {
            
            cell.checkMrk.isHidden = false
        } else{
            
            cell.checkMrk.isHidden = true
        }
        
        //Add the gesture recognizer
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchMusicType(_:))))
        
        return cell
    }
    
    
/*MARK: GESTURE RECOGNIZERS*/
    func switchMusicType(_ sender: UITapGestureRecognizer){
        
        //Get the cell that was tapped on
        if let cell: MusicTypeCell = sender.view as? MusicTypeCell {
            
            //Make sure we aren't switching to the same type
            if cell.musicPlayerLabel.text == preferredPlayerType{
                
                return
            }
            
            //Start loading indicators
            self.startUpLoadingIndicators()
            
            //Add notification to listen for library finished loading
            NotificationCenter.default.addObserver(self, selector: #selector(musicPlayerFinishedLoading), name: .libraryFinishedLoading, object: nil)
            
            //Let's figure out which music type we are switching to
            if cell.musicPlayerLabel.text == "Apple Music"{
                
                /*AUTHENTICATE APPLE MUSIC AND DO THIS IF AUTHENTICATIONS WORKS*/
                Authentication.AutheticateWithApple(){ alertController in
                    
                    if alertController == nil{
                        
                        peakMusicController.systemMusicPlayer.stopPlaying()
                        peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
                        peakMusicController.systemMusicPlayer.generateNotifications()
                        peakMusicController.systemMusicPlayer.stopPlaying()
                        self.musicPlayerTypeWasUpdated(cell.musicPlayerLabel.text!)
                    } else{
                        
                        DispatchQueue.main.async {
                            
                            self.present(alertController!, animated: true, completion: nil)
                        }
                        
                        
                        
                    }
                }
                
            }else if cell.musicPlayerLabel.text == "Spotify"{
                
                 peakMusicController.systemMusicPlayer.stopPlaying()
                
                NotificationCenter.default.addObserver(self, selector: #selector(spottyLoginWasSuccess), name: .spotifyLoginSuccessful, object: nil)
                
                Authentication.AuthenticateWithSpotify()
                
            } else{
                
                peakMusicController.systemMusicPlayer.stopPlaying()
                peakMusicController.systemMusicPlayer = GuestMusicController()
                musicPlayerTypeWasUpdated("Guest")
            }
            
            
            
        }
    }
    
    
    func musicPlayerTypeWasUpdated(_ musicType: String){
        
        peakMusicController.systemMusicPlayer.setNowPlayingItemToNil()
        
        //Set our new user defaults
        let defaults = UserDefaults.standard
        defaults.set(musicType, forKey: "Music Type")
        
        //Change the preferred variable
        preferredPlayerType = musicType
        
        switch musicType{
            
        case "Apple Music":
            peakMusicController.musicType = .AppleMusic
            
        case "Spotify":
            peakMusicController.musicType = .Spotify
            
        default:
            peakMusicController.musicType = .Guest
        }
        
        //reload table and fetch me library
        musicTypeTable.reloadData()
        (peakMusicController.delegate as! BeastController).libraryViewController.userLibrary.fetchLibrary()
        
    }
    
    @IBAction func flipView(_ sender: UIButton) {
        
        let p = parent as! PagesViewController
        p.flipMiddlePageToFront()
    }
    
    
/*MARK: SUPPORTING AUTHENTICATION METHODS*/
    func spottyLoginWasSuccess(){
        
        peakMusicController.systemMusicPlayer.generateNotifications()
        musicPlayerTypeWasUpdated("Spotify")
    }
    
    
    
/*MARK: METHODS TO TRACK SWITCHING MUSIC PLAYER*/
    
    func startUpLoadingIndicators(){
        
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func musicPlayerFinishedLoading(){
        
        //come back here
        NotificationCenter.default.removeObserver(self)
        
        loadingView.isHidden = true
        loadingIndicator.stopAnimating()
        
        flipView(UIButton())
    }
    
    func musicPlayerLoadingFailed(){
        NotificationCenter.default.removeObserver(self)
        
        loadingView.isHidden = true
        loadingIndicator.stopAnimating()
        
    }
}
