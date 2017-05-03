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

class BeastController: UIViewController, UISearchBarDelegate, SearchBarPopOverViewViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    /*MARK: Properties*/

    //SIC Props
    @IBOutlet weak var songInteractionContainer: SicContainer!

    
    //Search Props
    @IBOutlet weak var searchForMediaBar: UISearchBar!
    
    //Library Props
    @IBOutlet weak var libraryContainerView: UIView!
    var libraryViewController: LibraryViewController?
    
    
    //Bluetooth Props
    @IBOutlet weak var connectButton: UIButton!
    
    
    /*MARK: VIEW CONTROLLER LIFECYCLE METHODS*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //Set up search bar
        searchForMediaBar.delegate = self
    }

    
    /*MARK: SEGUE STUFF*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Get the View Controllers
        if let viewController: LibraryViewController = segue.destination as? LibraryViewController{
            
            libraryViewController = viewController
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
        
        view.insertSubview(searchViewController.view, at: 2) //Insert behind the currently playing view
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
    func returnLibraryItems() -> [LibraryItem]{
        
        return (libraryViewController?.userLibrary.itemsInLibrary)!
    }
    
    
}
