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
    
    private var topThreeResults = [AnyObject]() {
        
        didSet{

            searchedSongsTableView.reloadData()
        }
    }
    
    var delegate: SearchBarPopOverViewViewControllerDelegate?
    
    
    /*MARK: LifeCycle Methods*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add a listener so we know when segment changed
        selectMusicFromSegment.addTarget(self, action: #selector(searchRequestChanged), for: .valueChanged)
        selectMusicFromSegment.tintColor = UIColor.peakColor
        
        
        searchedSongsTableView.delegate = self
        searchedSongsTableView.dataSource = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //Called when the popover is about to go away
        //Resign first responder status for the search bar
        
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController {
            
            LVCDel.searchForMediaBar.resignFirstResponder()
        }
        
    }
    
    
    /*MARK: TABLE VIEW DELEGATE METHODS*/
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return 3 because we only want the top 3 results
        return topThreeResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = (delegate as! LibraryViewController).library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
    
            
            
        //Check whether we are adding a Apple Music or Library Item
        if let songToAdd: MPMediaItem = topThreeResults[indexPath.row] as? MPMediaItem{
            //we are adding an item from the library
                
            cell.albumArt.image = songToAdd.artwork?.image(at: CGSize())
            cell.songArtist.text = songToAdd.artist
            cell.songTitle.text = songToAdd.title
            cell.mediaItemInCell = topThreeResults[indexPath.row] as! MPMediaItem
                
            //add the gestures
            
                
        } else if let songToAdd: Song = topThreeResults[indexPath.row] as? Song{
            //we are adding an item from Apple Music
                
            cell.albumArt.image = songToAdd.image
            cell.songArtist.text = songToAdd.artistName
            cell.songTitle.text = songToAdd.trackName
            
            cell.songInCell = topThreeResults[indexPath.row] as? Song
            
            //add an add to library button here
            
        }
        
        //add the gestures
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        return cell
    }
    
    
    /*MARK: SEARCH BAR DELEGATE METHODS*/
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
       
        
        //searchBar.resignFirstResponder()
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController{
            
            searchBar.delegate = LVCDel
        }
        
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let search = searchBar.text else { return }
        
        searchSongs(search: search)
    }
    
    
    func searchRequestChanged() {
        //Gets called when the segmented control changes
       
        
        var searchText = String()
        if let LVCdel: LibraryViewController = delegate as? LibraryViewController {
            
            searchText = LVCdel.searchForMediaBar.text!
        }
        
        searchSongs(search: searchText)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
 
    
    
    /*MARK: GESTURE RECOGNIZERS*/
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        //display the options for the song that was tapped on
        
        
        if gesture.state == .began {
            
            //alert the options for the song here
            let alert = UIAlertController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            
            
            //Change what appears based on the user's type
            if peakMusicController.playerType != .Contributor {
                
                
                if let cell: SongCell = gesture.view as? SongCell{
                    
                    //change what appears based on the music type
                    if cell.songInCell == nil{
                        //Library
                        
                        //Loop through appropriate actions and add them
                        for action in returnActionsForNonContributorLibrary(cell){
                            
                            alert.addAction(action)
                        }

                    } else {
                        //Apple Music
                        
                        for action in returnActionsForNonContributorAppleMusic(cell){
                            
                            alert.addAction(action)
                        }
                    }
                }
                
                
                
                
            } else { //User is a contributor so display those methods
                
                
                if let cell: SongCell = gesture.view as? SongCell {
                    
                    
                    
                    //Check if we're in Apple Music or Library
                    if cell.songInCell == nil {
                        //library
                        
                        for action in returnActionsForContributorLibrary(cell) {
                         
                            alert.addAction(action)
                         }
                        
                        
                    } else {
                        //Apple Music
                        
                        for action in returnActionsForContributorAppleMusic(cell){
                            
                            alert.addAction(action)
                        }
                        
                    }
                }
            }
            
            
            //Add a cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            alert.modalPresentationStyle = .popover
            let ppc = alert.popoverPresentationController
            ppc?.sourceRect = (gesture.view?.bounds)!
            ppc?.sourceView = gesture.view
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func handleTap(_ gesture: UITapGestureRecognizer){
        //Gets called when a user taps on a song in the search
        
        //get the cell
        let cell = gesture.view as! SongCell
        
        
        //Check player type
        if peakMusicController.playerType != .Contributor {
            
            notContributorTap(cell)
            
        } else {
            //We are a contributor
            
            contributorTap(cell)
        }
        
    }

    
    /*MARK: Song Interaction Functionality Methods*/
    
    /*TAP METHODS*/
    
    func notContributorTap(_ cell: SongCell){
        //Handle the music for the non contributor
        
        //Check library or apple music
        if cell.mediaItemInCell != MPMediaItem() {
            //library
            
            peakMusicController.play([cell.mediaItemInCell])
            
        }else {
            //Apple Music
            //Play a song by song id, because we won't have the MPMediaItem
            
            peakMusicController.systemMusicPlayer.setQueueWithStoreIDs([(cell.songInCell?.id)!])
            peakMusicController.systemMusicPlayer.play()
            
        }
    }
    
    func contributorTap(_ cell: SongCell){
        //Handle the music for a contributor
        
        var songId = String()
        var songTitle = String()
        
        //Check if we are in apple music or library and get the song id + title
        if cell.songInCell == nil{
            //Library
            
            songId = cell.mediaItemInCell.playbackStoreID
            songTitle = cell.mediaItemInCell.title!
        } else {
            //Apple Music
            
            songId = (cell.songInCell?.id)!
            songTitle = (cell.songInCell?.trackName)!
        }
        
        //Alert the user
        promptUserToSendToGroupQueue(songTitle: songTitle, songId: songId)
        
    }
    
    func promptUserToSendToGroupQueue(songTitle: String, songId: String){
        //Makes sure the user wants to send the item to the group queue
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(songTitle) to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
            
            SendingBluetooth.sendSongIdToHost(id: "\(songId)", error: {
                () -> Void in
                
                let alert = UIAlertController(title: "Error", message: "Could not send", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }) // @cam added this. may want to change
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    /*RETURN ACTION METHODS*/
    func returnActionsForNonContributorLibrary(_ cell: SongCell) -> [UIAlertAction]{
        
        var actions = [UIAlertAction]()
       
        //Add Play Song Option
        let playAction = UIAlertAction(title: "Play Now", style: .default, handler: {(alert) in
            
            peakMusicController.play([cell.mediaItemInCell])
            
        })
        actions.append(playAction)
        
        
        //Add Play Next Option
        let playNextAction = UIAlertAction(title: "Play Next", style: .default, handler: {(alert) in
            
            peakMusicController.playNext([cell.mediaItemInCell])
            
        })
        actions.append(playNextAction)
        
        
        //Add Add to end of Queue
        let endOfQueue = UIAlertAction(title: "Play Last", style: .default, handler: {(alert) in
            
            peakMusicController.playAtEndOfQueue([cell.mediaItemInCell])
            
        })
        actions.append(endOfQueue)
        
        //Add play album
        let playAlbum = UIAlertAction(title: "Play Album", style: .default, handler: {(action) in
            
            peakMusicController.play(album: cell.mediaItemInCell)
            
        })
        actions.append(playAlbum)
        
        
        //Add Play Artist
        let playArtist = UIAlertAction(title: "Play Artist", style: .default, handler: {(action ) in
            
            peakMusicController.play(artist: cell.mediaItemInCell)
        })
        actions.append(playArtist)
        
        
        return actions
    }
    
    
    func returnActionsForNonContributorAppleMusic(_ cell: SongCell) -> [UIAlertAction]{
        
        var actions = [UIAlertAction]()
        
        //Play Song Option
        let playSongOption = UIAlertAction(title: "Play Song", style: .default, handler: {(action) in
            
            peakMusicController.systemMusicPlayer.setQueueWithStoreIDs([(cell.songInCell?.id)!])
            peakMusicController.systemMusicPlayer.play()
        })
        actions.append(playSongOption)
        
        
        //Add an add to library option
        let addToLibrary = UIAlertAction(title: "Add to Library", style: .default, handler: {(alert) in
            
            self.showSignifier()
            
            userLibrary.addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                
                /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                print(err)
            })
            
            
        })
        actions.append(addToLibrary)
        
        
        return actions
    }
    
    func returnActionsForContributorLibrary(_ cell: SongCell) -> [UIAlertAction]{
        
        var actions = [UIAlertAction]()
        
        let addToEndOfQueue = UIAlertAction(title: "Add to End of Queue", style: .default, handler: {(alert) in
            
            peakMusicController.playAtEndOfQueue([cell.mediaItemInCell])
            
        })
        actions.append(addToEndOfQueue)
        
        return actions
    }
    
    func returnActionsForContributorAppleMusic(_ cell: SongCell) -> [UIAlertAction] {
        
        var actions = [UIAlertAction]()
        
        let addToEndOfQueue = UIAlertAction(title: "Add to End of Queue", style: .default, handler: {(alert) in
            
            peakMusicController.systemMusicPlayer.setQueueWithStoreIDs([(cell.songInCell?.id)!])
            
        })
        actions.append(addToEndOfQueue)
        
        let addToLibrary = UIAlertAction(title: "Add To Library", style: .default, handler: {(alert) in
            
            self.showSignifier()
            
            userLibrary.addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                
                /******************HANDLE SOME ERRORS HERE************/
                print(err)
            })
            
        })
        actions.append(addToLibrary)
        
        return actions
        
    }
    
    
    func showSignifier(){
        
        //Show Signifier to let the user know they added it
        let sig = Signifier(frame: CGRect(x: view.bounds.midX - 50, y: view.bounds.midY - 50, width: 100, height: 100))
        sig.animationSetUp()
        view.addSubview(sig)
        sig.animate()
    }
    
    
    /*MARK: SEARCH FUNCTIONALITY METHODS*/
    
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
