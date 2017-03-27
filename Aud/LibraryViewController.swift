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

let peakMusicController = PeakMusicController()

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,PeakMusicControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    
    
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
        //recentsView.setUp()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        

        // Bluetooth
        //appDelegate.mpcManager.delegate = self
        //appDelegate.mpcManager.browser.startBrowsingForPeers()
        //appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCNotification(notification:)), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }
    
    
    //Used to set up the currently playing view
    var loadedViews = false
    override func viewDidLayoutSubviews() {
        
        if loadedViews == false {
        
            currPlayingView.library = library
            currPlayingView.addAllViews()
            recentsView.setUp()
            loadedViews = true
            //currPlayingView.setNeedsDisplay() //otherwise it doesn't draw the bezier path
            //recentsView.setNeedsDisplay() //Otherwise it doesn't draw the bezier path
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
            
            
            //Change what appears based on the user's type
            if peakMusicController.playerType != .Contributor {
                
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
            
            
            //Add Play Artist
                
                alert.addAction(UIAlertAction(title: "Play Artist", style: .default, handler: {(action ) in
                    
                    if let cell: SongCell = sender.view as? SongCell {
                        
                        peakMusicController.play(artist: cell.mediaItemInCell)
                    } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                        
                        peakMusicController.play(artist: albumView.mediaItemAssocWithImage)
                    }
                    
                }))
            
            } else { //User is a contributor so display those methods
                
                alert.addAction(UIAlertAction(title: "Add to End of Queue", style: .default, handler: {(alert) in
                    
                    if let cell: SongCell = sender.view as? SongCell {
                        
                        peakMusicController.playAtEndOfQueue([cell.mediaItemInCell])
                    } else if let albumView: RecentsAlbumView = sender.view as? RecentsAlbumView {
                        
                        peakMusicController.playAtEndOfQueue([albumView.mediaItemAssocWithImage])
                    }
                    
                }))
            }
            
            
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
    
    
    /*MARK: Bluetooth PopOverView Methods*/
    @IBAction func presentBluetoothPopover() {
        //Method to show the popover
        performSegue(withIdentifier: "Popover Bluetooth Controller", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Need to implement this to handle the popover
        
        //Make sure we are doing the popover segue
        if segue.identifier == "Popover Bluetooth Controller"{
         
            let popOverVC = segue.destination
            
            let controller = popOverVC.popoverPresentationController!
            controller.delegate = self
        
            //segue.destinationViewController?.popoverPresentationController?.sourceRect = anchorView.frame
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    /*End of User interaction methods*/
    
    
    /*MARK: Notification Methods*/
    
    
    
    func enteringForeground(_ notification: NSNotification){
        
        peakMusicController.systemMusicPlayer.shuffleMode = .off
    }
    /*END OF NOTIFICATION METHODS*/
    
    /*MARK: Fetching Methods*/
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
    
    /*MARK: Table View Data Source/Delegate Methods*/
    
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
    
    
    /*MARK: PEAK MUSIC CONTROLLER DELEGATE METHODS, USED TO UPDATE VIEWS*/
    func showSignifier(){
        
        let sig = Signifier(frame: CGRect(x: view.bounds.midX - 50, y: view.bounds.midY - 50, width: 100, height: 100))
        sig.animationSetUp()
        view.addSubview(sig)
        sig.animate()
        
    }
    
    func updateDisplay() {
        
        currPlayingView.updateInfoDisplay()
    }
    
    func playerTypeDidChange(){
        
        
        //Rid everything from the currently playing system, only if the user has switched to contributed
        if peakMusicController.playerType == .Contributor {
            
            peakMusicController.systemMusicPlayer.stop()
            peakMusicController.currPlayQueue = []
        }
        
        
        
        //Update the currently playing view
        //Remove all the subviews
        for view in currPlayingView.subviews {
            
        
            view.removeFromSuperview()
        }
        
        //Add them back
        currPlayingView.addAllViews()
    }
    /*End of Peak Music Controller Delegate Methods*/
    
    
    /*GESTURE TARGET METHODS*/
    
    func handleTapOnSong(_ gesture: UITapGestureRecognizer){
        
        //first get the media item
        var mediaItemOnTap = MPMediaItem()
        
        //check to see where the gesture is coming from and respond accordingly
        if let albumArt: RecentsAlbumView = gesture.view as? RecentsAlbumView {
            
            mediaItemOnTap = albumArt.mediaItemAssocWithImage
            
        } else if let cell: SongCell = gesture.view as? SongCell {
            
            mediaItemOnTap = cell.mediaItemInCell
        }
        
        //Check to see what the playerType of the user is
        if peakMusicController.playerType != .Contributor {
                
            peakMusicController.play([mediaItemOnTap])
            
        } else {
            //the user is a contributor
        
            promptUserToSendToGroupQueue(mediaItemOnTap)
            
        }
        
    }
    
    func promptUserToSendToGroupQueue(_ song: MPMediaItem){
        //Method to ask the user if they'd like to add an item to the group queue
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(song.title ?? "this song") to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
        
            peakMusicController.playAtEndOfQueue([song])
            //self.sendSongIdToHost(id: "\(song.persistentID)") // @cam added this. may want to change
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    /*END OF GESTURE TARGET METHODS*/
    
    
    
    /************************TEST METHODS FOR BLUETOOTH******************************/
    
    func receivedGroupPlayQueue(_ songIds: [String]){
        
        var tempSongHolder = [Song]()
        for songId in songIds {
            
            ConnectingToInternet.getSong(id: songId, completion: {(song) in
            
                tempSongHolder.append(song)
            })
        }
        
        peakMusicController.groupPlayQueue = tempSongHolder
       
    }
    
    //120954025
    /*TEST OF RECEVING A SONG FROM A USER*/
    func receivedSong(_ songID: String) {
        
        //add the song to the user's library, async
        DispatchQueue.global().async {
            
            var song = MPMediaItem()
            let library = MPMediaLibrary()
            library.addItem(withProductID: songID, completionHandler: {(ent, err) in
                
                //add the entity to the queue
                song = ent[0] as! MPMediaItem  // Error with this line //Might be because the search didn't return a song //Maybe we should try checking if there was an error first? //Not going to mess with it now because I'm not sure how the error was produced
                
                DispatchQueue.main.async {
                    peakMusicController.playAtEndOfQueue([song])
                }
                
                
            })
        }
        
    }
    
    // MARK: Bluetooth Stuff
    
    func sendSongIdToHost(id: String) {
        let messageDictionary: [String: String] = ["id": id]
        
        if MPCManager.defaultMPCManager.session.connectedPeers.count > 0 {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: MPCManager.defaultMPCManager.session.connectedPeers[0] as MCPeerID) {
                
                print("Successfully send song id \(id)")
            }
            else {
                let alert = UIAlertController(title: "Could Not Send", message: "Try Again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Could Not Send", message: "You are not connected to a device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func sendSongIdsToClient(ids: [String]) {
        
        var messageDictionary: [String: String] = [:]
        
        for (index, id) in ids.enumerated() {
            messageDictionary["\(index)"] = id
        }
        
        for peers in MPCManager.defaultMPCManager.session.connectedPeers {
            if !MPCManager.defaultMPCManager.sendData(dictionaryWithData: messageDictionary, toPeer: peers as MCPeerID) {
                
                print("Sent")
            }
            else {
                print("ERROR SENDING DATA COULD HAPPEN LibraryViewController -> sendSongIdsToClient")
            }
        }
    }
    
    // MARK: Notification
    func handleMPCNotification(notification: NSNotification) {
        switch peakMusicController.playerType {
        case .Host:
            handleMPCDJRecievedSongIDWithNotification(notification: notification)
        case .Contributor:
            handleMPCClientReceivedSongIdsWithNotification(notification: notification)
        default:
            print("ERROR: THIS SHOULD NEVER HAPPEN LibraryViewController -> handleMPCNotification")
        }
    }
    
    func handleMPCDJRecievedSongIDWithNotification(notification: NSNotification) {
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        
        if let id = dataDictionary["id"] {
            print("DJ Recieved ID \(id)")
            receivedSong(id)
        }
        else {
            print("ERROR: ")
        }
    }
    
    func handleMPCClientReceivedSongIdsWithNotification(notification: NSNotification) {
        
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let data = receivedDataDictionary["data"] as? NSData
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        
        var songIDs: [String] = []
        
        var index = 0
        while (true) {
            
            if let value = dataDictionary["\(index)"] {
                songIDs.append(value)
            }
            else {
                break
            }
            
            index += 1
        }
        
        print("Recieved")
        print(dataDictionary)
        print(songIDs)
        
        // Con add yourFunction(songIDs)
    }
    
    
}
