//
//  MusicTypeController.swift
//  Aud
//
//  Created by Connor Monks on 6/6/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

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
        }
        
        //Add the gesture recognizer
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchMusicType(_:))))
        
        return cell
    }
    
    
/*MARK: GESTURE RECOGNIZERS*/
    func switchMusicType(_ sender: UITapGestureRecognizer){
        
        print("Just View: \(sender.view)")
        print("Superview: \(sender.view?.superview)")
        
        //Get the cell that was tapped on
        if let cell: MusicTypeCell = sender.view as? MusicTypeCell {
            
            print("Made it in the cell")
            //Set our new user defaults
            let defaults = UserDefaults.standard
            defaults.set(cell.musicPlayerLabel.text, forKey: "Music Type")
            
            //Change the preferred variable
            preferredPlayerType = cell.musicPlayerLabel.text!
            
            //Now reload our table
            musicTypeTable.reloadData()
        } else{
            
            /*CAM THE ERROR IS HERE BECAUSE THE sender.view?.superview is not the cell in the above if let statment. Figure out how to turn that into the cell and we will be good*/
            print("\n\n\nCAM THE ERROR WAS HERE \n")
        }
    }
    
    @IBAction func flipView(_ sender: UIButton) {
        
        let p = parent as! PagesViewController
        p.flipMiddlePageToFront()
    }
    
}
