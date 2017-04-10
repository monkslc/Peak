//  AuthViewController.swift
//  Peak
//
//  Created by Connor Monks on 3/18/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import StoreKit
import CloudKit

class AuthViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var welcomeToLabel: UILabel!
    
    @IBOutlet weak var appleMusicButton: RoundedButton!
    
    @IBOutlet weak var ConnectToAppleMusicLabel: UILabel!
    
    @IBOutlet weak var guestButton: RoundedButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allow the label to properly display connect to apple music button
        //ConnectToAppleMusicLabel.adjustsFontSizeToFitWidth = true
        //ConnectToAppleMusicLabel.baselineAdjustment = .alignCenters
        
        welcomeToLabel.text = "\(getUserName()), how would you like to connect?"
        welcomeToLabel.adjustsFontSizeToFitWidth = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppleMusicForceTouchNotification(notification:)), name: NSNotification.Name(rawValue: "receivedAppleMusicForceTouchNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDjForceTouchNotification(notification:)), name: NSNotification.Name(rawValue: "receivedDjForceTouchNotification"), object: nil)
    }

    
    @IBAction func checkAppleAuthentication() {
        
        loadingIndicator.startAnimating()
        //check if we have authorization to the user's apple music
    
        let serviceController = SKCloudServiceController()
        /***************TEST CHECK FOR APPLE MUSIC*****************/
        
        
        //let's check if we can take them to get a subscription
        serviceController.requestCapabilities(completionHandler: {(capability: SKCloudServiceCapability, err: Error?) in
        
            if capability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible){
                
                self.loadingIndicator.stopAnimating()
                
                //They're eligible for a subscription so let's take them to get one
                
                let url = URL.init(string: "https://itunes.apple.com/subscribe?app=music&at=1000l4QJ&ct=14&itscg=1002")
                UIApplication.shared.open(url!, options: [:], completionHandler: {
                    (foo) -> Void in
                    
                    print(foo)
                })
                
            } else if capability.contains(SKCloudServiceCapability.addToCloudMusicLibrary){
                
                self.loadingIndicator.stopAnimating()
                
                //We're all set to go lets see if we can segue
                
                if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
                    
                    self.loadingIndicator.stopAnimating()
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            
                            self.performSegue(withIdentifier: "Segue to Apple Music", sender: nil)
                        }
                    }
                }
                

            } else if capability.contains(SKCloudServiceCapability.musicCatalogPlayback){
                
                self.loadingIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "Apple Music", message: "Is Apple Music Downloaded?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                
                    //prompt the user to change their settings
                    let subLert = UIAlertController(title: nil, message: "Head to Settings > Music > Switch on iCloud Music Library", preferredStyle: .alert)
                    subLert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(subLert, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No, take me there.", style: .default, handler: {(aciton) in
                    
                    let url = URL.init(string: "https://itunes.apple.com/subscribe?app=music&at=1000l4QJ&ct=14&itscg=1002")
                    UIApplication.shared.open(url!, options: [:], completionHandler: {
                        (foo) -> Void in
                        
                        print(foo)
                    })
                    
                }))
                
                
                
                self.present(alert, animated: true, completion: nil)
                //Downloaded but no iCloud selected
                
                //App was not downloaded
                
            } else {
                
                self.loadingIndicator.stopAnimating()
                
                //We are yet to get access from the user
                SKCloudServiceController.requestAuthorization({(authorization) in
                    
                    switch authorization{
                        
                    case .authorized:
                        self.checkAppleAuthentication()
                        
                    case .denied:
                        self.instructUserToAllowUsToAppleMusic()
                        
                    default:
                        print("Shouldn't be here")
                    }
                    
                })
                
            }
            
        
        })
        
    }
    
    @IBAction func guestButtonClicked() {
        self.performSegue(withIdentifier: "Segue as Guest", sender: nil)
    }
    
    //Let the user know how to give us access to apple music
    func instructUserToAllowUsToAppleMusic() {
        
        
        let alert = UIAlertController(title: "Head to settings > Privacy > Media & Apple Music and allow Peak to access Media & Apple Music.", message: nil,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        self.loadingIndicator.stopAnimating()
    }
    
    //let the user know their access to apple music is restricted
    func alertRestrictedAccess() {
        
        let alert = UIAlertController(title: "Access to Apple Music is restricted.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:
            .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        self.loadingIndicator.stopAnimating()
    }
    
    // used to get the name of the user
    private func getUserName() -> String {
        var name = UIDevice.current.name
        
        let possibleThingsToCutOff: [String] = [" iphone", "'", "’"]
        
        for p in possibleThingsToCutOff {
            if name.lowercased().contains(p) {
                let index = name.lowercased().indexOf(target: p)
                name = name.subString(toIndex: index)
            }
        }
    
        return name
    }
    
    // Handle Notification For Force Touché
    func handleAppleMusicForceTouchNotification(notification: NSNotification) {
        checkAppleAuthentication()
    }
    
    func handleDjForceTouchNotification(notification: NSNotification) {
        //DispatchQueue.main.sync {
            self.guestButtonClicked()
        //}
    }
    
    //Check how we are segueing so we can se tthe music player to the appropriate type
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Segue to Apple Music" {
            
            peakMusicController.musicType = .AppleMusic
            
        } else if segue.identifier == "Segue as Guest" {
        
            peakMusicController.musicType = .Guest
        }
    }
}
