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

class MusicTypeController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate{
    
/*MARK: PROPERTIES*/
    @IBOutlet weak var musicTypeTable: UITableView!
    
    let images = [#imageLiteral(resourceName: "apple-music-app-icon"), #imageLiteral(resourceName: "Spotify_Icon_RGB_Black"), #imageLiteral(resourceName: "Guest Icon")]
    let musicPlayerTitles = ["Apple Music", "Spotify", "Guest"]
    
    var preferredPlayerType: MusicTypeManager.MusicType = .Guest
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicTypeTable.delegate = self
        musicTypeTable.dataSource = self
        
        preferredPlayerType = Defaults.musicType
        
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
        if musicPlayerTitles[indexPath.row] == MusicTypeManager.convertMusicTypeToString(preferredPlayerType){
            
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
            if cell.musicPlayerLabel.text == MusicTypeManager.convertMusicTypeToString(preferredPlayerType){
                
                return
            }
            
            //Add notification to listen for library finished loading
            NotificationCenter.default.addObserver(self, selector: #selector(musicPlayerFinishedLoading), name: .libraryFinishedLoading, object: nil)
            
            //Let's figure out which music type we are switching to
            if cell.musicPlayerLabel.text == "Apple Music"{
                
                //Start Loading Indicator
                self.startUpLoadingIndicators()
                
                /*AUTHENTICATE APPLE MUSIC AND DO THIS IF AUTHENTICATIONS WORKS*/
                Authentication.AutheticateWithApple(){ alertController in
                    
                    if alertController == nil{
                        
                        self.setUpAppleAuthentication()
                    } else{
                        
                        DispatchQueue.main.async {
                            
                            self.present(alertController!, animated: true, completion: nil)
                            self.setUpGuestLogin()
                        }
                    }
                }
                
            }else if cell.musicPlayerLabel.text == "Spotify"{
                
                self.setUpSpotifyAuthentication()
                
            } else{
                
                self.setUpGuestLogin()
            }
        }
    }
    
    
    func musicPlayerTypeWasUpdated(_ musicType: String){
        
        peakMusicController.systemMusicPlayer.setNowPlayingItemToNil()
        
        //Defaults.musicType = MusicTypeManager.convertStringToMusicType(musicType)
        peakMusicController.musicType = MusicTypeManager.convertStringToMusicType(musicType)
        preferredPlayerType = Defaults.musicType
        
        
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
        
        self.startUpLoadingIndicators()
        peakMusicController.systemMusicPlayer.generateNotifications()
        musicPlayerTypeWasUpdated("Spotify")
    }
    
    
    func setUpAppleAuthentication(){
        
        peakMusicController.systemMusicPlayer.stopPlaying()
        peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
        peakMusicController.systemMusicPlayer.generateNotifications()
        peakMusicController.systemMusicPlayer.stopPlaying()
        self.musicPlayerTypeWasUpdated("Apple Music")
    }
    
    func setUpSpotifyAuthentication(){
        
        peakMusicController.systemMusicPlayer.stopPlaying()
        NotificationCenter.default.addObserver(self, selector: #selector(spottyLoginWasSuccess), name: .spotifyLoginSuccessful, object: nil)
        Authentication.AuthenticateWithSpotify(safariViewControllerDelegate: self)
    }
    
    func setUpGuestLogin(){
        
        self.startUpLoadingIndicators()
        peakMusicController.systemMusicPlayer.stopPlaying()
        peakMusicController.systemMusicPlayer = GuestMusicController()
        musicPlayerTypeWasUpdated("Guest")
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
        //musicTypeTable.reloadData()
        //preferredPlayerType = Defaults.musicType
        flipView(UIButton())
    }
    
    func musicPlayerLoadingFailed(){
        
        //Alert the user
        let alert = UIAlertController(title: "Failed Authentication", message: "We we're unable to switch your music player. We will now sign you in as a Guest", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default){ alert in
            
            self.setUpGuestLogin()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
/*MARK: SAFARI VIEW CONTROLLER DELEGATE METHODS*/
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        musicPlayerLoadingFailed()
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        
        print("We are in the second delegate method bitches")
    }
    
    
}
