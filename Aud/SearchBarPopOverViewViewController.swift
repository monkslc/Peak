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
            
            cell.mediaItemInCell = songToAdd
        
        } else if let songToAdd: Song = topThreeResults[indexPath.row] as? Song{
            //we are adding an item from Apple Music
            
            cell.songInCell = songToAdd
            
            //Add the library button
            cell.addToLibraryButton.isHidden = false
            
            cell.addToLibraryButton.addTarget(self, action: #selector(addToLibrary(_:)), for: .touchUpInside)
            
        }
        
        cell.addItems()
        
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
                
                //Get the cell
                if let cell: SongCell = gesture.view as? SongCell{
                    
                    //Add A play now
                    alert.addAction(Alerts.playNowAlert(gesture))
                    
                    //change what appears based on the music type
                    if cell.songInCell == nil{
                        //Library
                        
                        //Add Actions for library non contributors
                        alert.addAction(Alerts.playNextAlert(gesture))
                        alert.addAction(Alerts.playLastAlert(gesture))
                        alert.addAction(Alerts.playAlbumAlert(gesture))
                        alert.addAction(Alerts.playArtistAlert(gesture))
                        
        

                    } else {
                        //Apple Music
                        
                        //Add Actions For Apple Music Non Contributors
                        alert.addAction(addToLibraryAlert(gesture))
                    }
                }
                
    
            } else { //User is a contributor so display those methods
                
                
                if let cell: SongCell = gesture.view as? SongCell {
                    
                    alert.addAction(Alerts.sendToGroupQueueAlert(gesture))
                    
                    //Add an add to library option if we are in Apple Music
                    if cell.songInCell != nil {
                        
                        alert.addAction(addToLibraryAlert(gesture))
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
    
    
    func addToLibraryAlert(_ gesture: UIGestureRecognizer) -> UIAlertAction{
        
        return UIAlertAction(title: "Add to Library", style: .default, handler: {(alert) in
            
            self.showSignifier()
            
            let cell:SongCell = (gesture.view as? SongCell)!
            
            MPMediaLibrary().addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                
                /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                /*******DO SOMETHING WITH THE ERROR******/
            })
        })
    }
    
    
    func addToLibrary(_ button: UIButton){
        
        showSignifier()
        
        if let cell: SongCell = button.superview?.superview as? SongCell{
            
            if cell.songInCell != nil {
                
                MPMediaLibrary().addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                    
                    /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                    /*******DO SOMETHING WITH THE ERROR******/
                })
            }
        }
        
    }
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
        else if selectMusicFromSegment.selectedSegmentIndex == 1{
            
            searchAppleMusic(search: search)
        } else {
            
            /*CAM IMPLEMENT TOP CHARTS SEARCH HERE*/
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
