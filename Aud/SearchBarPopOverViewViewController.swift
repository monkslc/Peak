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
    
    private enum SongType {
        
        case AppleMusic(Song)
        case Library(MPMediaItem)
    }
    
    private var topThreeResults = [AnyObject]() {
        
        didSet{
            
            if let songs = topThreeResults as? [MPMediaItem] {
                for s in songs {
                    print(s.title ?? "NO TITLE")
                }
            }
            else if let songs = topThreeResults as? [Song] {
                for s in songs {
                    print(s.trackName)
                }
            }
            
            searchedSongsTableView.reloadData()
        }
    }
    
    var delegate: SearchBarPopOverViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add a listener so we know when segment changed
        selectMusicFromSegment.addTarget(self, action: #selector(searchRequestChanged), for: .valueChanged)
        selectMusicFromSegment.tintColor = UIColor.peakColor
    }
    
    
    /*MARK: TABLE VIEW DELEGATE METHODS*/
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return 3 because we only want the top 3 results
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (delegate as! LibraryViewController).library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
        
        //Double Check to make sure we have that many songs in the topFiveResults
        if topThreeResults.count - 1 <= indexPath.row {
            
            
            //Check whether we are adding a Apple Music or Library Item
            if let songToAdd: MPMediaItem = topThreeResults[indexPath.row] as? MPMediaItem{
                //we are adding an item from the library
                
                cell.albumArt.image = songToAdd.artwork?.image(at: CGSize())
                cell.songArtist.text = songToAdd.artist
                cell.songTitle.text = songToAdd.title
                
                //add the gestures
                cell.addGestureRecognizer(UITapGestureRecognizer(target: delegate, action: #selector(handleTap(_:))))
                cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
                
            } else if let songToAdd: Song = topThreeResults[indexPath.row] as? Song{
                //we are adding an item from Apple Music
                
                cell.albumArt.image = songToAdd.image
                cell.songArtist.text = songToAdd.artistName
                cell.songTitle.text = songToAdd.trackName
                
                //add an add to library button here
                
                //add gestures here, not sure what they'll be yet
            }
        
            
        }
        
        return cell
    }
    
    
    /*MARK: SEARCH BAR DELEGATE METHODS*/
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        print("Search Bar should end editing")
        //searchBar.resignFirstResponder()
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController{
            
            searchBar.delegate = LVCDel
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let search = searchBar.text else { return }
        
        searchSongs(search: search)
    }
    
    
    func searchRequestChanged() {
        //Gets called when the segmented control changes
        
        /*******CAM THE USER CHANGED FROM LIBRARY TO APPLE MUSIC OR VISA VERSA SO UPDATE THE RESULTS*******/
        //I'll get the search bar text for you
        
        var searchText = String()
        if let LVCdel: LibraryViewController = delegate as? LibraryViewController {
            
            searchText = LVCdel.searchForMediaBar.text!
        }
        
        searchSongs(search: searchText)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("Search Bar button clicked")
        
        searchBar.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Called when the popover is about to go away
        //Resign first responder status for the search bar
        
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController {
            
            LVCDel.searchForMediaBar.resignFirstResponder()
        }
        
    }
    
    
    /*MARK: GESTURE RECOGNIZERS*/
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        
        (delegate as! LibraryViewController).displaySongOptions(gesture)
    }
    
    func handleTap(_ gesture: UITapGestureRecognizer){
        
        (delegate as! LibraryViewController).handleTapOnSong(gesture)
    }
    
    
    private func searchSongs(search: String) {
        if selectMusicFromSegment.selectedSegmentIndex == 0 {
            searchLibrary(search: search)
        }
        else {
            searchAppleMusic(search: search)
        }
    }
    
    private func searchLibrary(search: String) {
        //we are searching the library so get the library // 3 cam store in top 5 results
        guard let library = delegate?.returnLibrary() else { return }
        
        /********CAMERON MONKS THIS IS WHERE YOU NEED TO GET THE SEARCH RESULTS AND STORE IT IN topFiveResults*******/
        /******GET ALL THE RESULTS AND THEN STORE THEM BECAUSE table view load each time you change topFiveResults******/
        
        var songs: [MPMediaItem] = []
        var points: [Int: Int] = [:]
        
        var index = 0
        for s in library {
            if s.title!.lowercased().contains(search.lowercased()) || s.albumArtist!.lowercased().contains(search.lowercased()) {
                
                var point = 1
                var multilier = 1
                
                var i = s.title!.lowercased().indexOf(target: search.lowercased())
                if i >= 0 {
                    point += i
                } else {
                    multilier += 1
                }
                
                i = s.albumArtist!.lowercased().indexOf(target: search.lowercased())
                if i >= 0 {
                    point += i
                } else {
                    multilier += 1
                }
                
                points[index] = point * multilier
                
                songs.append(s)
                
                index += 1
            }
        }
        
        let foo = Array(points.keys).sorted()
        
        var top3 : [MPMediaItem] = []
        for i in foo {
            top3.append(songs[i])
            if top3.count == 3 {
                break
            }
        }
        
        topThreeResults = top3
        
        //Store an MPMediaItem in topThreeResults
    }
    
    private func searchAppleMusic(search: String) {
        //we are searching apple music
        
        /********CAMERON MONKS THIS IS ALSO WHERE YOU NEEd TO GET THE SEARCH RESULTS BUT FROM APPLE MUSIC THIS TIME********/
        
        //Store an instance of the Song struct in topThree Results
        
        ConnectingToInternet.getSongs(searchTerm: search, limit: 3, sendSongsAlltogether: true, completion: {
            (songs) -> Void in
            
            var top3 : [Song] = []
            
            for i in 0..<songs.count {
                top3.append(songs[i])
            }
            
            DispatchQueue.main.async {
                self.topThreeResults = top3 as [AnyObject]
            }
        })
    }

}
