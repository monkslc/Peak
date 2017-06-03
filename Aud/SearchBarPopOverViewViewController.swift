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
    
    func returnLibraryItems() -> [BasicSong]
    
}

class SearchBarPopOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var selectMusicFromSegment: UISegmentedControl!
    
    @IBOutlet weak var searchedSongsTableView: UITableView!
    
    private var topResults = [BasicSong]() {
        
        didSet {
            
            self.searchedSongsTableView.reloadData()
            
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

        
        if let BCDel: BeastController = delegate as? BeastController{
            
            BCDel.searchForMediaBar.resignFirstResponder()
        }
        
        let BC = delegate as! BeastController
        BC.searchForMediaBar.showsCancelButton = false
    }

    
    /*MARK: TABLE VIEW DELEGATE METHODS*/
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return topResults.count + 2 //so we can see bottom results
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //check if we are in the last two
        if indexPath.row >= topResults.count{
            
            let cell = UITableViewCell(frame: CGRect())
            
            return cell
        }
        
        let BC = (delegate as! BeastController)
        let cell = BC.libraryViewController?.library.dequeueReusableCell(withIdentifier: "Song Cell") as! SongCell
        
        //Add the item to the cell
        cell.itemInCell = topResults[indexPath.row]
        
        //Check if we need to add it to the library
        let id = topResults[indexPath.row].getId()
        
        if !checkIfAlreadyInLibrary(id){
            
            cell.addToLibraryButton.isHidden = false
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        loadingIndicator.stopAnimating() //In case we are coming from top charts
        
        //If we are in Top Charts, change to Apple Music so the user can start searching
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            selectMusicFromSegment.selectedSegmentIndex = 1
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
        //The cancel button was clicked so segue back
        
        if let BCDel:BeastController = delegate as? BeastController{
            
            searchBar.delegate = BCDel
        }
        
        searchBar.text = ""
        
        
        UIView.animate(withDuration: 0.35, animations: {(animate) in
            
            self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY - self.view.self.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: {(bool) in
        
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let search = searchBar.text else { return }
        
        searchSongs(search: search)
    }
    
    
    func searchRequestChanged() {
        //Gets called when the segmented control changes
        
        
        //need to stop the loading indicator in case the user started it and then switched before results were returned
        loadingIndicator.stopAnimating()
        
        topResults = []
        
        var searchText = String()
        if let BCDel: BeastController = delegate as? BeastController {
            
            searchText = BCDel.searchForMediaBar.text!
        }
        
        
        //If we are searching TopCharts, please put away the keyboard and start the loading indicator
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            
            (delegate as! BeastController).searchForMediaBar.resignFirstResponder()
            loadingIndicator.startAnimating()
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
            
            //Create the alert
            let alert = SongOptionsController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            
            //Get the song
            let song = (gesture.view as! BasicSongHolder).getBasicSong()
            
            //Add the alerts
            alert.addAlerts(song: song, inLibrary: checkIfAlreadyInLibrary(song.getId()), library: nil, recents: nil)
            
            //Present
            alert.presentMe(gesture, presenterViewController: self)
        }
        
    }
    
    
    func handleTap(_ gesture: UITapGestureRecognizer){
        //Gets called when a user taps on a song in the search
        
        //resign the keyboard
        let BC = delegate as! BeastController
        BC.searchForMediaBar.resignFirstResponder()
        
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
    
    func addToLibrary(_ button: UIButton){
        
        //button.isHidden = true
        
        showSignifier()
        
        //Check what type of musci we are playing
        
        if peakMusicController.musicType == .AppleMusic {
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                MPMediaLibrary().addItem(withProductID: cell.itemInCell.getId(), completionHandler: {(ent, err) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
                        
                        self.searchedSongsTableView.reloadData()
                    }
                    NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
                    /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                    /*******DO SOMETHING WITH THE ERROR******/
                })
            }
        }
        else if peakMusicController.musicType == .Guest {
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                newSong.setValue(cell.itemInCell.getId(), forKey: "storedID")
                newSong.setValue(Date(), forKey: "downloaded")
                
                
                
                //now try to save it
                do{
                    try context.save()
                }catch{
                    
                    print("The fiddler he now steps to the road")
                }
                
            }
            
            //Now Reload the Data in both talbes so the user can see it
            
            //Do me here
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
             
                self.searchedSongsTableView.reloadData()
            }
            NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
            
        }
        else if peakMusicController.musicType == .Spotify{
            
            /*HERE WE NEED TO ADD TO SPOTIFY LIBRARY*/
            
            DispatchQueue.global().async {
                
                if let cell: SongCell = button.superview?.superview as? SongCell {
                    
                    if let track = cell.itemInCell as? SPTPartialTrack {
                        
                        SPTYourMusic.saveTracks([track], forUserWithAccessToken: auth?.session.accessToken){ err, callback in
                            
                            if err != nil{
                                
                                print("We had an error bitches, \(err!)")
                                return
                            }
                            
                            
                            //Update Library Here
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
                                
                                self.searchedSongsTableView.reloadData()
                            }
                            
                            NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
                        }
                    }
                    
                }
            }
            
        }
    }
    
    
    /*TAP METHODS*/
    func notContributorTap(_ cell: SongCell){
        //Handle the music for the non contributor
        
        //Check if we have a song
        
        if let song: Song = cell.itemInCell as? Song{
            
            //we have a song which we need to play by id
            peakMusicController.currPlayQueue.removeAll()
            peakMusicController.systemMusicPlayer.setQueueIds([song.id])
            peakMusicController.systemMusicPlayer.startPlaying()
            
        } else{
            
            //We don't have a song so just play shit here
            peakMusicController.play([cell.itemInCell])
        }
    
    }
    
    func contributorTap(_ cell: SongCell){
        //Handle the music for a contributor
        
        //Alert the user
        promptUserToSendToGroupQueue(song: cell.itemInCell)
    }
    
    func promptUserToSendToGroupQueue(song: BasicSong){
        //Makes sure the user wants to send the item to the group queue
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(song.getTrackName()) to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
            
            self.showSignifier()
            
            SendingBluetooth.sendSongIdToHost(song: song, error: {
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
            
            //Check what store we should be searching
            switch peakMusicController.musicType{
                
            case .Spotify:
                searchSpotifyMusic(search: search)
                
            default:
                searchAppleMusic(search: search)
            }
            
        } else {
            searchTopCharts()
        }
    }

    
    private func searchLibrary(search: String) {

        guard let library = delegate?.returnLibraryItems() else { return }

        DispatchQueue.global().async {
            let results = LocalSearch.search(search, library: library)
            
            DispatchQueue.main.async {
                if self.selectMusicFromSegment.selectedSegmentIndex == 0 {
                    
                    self.topResults = results
                }
            }
        }
        
    }
    
    private func searchAppleMusic(search: String) {
        
        if search.length > 0 {
            SearchingAppleMusicApi.defaultSearch.addSearch(term: search, completion: {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    self.topResults = songs
                   
                }
            })
        }
    }
    
    private func searchSpotifyMusic(search: String){
        
        /*HERE: MAKE SPOTIFY SEARCH WORK*/
        
        if search.length > 0 {
            
            
            SearchingSpotifyMusic.defaultSearch.addSearch(term: search){ songs in
                
                DispatchQueue.main.async {
                    
                    self.topResults = songs
                }
                
            }
        }
    }
    
    private func searchTopCharts() {
        
        if let songs = GettingTopCharts.defaultGettingTopCharts.lastTopCharts {
            DispatchQueue.main.async {
                if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
            
                    //Check if we are a Spotify Player so we can convert to Spotify Songs
                    if peakMusicController.musicType == .Spotify{
                        
                        self.convertTopChartsToSpotify(songs: songs)
                    } else{
                        
                        self.topResults = songs
                        self.loadingIndicator.stopAnimating()
                    }
                    
                }
            }
        }
        else {
            GettingTopCharts.defaultGettingTopCharts.completion = {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
                    
                        //Check if we are a Spotify Player so we can convert to Spotify Songs
                        if peakMusicController.musicType == .Spotify{
                            
                            self.convertTopChartsToSpotify(songs: songs)
                        }else{
                            
                            self.topResults = songs
                            self.loadingIndicator.stopAnimating()
                        }
                        
                        
                    }
                }
            }
            GettingTopCharts.defaultGettingTopCharts.searchTopCharts()
        }
    }
    
    
    
    private func convertTopChartsToSpotify(songs: [BasicSong]){
        
        //Take the songID and turn it into a song
        for song in songs{
            
            ConnectingToInternet.getSong(id: song.getId(), completion: { appleMusicSong in
                
                //Use the callback to get the song
                if let page: SPTListPage = callback as? SPTListPage {
                    
                    if page.items != nil {
                        
                        if let songs = page.items as? [SPTPartialTrack] {
                            let (song, _) = GettingClosestSong.getClosestSong(searchSong: song, songs: songs)
                            
                            DispatchQueue.main.async {
                                
                                if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
                                    
                                    _ = song.getImage()
                                    self.topResults.append(song)
                                    self.loadingIndicator.stopAnimating()
                                }
                                
                            }
                            
                        }
                        else {
                            
                            print("\n\n\nERROR: BluetoothHandler->convertAppleMusicIDToURI \n\n\n")
                        }
                        
                    }
                }
            })
        }
        
    }
    
    /*MARK: EXTRA METHODS*/
    func checkIfAlreadyInLibrary(_ id: String) -> Bool{
        //Method to check if the song is already in the users library
        
        for item in (delegate?.returnLibraryItems())!{
            
            if item.getId() == id{
                
                return true
            }
        }
        
        return false
    }
    
    

}
