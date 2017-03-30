//
//  SearchBarPopOverViewViewController.swift
//  Peak
//
//  Created by Connor Monks on 3/28/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

protocol SearchBarPopOverViewViewControllerDelegate{
    
    func returnLibrary() -> [MPMediaItem]
    
}

class SearchBarPopOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var selectMusicFromSegment: UISegmentedControl!
    
    @IBOutlet weak var searchedSongsTableView: UITableView!
    
    var topFiveResults = [Song]() {
        
        didSet{
            
            searchedSongsTableView.reloadData()
        }
    }
    
    var delegate: SearchBarPopOverViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add a listener so we know when segment changed
        selectMusicFromSegment.addTarget(self, action: #selector(searchRequestChanged), for: .valueChanged)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return 5 because we only want the top 5 results
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (delegate as! LibraryViewController).library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
        
        //Double Check to make sure we have that many songs in the topFiveResults
        if topFiveResults.count - 1 == indexPath.row {
            
            let songToAdd = topFiveResults[indexPath.row]
            
            //create the cell in here
            cell.albumArt.image = songToAdd.image
            cell.songArtist.text = songToAdd.artistName
            cell.songTitle.text = songToAdd.trackName
            
            /************ADD FUNCTIONALITY TO METHOD: CONNOR******************/
            //check if we are searching the library or Apple Music
            if selectMusicFromSegment.selectedSegmentIndex == 1{
                
                //we are searching the apple music store so add a plus button
                /***THIS IS WHERE THE FUNCTIONALITY NEEdS TO BE ADDED: CONNOR***/
            }
            
            
            
            
        }
        
        return cell
    }
    
    /*MARK: SEARCH BAR DELEGATE METHODS*/
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.resignFirstResponder()
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController{
            
            searchBar.delegate = LVCDel
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //Check whether we should search the library or apple music
        if selectMusicFromSegment.selectedSegmentIndex == 0 {
            //we are searching the library so get the library // 3 cam store in top 5 results
            let library = delegate?.returnLibrary()
            
            /********CAMERON MONKS THIS IS WHERE YOU NEED TO GET THE SEARCH RESULTS AND STORE IT IN topFiveResults*******/
            /******GET ALL THE RESULTS AND THEN STORE THEM BECAUSE table view load each time you change topFiveResults******/
            
        } else {
            //we are searching apple music
            
            /********CAMERON MONKS THIS IS ALSO WHERE YOU NEEd TO GET THE SEARCH RESULTS BUT FROM APPLE MUSIC THIS TIME********/
            
        }
    }
    
    
    func searchRequestChanged(){
        
        /*******CAM THE USER CHANGED FROM LIBRARY TO APPLE MUSIC OR VISA VERSA SO UPDATE THE RESULTS*******/
        //I'll get the search bar text for you
        
        var searchText = String()
        if let LVCdel: LibraryViewController = delegate as? LibraryViewController {
            
            searchText = LVCdel.searchForMediaBar.text!
        }
        
    }

}
