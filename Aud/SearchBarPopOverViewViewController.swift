//
//  SearchBarPopOverViewViewController.swift
//  Peak
//
//  Created by Connor Monks on 3/28/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

protocol SearchBarPopOverViewViewControllerDelegate{
    
    func returnLibrary() -> [MPMediaItem]
    
}

class SearchBarPopOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var selectMusicFromSegment: UISegmentedControl!
    
    @IBOutlet weak var searchedSongsTableView: UITableView!
    
    private var topThreeResults = [AnyObject]() {
        
        didSet {

            searchedSongsTableView.reloadData()
        }
    }
    
    var delegate: SearchBarPopOverViewViewControllerDelegate?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
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
        
        (delegate as! LibraryViewController).searchForMediaBar.showsCancelButton = false
    }
    
    
    /*MARK: TABLE VIEW DELEGATE METHODS*/
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return topThreeResults.count + 2 //so we can see bottom results
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //check if we are in the last two
        if indexPath.row >= topThreeResults.count{
            
            let cell = UITableViewCell(frame: CGRect())
            
            return cell
        }
        
        let cell = (delegate as! LibraryViewController).library.dequeueReusableCell(withIdentifier: "Song Cell") as! SongCell
        
        
        //Check whether we are adding a Apple Music or Library Item
        if let songToAdd: MPMediaItem = topThreeResults[indexPath.row] as? MPMediaItem{
            //we are adding an item from the library
            
            cell.mediaItemInCell = songToAdd
        
        } else if let songToAdd: Song = topThreeResults[indexPath.row] as? Song{
            //we are adding an item from Apple Music
            
            cell.songInCell = songToAdd
            
            //Add the library button
            if !checkIfAlreadyInLibrary(songToAdd.id){
                
                cell.addToLibraryButton.isHidden = false
            }
            
            
            cell.addToLibraryButton.addTarget(self, action: #selector(addToLibrary(_:)), for: .touchUpInside)
            
        }
        
        cell.addItems()
        
        //add the gestures
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    
    /*MARK: SEARCH BAR DELEGATE METHODS*/
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
        //The cancel button was clicked so segue back
        
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController{
            
            searchBar.delegate = LVCDel
        }
        
        searchBar.text = ""
        
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let search = searchBar.text else { return }
        
        searchSongs(search: search)
    }
    
    
    func searchRequestChanged() {
        //Gets called when the segmented control changes
        
        //need to stop the loading indicator in case the user started it and then switched before results were returned
        loadingIndicator.stopAnimating()
        
        topThreeResults = []
        
        var searchText = String()
        if let LVCdel: LibraryViewController = delegate as? LibraryViewController {
            
            searchText = LVCdel.searchForMediaBar.text!
        }
        
        
        //If we are searching TopCharts, please put away the keyboard and start the loading indicator
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            (delegate as! LibraryViewController).searchForMediaBar.resignFirstResponder()
            loadingIndicator.startAnimating()
            print("Loading Indicator should have started")
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
        
        //resign the keyboard
        (delegate as! LibraryViewController).searchForMediaBar.resignFirstResponder()
        
        //check to make sure we're not a guest

        
        //get the cell
        let cell = gesture.view as! SongCell
        
        
        //Check player type
        if peakMusicController.playerType != .Contributor && peakMusicController.musicType != .Guest{
            
            notContributorTap(cell)
            
        } else if peakMusicController.playerType == .Contributor{
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
        
        //Check what type of musci we are playing
        
        if peakMusicController.musicType == .AppleMusic{
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                if cell.songInCell != nil {
                    
                    MPMediaLibrary().addItem(withProductID: (cell.songInCell?.id)!, completionHandler: {(ent, err) in
                        
                        /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                        /*******DO SOMETHING WITH THE ERROR******/
                    })
                }
            }
        } else if peakMusicController.musicType == .Guest {
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                if let songToAdd = cell.songInCell{
                    
                    //Add the song to core data here, and to the users current library
                    
                    //check if the user has already downloaded it
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                    newSong.setValue(songToAdd.id, forKey: "storedID")
                    newSong.setValue(Date(), forKey: "downloaded")
                    
                    
                    
                    //now try to save it
                    do{
                        try context.save()
                    }catch{
                        
                        print("The fiddler he now steps to the road")
                    }
                    
                }
            }
            
            //Now Reload the Data in both talbes so the user can see it
            (delegate as! LibraryViewController).fetchLibrary()
            searchedSongsTableView.reloadData()
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
            
            //Need to clear the current play queue here so it doesn't cause errors
            peakMusicController.currPlayQueue.removeAll()
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
        searchedSongsTableView.setContentOffset(CGPoint.zero, animated: true)
        if selectMusicFromSegment.selectedSegmentIndex == 0 {
            searchLibrary(search: search)
        }
        else if selectMusicFromSegment.selectedSegmentIndex == 1 {
            searchAppleMusic(search: search)
        } else {
            searchTopCharts()
        }
    }

    private func searchLibrary(search: String) {

        //we are searching the library so get the library // 3 cam store in top 5 results
        guard let library = delegate?.returnLibrary() else { return }
        
        DispatchQueue.global().async {
            let results = LocalSearch.search(search, library: library)
            
            DispatchQueue.main.async {
                self.topThreeResults = results
            }
        }
    }
    
    private func searchAppleMusic(search: String) {
        
        if search.length > 0 {
            SearchingAppleMusicApi.defaultSearch.addSearch(term: search, completion: {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 1 {
                        self.topThreeResults = songs as [AnyObject]
                    }
                }
            })
        }
        
        /*
        ConnectingToInternet.getSongs(searchTerm: search, limit: 7, sendSongsAlltogether: true, completion: {
            (songs) -> Void in
            
            DispatchQueue.main.async {
                self.topThreeResults = songs as [AnyObject]
            }
        })
 */
    }
    
    private func searchTopCharts() {
        
        DispatchQueue.main.async {
            ConnectingToInternet.searchTopCharts(completion: {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
                        self.topThreeResults = songs as [AnyObject]
                        self.loadingIndicator.stopAnimating()
                    }
                }
            })
        }
    }
    
    
    /*MARK: EXTRA METHODS*/
    func checkIfAlreadyInLibrary(_ id: String) -> Bool{
        //Method to check if the song is already in the users library
        
        if peakMusicController.musicType == .AppleMusic{
            
            for song in (delegate?.returnLibrary())!{
                
                if song.playbackStoreID == id{
                    
                    return true
                }
            }
        } else if peakMusicController.musicType == .Guest{
            
            for song in (delegate as! LibraryViewController).guestItemsInLibrary{
                
                if song.id == id{
                    return true
                }
            }
        }
        
        
        return false
    }
    
    

}
