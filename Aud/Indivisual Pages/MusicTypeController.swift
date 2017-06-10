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
    
    let images = [#imageLiteral(resourceName: "apple-music-app-icon"), #imageLiteral(resourceName: "Spotify_Icon_RGB_Black"), #imageLiteral(resourceName: "Backward Filled-50")]
    let musicPlayerTitles = ["Apple Music", "Spotify", "Guest"]
    
    var preferredPlayerType = "Guest"
    
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
        
        print("We are reloading the table view with a preferred type of: \(preferredPlayerType)")
        
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
            
            
            //Let's figure out which music type we are switching to
            if cell.musicPlayerLabel.text == "Apple Music"{
                
                /*AUTHENTICATE APPLE MUSIC AND DO THIS IF AUTHENTICATIONS WORKS*/
                Authentication.AutheticateWithApple(){ alertController in
                    
                    if alertController == nil{
                        
                        print("Our new Music Controller should be updating")
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
                
                /*AUTHENTICATE SPOTIFY AND DO THIS IF AUTHENTICATION WORKS*/
                //Add the listener so we know it worked
                NotificationCenter.default.addObserver(self, selector: #selector(spottyLoginWasSuccess), name: .spotifyLoginSuccessful, object: nil)
                
                Authentication.AuthenticateWithSpotify()
                //peakMusicController.systemMusicPlayer = SPTAudioStreamingController.sharedInstance()
                
            } else{
                
                peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
            }
            
            
            
        }
    }
    
    
    func musicPlayerTypeWasUpdated(_ musicType: String){
        
        print("Our Music Player Type Was Updated")
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
        
        //Now reload our table
        musicTypeTable.reloadData()
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
}
