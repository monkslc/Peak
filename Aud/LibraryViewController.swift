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

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,PeakMusicControllerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, SearchBarPopOverViewViewControllerDelegate, ScrollBarDelegate{
    

    //view that displays currently playing options
    @IBOutlet weak var currPlayingView: CurrentlyPlayingView!
    
    @IBOutlet weak var library: UITableView!
    
    //Data for the library
    var mediaItemsInLibrary = [MPMediaItem]() {
        
        didSet{

            library.reloadData()
        }
    }
    
    //holds the recents in case we decide to shuffle them
    var recentSongsDownloaded = [MPMediaItem]()
    
    @IBOutlet weak var recentsView: RecentlyAddedView!
    
    //Search Bar in header view
    @IBOutlet weak var searchForMediaBar: UISearchBar!
    
    //Bluetooth connectivity button in header
    @IBOutlet weak var connectButton: UIButton!
    
    //View that controls the scroll bar
    @IBOutlet weak var scrollBar: ScrollBar!
    @IBOutlet weak var scrollPresenter: ScrollPresenterView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //First thing we want to do is start the fetch the user's library
        DispatchQueue.global().async {
            self.fetchLibrary()
        }
        
        
        //Now set up the music controller
        peakMusicController.delegate = self
        peakMusicController.setUp()
        
        //set up the search bar
        searchForMediaBar.delegate = self
        
        //set up the scroll bar
        scrollBar.delegate = self
        scrollBar.setUp()
        scrollPresenter.setUp()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        
        //Detect LIbrary changes
        NotificationCenter.default.addObserver(self, selector: #selector(libraryChanged(_:)), name: .MPMediaLibraryDidChange, object: MPMediaLibrary.default())
        MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()

        // Bluetooth
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
        }
        
        
        //Set the albumView
        if peakMusicController.systemMusicPlayer.nowPlayingItem?.artwork != nil {
            
             currPlayingView.albumView.image = peakMusicController.systemMusicPlayer.nowPlayingItem?.artwork?.image(at: CGSize())
        }
       
    }
    
    
    /*MARK: User Interaction Methods*/
    
    @IBAction func displaySongOptions(_ sender: UILongPressGestureRecognizer) {
        //Used to pop up alert view for more song options
        
        if sender.state == .began {
            
            //alert the options for the song here
            let alert = UIAlertController(title: "Song Options", message: nil, preferredStyle: .actionSheet)
            
            
            //Change what appears based on the user's type
            if peakMusicController.playerType != .Contributor {
                
                alert.addAction(Alerts.playNowAlert(sender))
                alert.addAction(Alerts.playNextAlert(sender))
                alert.addAction(Alerts.playLastAlert(sender))
                alert.addAction(Alerts.playAlbumAlert(sender))
                alert.addAction(Alerts.playArtistAlert(sender))
                alert.addAction(Alerts.shuffleAlert(sender, library: mediaItemsInLibrary, recents: recentSongsDownloaded))
            
            } else { //User is a contributor so display those methods
                
                alert.addAction(Alerts.sendToGroupQueueAlert(sender))
            }
            
            
            //Add a cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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
        } else if segue.identifier == "Show Search Options" {
            
            //We are showing search options
            //remark
            let popOverVC = segue.destination as! SearchBarPopOverViewViewController
            popOverVC.delegate = self
            searchForMediaBar.delegate = popOverVC
            
            //Set the bounds for the popOverVc
            popOverVC.preferredContentSize = CGSize(width: view.bounds.width, height: 300)
            
            let controller = popOverVC.popoverPresentationController!
            controller.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    /*End of User interaction methods*/
    
    
    /*MARK: Notification Methods*/
    
    func libraryChanged(_ notification: NSNotification){
        
        fetchLibrary()
    }
    
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
        
        //First Remove All Subviews
        for sub in recentsView.subviews {
            
            sub.removeFromSuperview()
        }
        
        //First Add The Subview
        let reView = UIView(frame: CGRect(x: 0, y: 0, width: (recents.count * 100), height: Int(recentsView.frame.height)))
        recentsView.contentSize = CGSize(width: reView.frame.width, height: reView.frame.height)
        recentsView.addSubview(reView)
        
        //Loop through and add each recent
        var counter = 0
        for song in recents {
            
            //add the song to the recents
            recentSongsDownloaded.append(song)
            
            //Create the AlbumView
            let albumImage = RecentsAlbumView(frame: CGRect(x: CGFloat(Double(counter * 100) + 12.5), y: 0, width: 75, height: 75))
            albumImage.setUp(song)
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
        
        //Stop the cell from showing...
        cell.addToLibraryButton.isHidden = true
        cell.songDurationLabel.isHidden = true
        
        return cell
        
    }

   
    
    /*End of Table View Data Source/Delegate Methods*/
    
    /*MARK: SearchBarPopOver Delegate Methods*/
    func returnLibrary() -> [MPMediaItem]{
        
        return mediaItemsInLibrary
    }
    
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
        DispatchQueue.main.async {
            self.currPlayingView.addAllViews()
        }
    }
    /*End of Peak Music Controller Delegate Methods*/
    
    /*MARK: Scroll Bar Delegate Methods*/
    func scrolling(_ yLoc: CGFloat,_ state: UIGestureRecognizerState) {
        
        //Get the index of the cell we want to scroll to
        var indexToScrollTo = floor(yLoc / (scrollBar.frame.height / CGFloat(mediaItemsInLibrary.count + 2))) //add two because we did that for num of rows
        
        //Make sure our index path is in range
        if indexToScrollTo >= 0 && indexToScrollTo < CGFloat(mediaItemsInLibrary.count){
            
            //library.scrollToRow(at: IndexPath(row: Int(indexToScrollTo), section: 0), at: .top, animated: false)
            scrollPresenter.positionOfLabel = yLoc
            scrollPresenter.displayLabel.text = mediaItemsInLibrary[Int(indexToScrollTo)].artist
        }
        
        //Now update the label
        
        if state == .began{
            
            scrollPresenter.displayLabelView.isHidden = false
        } else if state == .ended{
            
            //Get the cell index we want to scroll to
            if indexToScrollTo < 0{
                indexToScrollTo = 0
            } else if indexToScrollTo > CGFloat(mediaItemsInLibrary.count){
                
                indexToScrollTo = CGFloat(mediaItemsInLibrary.count)
            }
            
            library.scrollToRow(at: IndexPath(row: Int(indexToScrollTo), section: 0), at: .top, animated: false)
            scrollPresenter.displayLabelView.isHidden = true
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Check if the header view is visible
        if scrollView.contentOffset.y < (library.tableHeaderView?.frame.height)! {
            //it's showing
            
            //scrollBar.shouldShow = false
            scrollBar.isHidden = true
        }else {
            //it's not
            
            //scrollBar.shouldShow = true
            scrollBar.isHidden = false
        }
        
        //Get the top cell and its position
        let topCell = library.visibleCells[0]
        let pos = library.indexPath(for: topCell)?.row
        
        //Now set the scroll bar's position
        scrollBar.position = CGFloat(pos!) * (scrollBar.frame.height / CGFloat(mediaItemsInLibrary.count))
    }
    
    /*GESTURE TARGET METHODS*/
    
    func handleTapOnSong(_ gesture: UITapGestureRecognizer) {
        
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
    
    func promptUserToSendToGroupQueue(_ song: MPMediaItem) {
        //Method to ask the user if they'd like to add an item to the group queue
        
        let alert = UIAlertController(title: "Group Queue", message: "Would you like to add \(song.title ?? "this song") to the group queue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert) in
        
            //peakMusicController.playAtEndOfQueue([song])
            SendingBluetooth.sendSongIdToHost(id: "\(song.playbackStoreID)", error: {
                () -> Void in
                
                let alert = UIAlertController(title: "Error", message: "Could not send", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }) // @cam added this. may want to change
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    /*END OF GESTURE TARGET METHODS*/
    
    /*SEARCH BAR DELEGATE METHODS*/
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //When the textfield begins editing, we want to display our other view
        
        //Create the search view controller
        let searchViewController = storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchBarPopOverViewViewController
        addChildViewController(searchViewController)
        
        //set the frame
        //frame with rounded
        //searchViewController.view.frame = CGRect(x: library.frame.minX, y: library.frame.minY, width: library.frame.width, height: library.frame.height - 140) //140 because that's the height of the currently playing view
        searchViewController.view.frame = library.frame
    
        
        //Create the shape layer
        //let viewOutline = CAShapeLayer()
        
        //let rect = CGRect(x: 0, y: 0, width: library.frame.width, height: searchViewController.view.frame.height)
        //let pathForOutline = UIBezierPath(roundedRect:  rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 30, height: 30))
        //viewOutline.path = pathForOutline.cgPath
        
        //searchViewController.view.layer.mask = viewOutline
        //searchViewController.view.layer.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0).cgColor
        
        
        
        view.insertSubview(searchViewController.view, at: 2) //Insert behind the currently playing view
        searchViewController.didMove(toParentViewController: self)
        
        //set up the delegates
        searchViewController.delegate = self
        searchBar.delegate = searchViewController
        searchBar.showsCancelButton = true
        
        
    }
    
    
    /************************TEST METHODS FOR BLUETOOTH******************************/
    
    func receivedGroupPlayQueue(_ songIds: [String]) {
        
        var tempSongHolder = [Song?].init(repeating: nil, count: songIds.count)
        for i in 0..<songIds.count {
            
            ConnectingToInternet.getSong(id: songIds[i], completion: {(song) in
                tempSongHolder[i] = song
                
                if let songs = tempSongHolder as? [Song] {
                    
                    DispatchQueue.main.async {
                        peakMusicController.groupPlayQueue = songs
                    }
                }
            })
        }
       
    }
    
    /*TEST OF RECEVING A SONG FROM A USER*/
    func receivedSong(_ songID: String) {
        
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
        
        receivedGroupPlayQueue(songIDs)
    }
    
}
