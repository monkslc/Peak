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


let peakMusicController = PeakMusicController()

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,PeakMusicControllerDelegate {
    
    
    
    //view that displays currently playing options
    @IBOutlet weak var currPlayingView: CurrentlyPlayingView!
    
    @IBOutlet weak var library: UITableView!
    
    //Data for the library
    var mediaItemsInLibrary = [MPMediaItem]() {
        
        didSet{
            library.reloadData()
        }
    }
    
    
    @IBOutlet weak var recentsView: RecentlyAddedView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //systemMusicPlayer.setQueueWithStoreIDs(["966997496"])
        //systemMusicPlayer.setQueueWithStoreIDs(["798928362"])
        
        
        //First thing we want to do is start the fetch the user's library
        DispatchQueue.global().async {
            self.fetchLibrary()
        }
        
        
        //Now set up the music controller
        peakMusicController.delegate = self
        peakMusicController.setUp()
        
        //Now we want to enable the settings for the recents view at the top of the table
        recentsView.setUp()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        

    }
    
    
    //Used to set up the currently playing view
    var loadedViews = false
    override func viewDidLayoutSubviews() {
        
        
        if loadedViews == false {
        
            currPlayingView.library = library
            currPlayingView.addAllViews()
            loadedViews = true
            currPlayingView.setNeedsDisplay()
            recentsView.setNeedsDisplay()
        }
        
        
        //Set the albumView
        if peakMusicController.systemMusicPlayer.nowPlayingItem?.artwork != nil {
            
             currPlayingView.albumView.image = peakMusicController.systemMusicPlayer.nowPlayingItem?.artwork?.image(at: CGSize())
        }
       
        
    }
    
    @IBAction func displaySongOptions(_ sender: UILongPressGestureRecognizer) {
        //Used to pop up alert view for more song options
        
        if sender.state == .began {
            
            //alert the options for the song here
            let alert = UIAlertController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            
            //Add Play Song Option
            alert.addAction(UIAlertAction(title: "Play Song", style: .default, handler: {(alert) in
                
                if let cell: SongCell = sender.view as? SongCell {
                    
                    peakMusicController.play([cell.mediaItemInCell])
                } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                    
                    peakMusicController.play([albumView.mediaItemAssocWithImage])
                }
                
            }))
            
            //Add Play Next Option
            alert.addAction(UIAlertAction(title: "Play Next", style: .default, handler: {(alert) in
            
                if let cell: SongCell = sender.view as? SongCell {
                    
                    peakMusicController.playNext([cell.mediaItemInCell])
                }else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                    
                    peakMusicController.playNext([albumView.mediaItemAssocWithImage])
                }
            }))
            
            //Add Add to end of Queue
            alert.addAction(UIAlertAction(title: "Play Last", style: .default, handler: {(alert) in
            
                if let cell: SongCell = sender.view as? SongCell {
                    
                    peakMusicController.playAtEndOfQueue([cell.mediaItemInCell])
                } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                    
                    peakMusicController.playAtEndOfQueue([albumView.mediaItemAssocWithImage])
                }
                
            }))
            
            //Add play album
            alert.addAction(UIAlertAction(title: "Play Album", style: .default, handler: {(action) in
                
                if let cell: SongCell = sender.view as? SongCell {
                    
                    peakMusicController.play(album: cell.mediaItemInCell)
                } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                    
                    peakMusicController.play(album: albumView.mediaItemAssocWithImage)
                }
                
            }))
            
            //Add Shuffle Artist
            alert.addAction(UIAlertAction(title: "Play Artist", style: .default, handler: {(action ) in
                
                if let cell: SongCell = sender.view as? SongCell {
                
                    peakMusicController.play(artist: cell.mediaItemInCell)
                } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                    
                    peakMusicController.play(artist: albumView.mediaItemAssocWithImage)
                }
                
            }))
            
            //Add a cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
            //self.present(alert, animated: true, completion: nil)
            alert.modalPresentationStyle = .popover
            let ppc = alert.popoverPresentationController
            ppc?.sourceRect = (sender.view?.bounds)!
            ppc?.sourceView = sender.view
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func showHidePlayingView(_ sender: UITapGestureRecognizer) {
        //Method to hand tap on currently playing view
        
        currPlayingView.animate()
    }
    
    //Fast Scroll Methods
    @IBAction func skipUpTable() {
        
        //Get the IndexPath to scroll to
        let currentIndexPath = library.indexPath(for: library.visibleCells[0])
        let indexPathRow = max((currentIndexPath?.row)! - 25, 0)
        let newIndexPath = IndexPath(row: indexPathRow, section: 0)
        
        library.scrollToRow(at: newIndexPath, at: .top, animated: true)
        library.isScrollEnabled = true
    }
    
    @IBAction func skipDownTable() {
        
        //Get the IndexPath to scroll to
        let currentIndexPath = library.indexPath(for: library.visibleCells[library.visibleCells.count - 1])
        let indexPathRow = min((currentIndexPath?.row)! + 25, mediaItemsInLibrary.count + 1)
        let newIndexPath = IndexPath(row: indexPathRow, section: 0)
        
        library.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        library.isScrollEnabled = true
    }
    
    
    
    
    /*End of User interaction methods*/
    
    
    /*START OF NOTIFICATION METHODS*/
    
    
    
    func enteringForeground(_ notification: NSNotification){
        
        peakMusicController.systemMusicPlayer.shuffleMode = .off
    }
    /*END OF NOTIFICATION METHODS*/
    
    /*Start of Fetching Methods*/
    func fetchLibrary(){
        
        
        //Temp Sort Method
        func sort(_ item1: MPMediaItem, _ item2: MPMediaItem) -> Bool {
            
            if item1.dateAdded > item2.dateAdded {
                return true
            } else {
                return false
            }
        }
        
        
        //Do this async
        DispatchQueue.global().async {
            
            //Fetch by artists
            
            let retreivedItems = MPMediaQuery.artists().items
            
            //Retreive the recently played items
            let maxItemsToRetrieve = min(retreivedItems!.count, 20)
            var recentlyPlayedItems = retreivedItems
            recentlyPlayedItems = recentlyPlayedItems?.sorted(by: sort)
            
            let recentList = recentlyPlayedItems?[0..<maxItemsToRetrieve]
            
            DispatchQueue.main.async {
            
                self.mediaItemsInLibrary = retreivedItems!
                self.displayRecentlyPlayed(recentList!)
                
            }
            
        }
        
       
    }

    /*END OF FETCHING METHODS*/
    func displayRecentlyPlayed(_ recents: ArraySlice<MPMediaItem>){
        
        //First Add The Subview
        let reView = UIView(frame: CGRect(x: 0, y: 0, width: (recents.count * 100), height: Int(recentsView.frame.height)))
        recentsView.contentSize = CGSize(width: reView.frame.width, height: reView.frame.height)
        recentsView.addSubview(reView)
        
        //Loop through and add each recent
        var counter = 0
        for song in recents {
            
            
            //Create the AlbumView
            let albumImage = RecentsAlbumView(frame: CGRect(x: CGFloat(Double(counter * 100) + 12.5), y: 0, width: 75, height: 75))
            albumImage.image = song.artwork?.image(at: CGSize())
            albumImage.layer.cornerRadius = 5
            albumImage.clipsToBounds = true
            albumImage.layer.borderColor = UIColor.lightGray.cgColor
            albumImage.layer.borderWidth = 1.0
            albumImage.mediaItemAssocWithImage = song
            reView.addSubview(albumImage)
            
            //Add the gesture recognizers to the album view
            albumImage.isUserInteractionEnabled = true
            albumImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnSong(_:))))
            albumImage.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(displaySongOptions(_:))))
            
            //Create the Label
            let songTitle = UILabel(frame: CGRect(x: counter*100, y: 80, width: 100, height: 20))
            songTitle.textAlignment = .center
            songTitle.text = song.title
            songTitle.font = UIFont.systemFont(ofSize: 10)
            reView.addSubview(songTitle)
            
            counter+=1
        }
    }
    
    /*Start of Table View Data Source/Delegate Methods*/
    
    //For now always return 1
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    //We want the number of rows to be equal to the number of media items + 2 so curr Play view doesnt cover
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mediaItemsInLibrary.count + 2
    }
    
    //Create the cells here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //First check to see if it should be the last empty row
        if indexPath.row == mediaItemsInLibrary.count || indexPath.row == mediaItemsInLibrary.count + 1 {
            
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            
            return cell
        }
        
        let mediaItemToAdd = mediaItemsInLibrary[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
        
        cell.albumArt.image = mediaItemToAdd.artwork?.image(at: CGSize())
        cell.songTitle.text = mediaItemToAdd.title
        cell.songArtist.text = mediaItemToAdd.artist
        cell.mediaItemInCell = mediaItemToAdd
        
        //ADD GESTURES
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnSong(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(displaySongOptions(_:))))
        
        return cell
        
    }

   
    
    /*End of Table View Data Source/Delegate Methods*/
    
    
    /*PEAK MUSIC CONTROLLER DELEGATE METHODS, USED TO UPDATE VIEWS*/
    func showSignifier(){
        
        let sig = Signifier(frame: CGRect(x: view.bounds.midX - 50, y: view.bounds.midY - 50, width: 100, height: 100))
        sig.animationSetUp()
        view.addSubview(sig)
        sig.animate()
        
    }
    
    func updateDisplay() {
        
        currPlayingView.updateInfoDisplay()
    }
    /*End of Peak Music Controller Delegate Methods*/
    
    
    /*GESTURE TARGET METHODS*/
    
    func handleTapOnSong(_ gesture: UITapGestureRecognizer){
        
        //check to see where the gesture is coming from and respond accordingly
        if let albumArt: RecentsAlbumView = gesture.view as? RecentsAlbumView {
            
            peakMusicController.play([albumArt.mediaItemAssocWithImage])
        } else if let cell: SongCell = gesture.view as? SongCell {
            
            peakMusicController.play([cell.mediaItemInCell])
        }
    }
    /*END OF GESTURE TARGET METHODS*/
    
    
    
    /************************TEST METHODS FOR BLUETOOTH******************************/
    
    //120954025
    /*TEST OF RECEVING A SONG FROM A USER*/
    func receivedSong(_ songID: String){
        
        //add the song to the user's library, async
        DispatchQueue.global().async {
            
            var song = MPMediaItem()
            let library = MPMediaLibrary()
            library.addItem(withProductID: songID, completionHandler: {(ent, err) in
                
                //add the entity to the queue
                song = ent[0] as! MPMediaItem
                
                DispatchQueue.main.async {
                    peakMusicController.playAtEndOfQueue([song])
                }
                
                
            })
        }
        
    }
}


