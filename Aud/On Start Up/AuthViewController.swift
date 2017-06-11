//  AuthViewController.swift
//  Peak
//
//  Created by Connor Monks on 3/18/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import StoreKit
import CloudKit
import MediaPlayer

//Spotify Authentication tools
//let auth = SPTAuth.defaultInstance()
//var authViewController: SFSafariViewController?

class AuthViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var welcomeToLabel: UILabel!
    
    @IBOutlet var peakLabel: UILabel!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppleSpotifyForceTouchNotification(notification:)), name: NSNotification.Name(rawValue: "receivedSpotifyMusicForceTouchNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDjForceTouchNotification(notification:)), name: NSNotification.Name(rawValue: "receivedDjForceTouchNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive(notification:)), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
        
        makePeakGlow()
    }
    
    
    private func makePeakGlow() {
        addGradientMaskToView(view: peakLabel, gradientWidth: 30)
    }
    
    fileprivate func addGradientMaskToView(view:UIView, transparency:CGFloat = 0.5, gradientWidth:CGFloat = 40.0) {
        let gradientMask = CAGradientLayer()
        gradientMask.frame = view.bounds
        let gradientSize = gradientWidth/view.frame.size.width
        let gradientColor = UIColor(white: 1, alpha: transparency)
        //let gradientColor = UIColor(colorLiteralRed: 0.6, green: 0.2, blue: 0.2, alpha: Float(transparency))
        let startLocations = [0, gradientSize/2, gradientSize]
        let endLocations = [(1 - gradientSize), (1 - gradientSize/2), 1]
        let animation = CABasicAnimation(keyPath: "locations")
        
        gradientMask.colors = [gradientColor.cgColor, UIColor.white.cgColor, gradientColor.cgColor]
        gradientMask.locations = startLocations as [NSNumber]?
        gradientMask.startPoint = CGPoint(x:0 - (gradientSize * 2) - 0.1, y: 0.5)
        gradientMask.endPoint = CGPoint(x:1 + gradientSize + 0.1, y: 0.5)
        
        view.layer.mask = gradientMask
        
        animation.fromValue = startLocations
        animation.toValue = endLocations
        animation.repeatCount = HUGE
        animation.duration = 4
        
        gradientMask.add(animation, forKey: nil)
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
                
                DispatchQueue.main.async {
                    
                    self.loadingIndicator.stopAnimating()
                }
                
                
                //We're all set to go lets see if we can segue
                
                if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                    }
                    
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            
                            peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
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
                    
                    switch authorization {
                        
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
    
    
    
    
    /*MARK: SPOTIFY SIGN IN METHOD*/
    
    //get the app delegate for spotify
    //Get the app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func loginWithSpotify() {
        
        
        //start up the player so we can get the authentication access
        peakMusicController.systemMusicPlayer = SPTAudioStreamingController.sharedInstance()
        
        //Create the delegate for this
        (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).delegate = appDelegate
        
        
        //Add the listener for the callback
        NotificationCenter.default.addObserver(self, selector: #selector(spottyLoginWasSuccess), name: .spotifyLoginSuccessful, object: nil)
        
        
        
        
        //Check if we can login
        auth?.clientID = "7b3c389c57ee44ce8f3562013df963ec"
        auth?.redirectURL = URL(string: "peak-music-spotty-login://callback")
        
        
        auth?.sessionUserDefaultsKey = "current session"
        
        auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserLibraryReadScope, SPTAuthUserReadTopScope, SPTAuthUserReadPrivateScope, SPTAuthUserLibraryModifyScope]
        
        (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).delegate = appDelegate
        
        do{
            
            //Maybe Here
            try (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).start(withClientId: auth?.clientID)
        } catch{
            
            print("\n\nHad a fucking error\n\n")
        }
        
        DispatchQueue.global().async {
            
            DispatchQueue.main.async {
                
                self.startAuthenticationFlow()
            }
        }
    }
    
    //AUthentication flow method
    func startAuthenticationFlow(){
        
        if auth?.session != nil{
            
            (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).login(withAccessToken: auth?.session.accessToken)
            
            
        } else{
            
            let authURL = auth?.spotifyWebAuthenticationURL()
            
            authViewController = SFSafariViewController(url: authURL!)
            appDelegate.window?.rootViewController?.present(authViewController!, animated: true, completion: nil)
        }
    }
    
    
    //Login with spotify was successful so we can segue
    func spottyLoginWasSuccess(){
        
        print("\n\n\nIt's not getting called here is it?\n\n")
        self.performSegue(withIdentifier: "Segue To Spotify", sender: nil)
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
        
        //Do we really need iPhone here
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
    
    func handleAppleSpotifyForceTouchNotification(notification: NSNotification) {
        loginWithSpotify()
    }
    
    func handleDjForceTouchNotification(notification: NSNotification) {
        //DispatchQueue.main.sync {
            self.guestButtonClicked()
        //}
    }
    
    func handleApplicationDidBecomeActive(notification: NSNotification) {
        makePeakGlow()
    }
    
    //Check how we are segueing so we can se tthe music player to the appropriate type
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "Segue to Apple Music" {
            
            peakMusicController.musicType = .AppleMusic
            
        } else if segue.identifier == "Segue as Guest" {
        
            peakMusicController.systemMusicPlayer = GuestMusicController()
            peakMusicController.musicType = .Guest
            
        } else if segue.identifier == "Segue To Spotify"{
        
            peakMusicController.musicType = .Spotify
        }
        
        
    }
}
