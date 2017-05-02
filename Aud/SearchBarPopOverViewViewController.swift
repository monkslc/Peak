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
    
    func returnLibraryItems() -> [LibraryItem]
    
    //func returnLibrary() -> [MPMediaItem]
    
    //func getGuestLibrary() -> [Song]
}

class SearchBarPopOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var selectMusicFromSegment: UISegmentedControl!
    
    @IBOutlet weak var searchedSongsTableView: UITableView!
    
    private var topResults = [LibraryItem]() {
        
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
        
        return topResults.count + 2 //so we can see bottom results
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //check if we are in the last two
        if indexPath.row >= topResults.count{
            
            let cell = UITableViewCell(frame: CGRect())
            
            return cell
        }
        
        let cell = (delegate as! LibraryViewController).library.dequeueReusableCell(withIdentifier: "Song Cell") as! SongCell
        
        //Add the item to the cell
        cell.itemInCell = topResults[indexPath.row]
        
        //Check if we need to add it to the library
        var id = ""
        switch topResults[indexPath.row]{
            
        case .MediaItem(let song):
            id = song.playbackStoreID
            
        case .GuestItem(let song):
            id = song.id
        }
        
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
        
        if let LVCDel:LibraryViewController = delegate as? LibraryViewController{
            
            searchBar.delegate = LVCDel
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
        if let LVCdel: LibraryViewController = delegate as? LibraryViewController {
            
            searchText = LVCdel.searchForMediaBar.text!
        }
        
        
        //If we are searching TopCharts, please put away the keyboard and start the loading indicator
        if selectMusicFromSegment.selectedSegmentIndex == 2{
            
            (delegate as! LibraryViewController).searchForMediaBar.resignFirstResponder()
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
            
            let alert = SongOptionsController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            alert.addSearchAlerts(gesture, delegateViewController: (delegate as! LibraryViewController))
            alert.presentMe(gesture, presenterViewController: self)
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
    
    func addToLibrary(_ button: UIButton){
        
        button.isHidden = true
        
        showSignifier()
        
        //Check what type of musci we are playing
        
        if peakMusicController.musicType == .AppleMusic{
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                switch cell.itemInCell{
                    
                case .GuestItem(let song):
                    MPMediaLibrary().addItem(withProductID: song.id, completionHandler: {(ent, err) in
                        
                        /*******LET THE USER KNOW OF ANY ERRORS HERE*********/
                        /*******DO SOMETHING WITH THE ERROR******/
                    })
                    
                default:
                    break
                }
                
            }
            
    
            
        } else if peakMusicController.musicType == .Guest {
            
            if let cell: SongCell = button.superview?.superview as? SongCell{
                
                switch cell.itemInCell{
                    
                case .GuestItem(let song):
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let newSong = NSEntityDescription.insertNewObject(forEntityName: "StoredSong", into: context)
                    newSong.setValue(song.id, forKey: "storedID")
                    newSong.setValue(Date(), forKey: "downloaded")
                    
                    
                    
                    //now try to save it
                    do{
                        try context.save()
                    }catch{
                        
                        print("The fiddler he now steps to the road")
                    }
                    
                default:
                    break
                    
                }
                
            }
            
            //Now Reload the Data in both talbes so the user can see it
            (delegate as! LibraryViewController).userLibrary.fetchLibrary()
            searchedSongsTableView.reloadData()
        }
    }
    
    
    /*TAP METHODS*/
    
    func notContributorTap(_ cell: SongCell){
        //Handle the music for the non contributor
        
        //Check library or apple music
        
        switch cell.itemInCell{
            
        case .MediaItem(let song):
            peakMusicController.play([song])
            
        case .GuestItem(let song):
            
            peakMusicController.currPlayQueue.removeAll()
            peakMusicController.systemMusicPlayer.setQueueWithStoreIDs([song.id])
            peakMusicController.systemMusicPlayer.play()
        }
    }
    
    func contributorTap(_ cell: SongCell){
        //Handle the music for a contributor
        
        var songId = String()
        var songTitle = String()
        
        //Check if we are in apple music or library and get the song id + title
        switch cell.itemInCell{
            
        case .MediaItem(let song):
            songId = song.playbackStoreID
            songTitle = song.title!
            
        case .GuestItem(let song):
            songId = song.id
            songTitle = song.trackName
        }

        
        //Alert the user
        promptUserToSendToGroupQueue(songTitle: songTitle, songId: songId)
    }
    
    func promptUserToSendToGroupQueue(songTitle: String, songId: String){
        //Makes sure the user wants to send the item to the group queue
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(songTitle) to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
            
            self.showSignifier()
            
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

        guard let packedLibrary = delegate?.returnLibraryItems() else { return }

        var library = [Any]()
        for item in packedLibrary{
            
            switch item{
                
            case .MediaItem(let song):
                library.append(song)
                
            case .GuestItem(let song):
                library.append(song)
            }
        }
        
        
        
        switch peakMusicController.musicType {
        case .AppleMusic:
            //guard let library = delegate?.returnLibrary() else { return }
            
            let newLibrary = (library as! [MPMediaItem])
            
            DispatchQueue.global().async {
                let results = LocalSearch.search(search, library: newLibrary)
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 0 {
                        
                        var temp = [LibraryItem]()
                        for result in results{
                            temp.append(LibraryItem.MediaItem(result))
                        }
                        
                        self.topResults = temp
                    }
                }
            }
        case .Guest:
            
            let newlibrary = (library as! [Song])
            
            DispatchQueue.global().async {
                let results = LocalSearch.search(search, library: newlibrary)
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 0 {
                        //self.topResults = results
                        var temp = [LibraryItem]()
                        for result in results{
                            temp.append(LibraryItem.GuestItem(result))
                        }
                        self.topResults = temp
                    }
                }
            }
        }
        
    }
    
    private func searchAppleMusic(search: String) {
        
        if search.length > 0 {
            SearchingAppleMusicApi.defaultSearch.addSearch(term: search, completion: {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 1 {
                        //self.topResults = songs as [AnyObject]
                        var temp = [LibraryItem]()
                        for song in songs{
                            temp.append(LibraryItem.GuestItem(song))
                        }
                        self.topResults = temp
                    }
                }
            })
        }
    }
    
    private func searchTopCharts() {
        
        if let songs = GettingTopCharts.defaultGettingTopCharts.lastTopCharts {
            DispatchQueue.main.async {
                if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
            
                    var temp = [LibraryItem]()
                    for song in songs{
                        
                        temp.append(LibraryItem.GuestItem(song))
                    }
                    self.topResults = temp
                    
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
        else {
            GettingTopCharts.defaultGettingTopCharts.completion = {
                (songs) -> Void in
                
                DispatchQueue.main.async {
                    if self.selectMusicFromSegment.selectedSegmentIndex == 2 {
                    
                        var temp = [LibraryItem]()
                        for song in songs{
                            
                            temp.append(LibraryItem.GuestItem(song))
                        }
                        self.topResults = temp
                        
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
            GettingTopCharts.defaultGettingTopCharts.searchTopCharts()
        }
    }
    
    
    /*MARK: EXTRA METHODS*/
    func checkIfAlreadyInLibrary(_ id: String) -> Bool{
        //Method to check if the song is already in the users library
        
        
        
        for item in (delegate?.returnLibraryItems())!{
            
            switch item{
                
            case .MediaItem(let song):
                if song.playbackStoreID == id{
                    return true
                }
                
            case .GuestItem(let song):
                if song.id == id{
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    

}
