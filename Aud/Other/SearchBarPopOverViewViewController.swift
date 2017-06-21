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

class SearchBarPopOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var selectMusicFromSegment: UISegmentedControl!
    
    @IBOutlet weak var searchedSongsTableView: UITableView!
    
    private var topResults = [BasicSong]() {
        
        didSet {
            
            self.searchedSongsTableView.reloadData()
            
        }
    }
    
    var delegate: SearchBarPopOverViewViewControllerDelegate?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    var isDisappearing = false
    
    /*MARK: LifeCycle Methods*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.color = UIColor.peakColor
        
        //add a listener so we know when segment changed
        selectMusicFromSegment.addTarget(self, action: #selector(searchRequestChanged), for: .valueChanged)
        selectMusicFromSegment.tintColor = UIColor.white
        
        
        searchedSongsTableView.delegate = self
        searchedSongsTableView.dataSource = self
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //Called when the popover is about to go away
        
        if let BCDel: BeastController = delegate as? BeastController{
            
            BCDel.mediaSearchBar.resetSearch(BCDel)
            
            BCDel.cancelSearch.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
            BCDel.cancelSearch.isHidden = true
        }
    }

    
    /*MARK: Editing Views*/
    func showViews(){
        
        for view in view.subviews{
            
            if let _: UIActivityIndicatorView = view as? UIActivityIndicatorView{
                
            }else{
                
                view.isHidden = false
            }
        }
    }
    
    func hideAllViews(){
        
        for view in view.subviews{
            
            view.removeFromSuperview()
        }
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
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
        let BC = (delegate as! BeastController)
        let cell = BC.libraryViewController.library.dequeueReusableCell(withIdentifier: "Song Cell") as! SongCell
        
        //Add the item to the cell
        cell.itemInCell = topResults[indexPath.row]
        
        //Check if we need to add it to the library
        let id = topResults[indexPath.row].getId()
        
        if !checkIfAlreadyInLibrary(id){
            
            cell.addToLibraryButton.isHidden = false
            cell.addToLibraryButton.addTarget(self, action: #selector(addToLibrary(_:)), for: .touchUpInside)
        } else{
            
            cell.addToLibraryButton.isHidden = true
        }
        
        
        cell.addItems()
        
        
        //Since we are in search, change the text color to white
        cell.songTitle.textColor = UIColor.white
        
        //add the gestures
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    
    
    /*MARKL TEXT FIELD DELEGATE METHODS*/
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Stop the loading indicator, in case we are coming from top charts
        loadingIndicator.stopAnimating()
        
        //If we are in the top charts, change to Browse so the user can start searching
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            selectMusicFromSegment.selectedSegmentIndex = 1
        }
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //Resign the text field
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField){
        
        //Clear the results from the table
        topResults = []
        
        //Let the user know we're loading their fucking data
        loadingIndicator.startAnimating()
        
        //Check to see if the user stopped typing for at least 0.5 seconds
        checkShouldSearch(textField.text ?? "")
        
    }
    
    /*MARK: OTHER SEARCH RELATED METHODS*/
    
    var latestQuery = ""
    
    func checkShouldSearch(_ searchQuery: String){
        
        //Check to see if the search request is still the same 0.5 seconds later
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)){
            
            if (self.delegate as! BeastController).mediaSearchBar.text == searchQuery{
                
                //It is so let's search
                self.searchSongs(search: searchQuery)
                self.latestQuery = searchQuery
                
            }
        }

    }
    
    
    @objc func resignSearchField(){
        
        isDisappearing = true
        hideAllViews()
        animateSelfAway(with: returnBlurView()!)
    }
    
    func returnBlurView() -> UIView?{
        
        for view in (delegate as! UIViewController).view.subviews{
            
            if let blur: UIVisualEffectView = view as? UIVisualEffectView{
                
                return blur
            }
        }
        
        return nil
    }
    
    func animateSelfAway(with blurView: UIView){
        
        UIView.animate(withDuration: 0.5, animations:{
            
            self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 0)
            blurView.frame = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.bounds.width, height: 0)
        }, completion: {(finsished) in
            
            blurView.removeFromSuperview()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    @objc func searchRequestChanged() {
        //Gets called when the segmented control changes
        
        //Clear the table
        self.topResults = []
        
        //need to stop the loading indicator in case the user started it and then switched before results were returned
        loadingIndicator.stopAnimating()
        
        var searchText = String()
        if let BCDel: BeastController = delegate as? BeastController {
            
            searchText = BCDel.mediaSearchBar.text ?? ""
        }
        
        
        //If we are searching TopCharts, please put away the keyboard and start the loading indicator
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            
            (delegate as! BeastController).mediaSearchBar.resignFirstResponder()
            loadingIndicator.startAnimating()
        }
        
        searchSongs(search: searchText)
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
 
    
    
    /*MARK: GESTURE RECOGNIZERS*/
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
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
    
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        //Gets called when a user taps on a song in the search
        
        //resign the keyboard
        let BC = delegate as! BeastController
        BC.mediaSearchBar.resignFirstResponder()
        
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

    
    /*MARK: Adding To Library Methods*/
    
    @objc func addToLibrary(_ button: UIButton){
        
        showSignifier()
        
        if let cell: SongCell = button.superview?.superview as? SongCell{
            
            switch peakMusicController.musicType{
                
            case .AppleMusic:
                addToAppleMusicLibrary(cell.itemInCell.getId())
                
            case .Spotify:
                addToSpotifyLibrary(songToAdd: cell.itemInCell)
                
            case .Guest:
                addToGuestLibrary(cell.itemInCell.getId())
            }
        }
    }
    
    func addToAppleMusicLibrary(_ songID: String){
        
        AddToLibrary.addToAppleMusicLibrary(songID, completion: checkAddedToLibrary(_:))
    }
    
    func addToGuestLibrary(_ songID: String){
        
        AddToLibrary.addToGuestLibrary(songID, completion: checkAddedToLibrary(_:))
    }
    
    func addToSpotifyLibrary(songToAdd: BasicSong){
        
        AddToLibrary.addToSpotifyLibrary(songToAdd, completion: checkAddedToLibrary(_:))
    }
    
    func errorAddingSongAlert(){
        
        let alert = UIAlertController(title: "There was an error adding the song to your library", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refreshTable(){
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)){
            
            self.searchedSongsTableView.reloadData()
        }
        
    }
    
    func checkAddedToLibrary(_ wasAdded: Bool){
        
        if wasAdded{
            
            refreshTable()
        }else{
            
            errorAddingSongAlert()
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
        alert.addAction(Alerts.sendToGroupQueueAlert(song))
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
                    
                    self.loadingIndicator.stopAnimating()
                    //Check to see if we still have the latest query
                    if self.latestQuery == (self.delegate as! BeastController).mediaSearchBar.text{
                        
                        self.topResults = results
                    }
                    
                    
                }
            }
        }
        
    }
    
    private func searchAppleMusic(search: String) {
        
        if search.length > 0 {
            
            /*THE FOLLOWING RIGHT HERE IS NOT GETTING CALLED*/
            SearchingAppleMusicApi.defaultSearch.addSearch(term: search, completion: {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    
                    if self.isDisappearing == false{
                        
                        self.loadingIndicator.stopAnimating()
                        if self.latestQuery == (self.delegate as! BeastController).mediaSearchBar.text{
                            
                            self.topResults = songs
                        }
                    }
                    
                   
                }
            })
        }
    }
    
    private func searchSpotifyMusic(search: String){
        
        if search.length > 0 {
            
            SearchingSpotifyMusic.defaultSearch.addSearch(term: search){ songs in
                
                DispatchQueue.main.async {
                    
                    if self.isDisappearing == false{
                        
                        self.loadingIndicator.stopAnimating()
                        if self.latestQuery == (self.delegate as! BeastController).mediaSearchBar.text{
                            
                            self.topResults = songs
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func searchTopCharts() {
        
        
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
            
            
            SPTSearch.perform(withQuery: song.getTrackName(), queryType: SPTSearchQueryType.queryTypeTrack, accessToken: auth?.session.accessToken){ err, callback in
                
                //Use the callback to get the song
                if let page: SPTListPage = callback as? SPTListPage {
                    
                    if page.items != nil {
                        
                        if let songs = page.items as? [SPTPartialTrack] {
                            let (song, _) = GettingClosestSong.getClosestSong(searchSong: song, songs: songs)
                            
                            DispatchQueue.main.async {
                                
                                if self.isDisappearing == false{
                                    
                                    if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
                                        
                                        _ = song.getImage()
                                        self.topResults.append(song)
                                        self.loadingIndicator.stopAnimating()
                                    }
                                }
                                
                                
                                
                            }
                            
                        }
                        else {
                            
                            print("\n\n\nERROR: BluetoothHandler->convertAppleMusicIDToURI \n\n\n")
                        }
                        
                    }
                }
            }
            
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
