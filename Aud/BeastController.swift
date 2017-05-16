//
//  BeastController.swift
//  Peak
//
//  Created by Connor Monks on 5/1/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

let peakMusicController = PeakMusicController()

class BeastController: UIViewController, UISearchBarDelegate, SearchBarPopOverViewViewControllerDelegate, UIPopoverPresentationControllerDelegate, PeakMusicControllerDelegate, LibraryViewControllerDelegate, BluetoohtHandlerDelegate {

    /*MARK: Properties*/

    //SIC Props
    @IBOutlet weak var songInteractionContainer: SicContainer!

    
    //Search Props
    @IBOutlet weak var searchForMediaBar: UISearchBar!
    
    //Library Props
    @IBOutlet weak var libraryContainerView: UIView!
    var libraryViewController: LibraryViewController?
    
    @IBOutlet weak var scrollPresenter: ScrollPresenterView!
    
    //Bluetooth Props
    @IBOutlet weak var connectButton: UIButton!
    let bluetoothHandler = BluetoothHandler()
    
    
    /*MARK: VIEW CONTROLLER LIFECYCLE METHODS*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //Set up search bar
        searchForMediaBar.delegate = self
        
        //Set up the Peak Music Controller
        peakMusicController.delegate = self
        peakMusicController.setUp()
        
        //Set up bluetooth handler
        bluetoothHandler.delegate = self
        
        //Add the listener for player type
        NotificationCenter.default.addObserver(self, selector: #selector(playerTypeDidChange), name: .playerTypeChanged, object: nil)
        
        //Set up the scroll presenter
        scrollPresenter.setUp()
    }

    
    /*MARK: SEGUE STUFF*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Get the View Controllers
        if let viewController: LibraryViewController = segue.destination as? LibraryViewController{
            
            libraryViewController = viewController
            libraryViewController?.delegate = self
    
        
        } else if let _: SongInteractionController = segue.destination as? SongInteractionController{
            
            //In case we need to do anything with the song interaction controller
        }
        
        //Check if we are presenting the bluetooth popover
        if segue.identifier == "Popover Bluetooth Controller"{
            
            let popOverVC = segue.destination
            
            let controller = popOverVC.popoverPresentationController!
            controller.delegate = self
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    /*MARK: SEARCH BAR Delegate METHODS*/
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //When the user starts editing we want to display the search bar
        
        //Create the search View Controller
        let searchViewController = storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchBarPopOverViewViewController
        addChildViewController(searchViewController)
        
        //Set the frame for the view controller in a position so it can be animated
        searchViewController.view.frame = CGRect(x: libraryContainerView.frame.minX, y: libraryContainerView.frame.minY - libraryContainerView.frame.height, width: libraryContainerView.frame.width, height: libraryContainerView.frame.height)
        
        view.insertSubview(searchViewController.view, at: 1) //Insert behind the currently playing view
        searchViewController.didMove(toParentViewController: self)
        
        //Now animate the view into place
        UIView.animate(withDuration: 0.35){(animate) in
            
            searchViewController.view.frame = self.libraryContainerView.frame
        }
        
        //set up the delegates
        searchViewController.delegate = self
        searchBar.delegate = searchViewController
        searchBar.showsCancelButton = true
    }
    
    
    /*MARK: SearchBarPopOver Delegate Methods*/
    func returnLibraryItems() -> [BasicSong]{
        
        return (libraryViewController?.userLibrary.itemsInLibrary)!
    }
    
    
    /*MARK: Peak Music Controller Delegate Methods*/
    func showSignifier() {
        
        let sig = Signifier(frame: CGRect(x: view.bounds.midX - 50, y: view.bounds.midY - 50, width: 100, height: 100))
        sig.animationSetUp()
        view.addSubview(sig)
        sig.animate()
    }
    
    /*MARK: Listener Methods*/
    func playerTypeDidChange() {
        
        switch peakMusicController.playerType{
            
        case .Host:
            connectButton.setImage(#imageLiteral(resourceName: "Host-Icon"), for: .normal)
            
        case .Individual:
            connectButton.setImage(#imageLiteral(resourceName: "IndieBigIcon"), for: .normal)
            
        case .Contributor:
            connectButton.setImage(#imageLiteral(resourceName: "CommIconBig"), for: .normal)
        }
    }
    
    
}
