//
//  ViewController.swift
//  Aud
//
//  Created by Connor Monks on 3/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit
import AVKit
import MultipeerConnectivity
import CoreData

protocol LibraryViewControllerDelegate{
    
    func showSignifier()
}

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, ScrollBarDelegate, UserLibraryDelegate{
    

    /*MODEL for all library info*/
    let userLibrary = UserLibrary()
    
    @IBOutlet weak var library: UITableView!
    
    @IBOutlet weak var recentsView: RecentlyAddedView!
    
    //View that controls the scroll bar
    @IBOutlet weak var scrollBar: ScrollBar!
    @IBOutlet weak var scrollPresenter: ScrollPresenterView!
    
    var delegate: LibraryViewControllerDelegate?
    
    
    /*MARK: LIFECYCLE METHODS*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the delegate for the user library
        userLibrary.delegate = self
        
        //Fetch the items in the library
        DispatchQueue.global().async {
            
            self.userLibrary.fetchLibrary()
        }
        
        //set up the scroll bar
        scrollBar.delegate = self
        scrollBar.setUp()
        scrollPresenter.setUp()
        
        //Set up the recents view
        recentsView.setUp()
        
        //Add Listener
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    

        if peakMusicController.musicType != .Guest && peakMusicController.playerType != .Contributor {
            
            MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()
        }
    
    }
    
    
    //Used to set up the currently playing view
    var loadedViews = false
    override func viewDidLayoutSubviews() {
        
        if loadedViews == false {
            
            //recentsView.setUp()
            loadedViews = true
        }

        
    }
    
    
    /*MARK: User Interaction Methods*/
    
    @IBAction func displaySongOptions(_ sender: UILongPressGestureRecognizer) {
        //Used to pop up alert view for more song options
        
        if sender.state == .began {

            //Get our song collections
            let mediaItemsInLibrary = userLibrary.itemsInLibrary
            let recentSongsDownloaded = userLibrary.recents
            
            
            let alert = SongOptionsController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            alert.addLibraryAlerts(sender: sender, library: mediaItemsInLibrary as! [MPMediaItem], recents: recentSongsDownloaded as! [MPMediaItem])
            alert.presentMe(sender, presenterViewController: self)
        }
        
    }

    
    
    /*MARK: Notification Methods*/
    
    func enteringForeground(_ notification: NSNotification){
        
        peakMusicController.systemMusicPlayer.shuffleMode = .off
    }
    /*END OF NOTIFICATION METHODS*/
    
    /*MARK: USER LIBRARY DELEGATE METHODS*/
    
    func libraryItemsUpdated() {
        //Get's called when the variable in userLibrary changes
        //Update our displays
        
        library.reloadData()
        displayRecentlyPlayed(userLibrary.recents)
    }
    

    func displayRecentlyPlayed(_ recentItems: [BasicSong]){
        
        //First Remove All Subviews
        for sub in recentsView.subviews{
            
            sub.removeFromSuperview()
        }
        
        //Now add the initial subview
        let reView = UIView(frame: CGRect(x: 0, y: 0, width: (recentItems.count * 100), height: Int(recentsView.frame.height)))
        recentsView.contentSize = CGSize(width: reView.frame.width, height: reView.frame.height)
        recentsView.addSubview(reView)
        
        //Loop through and add each recent
        var counter = 0
        for song in recentItems{
            
            //Create the album view for the song
            let albumView = RecentsAlbumView(frame: CGRect(x: CGFloat(Double(counter * 100) + 12.5), y: 0, width: 75, height: 75))
            
            //Create the label for the song
            let songTitle = UILabel(frame: CGRect(x: counter*100, y: 80, width: 100, height: 20))
            songTitle.textAlignment = .center
            songTitle.font = UIFont.systemFont(ofSize: 10)
            
            
            //Set our data depending on the song type
            albumView.setUp(song)
            songTitle.text = song.getTrackName()
            
            
            //Add the gesture recognizers to the album view
            albumView.isUserInteractionEnabled = true
            albumView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnSong(_:))))
            albumView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(displaySongOptions(_:))))
            
            //Add our subviews
            reView.addSubview(albumView)
            reView.addSubview(songTitle)
            
            //add to the accumulator
            counter += 1
        }
    }
    
    /*MARK: Table View Data Source/Delegate Methods*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return the number of rows we want
        
        
        return userLibrary.itemsInLibrary.count + 2 //add two so the last rows don't get hidden
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Always want one section
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Check if it is our last two rows
        if indexPath.row >= userLibrary.itemsInLibrary.count {
            
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            
            return cell
        }
        
        
        //Create the cells here
        let cell = tableView.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
        
        let mediaItemToAdd = userLibrary.itemsInLibrary[indexPath.row]
        
        //Get the data for the media item
        cell.albumArt.image = mediaItemToAdd.getImage()
        cell.songTitle.text = mediaItemToAdd.getTrackName()
        cell.songArtist.text = mediaItemToAdd.getArtistName()
        
        cell.itemInCell = mediaItemToAdd
        
        //Hide the bullshit
        cell.addToLibraryButton.isHidden = true
        cell.songDurationLabel.isHidden = true
        
        //Add our gestures to the cell
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnSong(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(displaySongOptions(_:))))
        
        
        return cell
    }
    
    /*MARK: Scroll Bar Delegate Methods*/
    func scrolling(_ yLoc: CGFloat,_ state: UIGestureRecognizerState) {
        
        let libraryCount = userLibrary.itemsInLibrary.count
        
        //Get the index of the cell we want to scroll to
        var indexToScrollTo = floor(yLoc / ((scrollBar.frame.height-scrollBar.heightOfScrollBar) / CGFloat(libraryCount + 2))) //add two because we did that for num of rows
        
        //Make sure our index path is in range
        if indexToScrollTo >= 0 && indexToScrollTo < CGFloat(libraryCount){
            
            scrollPresenter.positionOfLabel = yLoc + scrollBar.heightOfScrollBar / 2
            scrollPresenter.displayLabel.text = userLibrary.itemsInLibrary[Int(indexToScrollTo)].getArtistName()
        }
        
        //Now update the label
        
        if state == .began{
            
            scrollPresenter.displayLabelView.isHidden = false
        } else if state == .ended{
            
            //Get the cell index we want to scroll to
            if indexToScrollTo < 0{
                indexToScrollTo = 0
            } else if indexToScrollTo > CGFloat(libraryCount){
                
                indexToScrollTo = CGFloat(libraryCount)
            }
            
            library.scrollToRow(at: IndexPath(row: Int(indexToScrollTo), section: 0), at: .top, animated: false)
            scrollPresenter.displayLabelView.isHidden = true
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Check if the header view is visible
        if scrollView.contentOffset.y < (library.tableHeaderView?.frame.height)! {
            //it's showing
            
            scrollBar.isHidden = true
        }else {
            //it's not
            
            scrollBar.isHidden = false
        }
        
        //Get the top cell and its position
        let topCell = library.visibleCells[0]
        let pos = library.indexPath(for: topCell)?.row
        
        let libraryCount = userLibrary.itemsInLibrary.count
        
        scrollBar.position = CGFloat(pos!) * (scrollBar.frame.height / CGFloat(libraryCount))
    }
    
    /*GESTURE TARGET METHODS*/
    
    func handleTapOnSong(_ gesture: UITapGestureRecognizer) {
        
        //Get the holder
        let holder: BasicSongHolder = (gesture.view as? BasicSongHolder)!
        
        //Switch on it and perform the appropriate action
        switch peakMusicController.playerType{
            
        case .Contributor:
            promptUserToSendToGroupQueue(holder.getBasicSong())
            
        default:
            
            if let song: MPMediaItem = holder.getBasicSong() as? MPMediaItem{
                
                peakMusicController.play([song])
            } else if let song: Song = holder.getBasicSong() as? Song{
                
                tellUserToConnect(song)
            }
        }
    }
    
    func promptUserToSendToGroupQueue(_ song: BasicSong){
        //Method to ask the user if they'd like to send a song to the group queue
        
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(song.getTrackName()) to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
            
            self.delegate?.showSignifier()
            
            SendingBluetooth.sendSongIdToHost(id: "\(song.getId())", error: {
                () -> Void in
                
                let alert = UIAlertController(title: "Error", message: "Could not send", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }) // @cam added this. may want to change
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func tellUserToConnect(_ song: Song){
        //User can't play locally, let the idiot know
        
        let alert = UIAlertController(title: "Connect", message: "Guests cannot play music locally. In order to hear \(song.trackName), connect with another user.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
