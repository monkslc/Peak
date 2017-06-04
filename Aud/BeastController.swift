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

class BeastController: UIViewController,SearchBarPopOverViewViewControllerDelegate, UIPopoverPresentationControllerDelegate, PeakMusicControllerDelegate, LibraryViewControllerDelegate, BluetoohtHandlerDelegate, UITextFieldDelegate {

    /*MARK: Properties*/

    //SIC Props
    @IBOutlet weak var songInteractionContainer: SicContainer!

    
    //Search Props
    @IBOutlet weak var mediaSearchBar: UITextField!
    @IBOutlet weak var mediaSearchBackdrop: UIView!
    @IBOutlet weak var cancelSearch: UIButton!
    
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
        mediaSearchBar.delegate = self
    
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
    
    
    /*MARK: TEXT FIELD DELEGATE METHODS*/
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Create the search view controller
        
        let searchViewController = storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchBarPopOverViewViewController
        addChildViewController(searchViewController)
        
        //Set the frame for the view controller
        
        let heightOfSearchBarFrame = self.view.frame.height - 50
        
        
        //Create a pre animation view
        searchViewController.view.frame = CGRect(x: self.view.frame.minX, y: 50, width: self.view.frame.width, height: 0)
        
        //Insert the view
        view.insertSubview(searchViewController.view, at: 1) //Insert behind the SIC
        searchViewController.didMove(toParentViewController: self)


        UIView.animate(withDuration: 0.5, animations: {
        
            searchViewController.view.frame = CGRect(x: self.view.frame.minX, y: 50, width: self.view.frame.width, height: heightOfSearchBarFrame)
        }, completion: {(finished) in
            
            //add me blur
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            self.view.insertSubview(blurEffectView, belowSubview: searchViewController.view)
        })
        
        
        //Change the color of our mediaSearch Backdrop
        mediaSearchBackdrop.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 0.90)
        
        //Now set up our delegates
        searchViewController.delegate = self
        textField.delegate = searchViewController
        
        //Add the textField Observer
        mediaSearchBar.addTarget(searchViewController, action: #selector(searchViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        mediaSearchBar.text = nil
        
        //Set up the cancel search bar
        cancelSearch.isHidden = false
        cancelSearch.addTarget(searchViewController, action: #selector(searchViewController.resignSearchField), for: .touchUpInside)
        
        
        

  
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
            DispatchQueue.main.async {
                self.connectButton.setImage(#imageLiteral(resourceName: "Host-Icon"), for: .normal)
            }
            
            
        case .Individual:
            DispatchQueue.main.async {
                self.connectButton.setImage(#imageLiteral(resourceName: "IndieBigIcon"), for: .normal)
            }
            
            
        case .Contributor:
            DispatchQueue.main.async {
                self.connectButton.setImage(#imageLiteral(resourceName: "CommIconBig"), for: .normal)
            }
            
        }
    }
    
    
}
