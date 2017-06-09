//
//  PagesViewController.swift
//  Peak
//
//  Created by Cameron Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import StoreKit
import CloudKit
import MediaPlayer

protocol SongsLoaded {
    func songsLoaded(count: Int)
}

class PagesViewController: UIViewController, UIScrollViewDelegate, SongsLoaded {

    var horizontalScrollView: UIScrollView!
    var verticalScrollViews: [UIScrollView] = []
    
    static let halfOfSpaceBetween: CGFloat = 16
    
    static let topBarHeight: CGFloat = 58
    
    var pageIndex: Int {
        set {
            horizontalScrollView.setContentOffset(CGPoint(x: CGFloat(newValue) * horizontalScrollView.frame.width, y: 0), animated: true)
        }
        get {
            return Int(round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width))
        }
    }
    var bluetoothViewController: PopOverBluetoothViewController {
        return childViewControllers[0] as! PopOverBluetoothViewController
    }
    var libraryViewController: LibraryViewController {
        print("\(childViewControllers.count) > 1 CHILDREN")
        print(childViewControllers[1])
        return childViewControllers[1] as! LibraryViewController
    }
    var musicTypeController: MusicTypeController {
        return childViewControllers[2] as! MusicTypeController
    }
    var viewController: UIViewController {
        return childViewControllers[pageIndex]
    }
    
    var bluetoothHeight: CGFloat {
        return self.view.frame.height - 58
    }
    var libraryHeight: CGFloat {
        
        var rowHeight: CGFloat = 75
        if libraryViewController.library.visibleCells.count > 0 {
            rowHeight = libraryViewController.library.visibleCells[0].frame.height
        }
        
        print("ROW HEIGHT: \(rowHeight)")
        print("COUNT: \(itemsCount)")
        
        return max(self.view.frame.height, CGFloat(CGFloat(itemsCount) * rowHeight + 175))
    }
    
    var itemsCount = 0
    
    var alreadyLoaded = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(libraryUpdated(notification:)), name: Notification.Name.systemMusicPlayerLibraryChanged, object: nil)
        
        // Do any additional setup after loading the view.
        //setUpScrollView()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(libraryUpdated(notiication:)), name: Notification.Name.systemMusicPlayerLibraryChanged, object: nil)
        
        
        switch peakMusicController.musicType {
        case .AppleMusic:
            checkAppleAuthentication()
        case .Spotify:
            loginWithSpotify()
        default:
            peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
            setUpScrollView()
        }
        
        //setUpScrollView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkAppleAuthentication() {
    
        //loadingIndicator.startAnimating()
        //check if we have authorization to the user's apple music
        
        let serviceController = SKCloudServiceController()
        /***************TEST CHECK FOR APPLE MUSIC*****************/
        
        //let's check if we can take them to get a subscription
        serviceController.requestCapabilities(completionHandler: {(capability: SKCloudServiceCapability, err: Error?) in
            
            if capability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible){
                
                //self.loadingIndicator.stopAnimating()
                
                //They're eligible for a subscription so let's take them to get one
                
                let url = URL.init(string: "https://itunes.apple.com/subscribe?app=music&at=1000l4QJ&ct=14&itscg=1002")
                UIApplication.shared.open(url!, options: [:], completionHandler: {
                    (foo) -> Void in
                    
                    print(foo)
                })
                
            } else if capability.contains(SKCloudServiceCapability.addToCloudMusicLibrary){
                
                DispatchQueue.main.async {
                    
                    //self.loadingIndicator.stopAnimating()
                }
                
                
                //We're all set to go lets see if we can segue
                
                if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
                    
                    DispatchQueue.main.async {
                        //self.loadingIndicator.stopAnimating()
                    }
                    
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            
                            peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
                            self.setUpScrollView()
                            //self.performSegue(withIdentifier: "Segue to Apple Music", sender: nil)
                        }
                    }
                }
    
    
            } else if capability.contains(SKCloudServiceCapability.musicCatalogPlayback){
                
                //self.loadingIndicator.stopAnimating()
                
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
                
                //self.loadingIndicator.stopAnimating()
                
                //We are yet to get access from the user
                SKCloudServiceController.requestAuthorization({(authorization) in
                    
                    switch authorization{
                        
                    case .authorized:
                        self.checkAppleAuthentication()
                        
                    case .denied:
                        //self.instructUserToAllowUsToAppleMusic()
                        break
                    default:
                        print("Shouldn't be here")
                    }
                    
                })
                
            }
            
            
        })
        
    }
    
    func loginWithSpotify() {
        
        
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
    
    func spottyLoginWasSuccess(){
        
        self.performSegue(withIdentifier: "Segue To Spotify", sender: nil)
    }
    
    func startAuthenticationFlow(){
        
        if auth?.session != nil{
            
            (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).login(withAccessToken: auth?.session.accessToken)
            
            
        } else{
            
            let authURL = auth?.spotifyWebAuthenticationURL()
            
            setUpScrollView()
            //authViewController = SFSafariViewController(url: authURL!)
            //appDelegate.window?.rootViewController?.present(authViewController!, animated: true, completion: nil)
        }
    }
    
    // Private Functions
    
    private func pageSize(at index: Int) -> CGFloat {
        switch index {
        case 0:
            return bluetoothHeight
        case 1:
            return libraryHeight
        default:
            return self.view.frame.height
        }

    }
    
    private func setUpScrollView() {
        
        print("PagesViewController setUpScrollView START")
        
        self.view.backgroundColor = UIColor.green
        
        horizontalScrollView = UIScrollView(frame: CGRect(x: -PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: self.view.frame.height))
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.delegate = self
        
        let bluetoothVc = storyboard?.instantiateViewController(withIdentifier: "bluetoothVcID") as! PopOverBluetoothViewController
        
        let middleVc = storyboard?.instantiateViewController(withIdentifier: "mainMiddleVcID") as! LibraryViewController
        middleVc.delegate = parent as? BeastController
        middleVc.libraryUpdatedDelegate = self
        
        for (index, vc) in [bluetoothVc, middleVc].enumerated() {
            
            let newVerticalScrollView = UIScrollView(frame: CGRect(x: CGFloat(index) * horizontalScrollView.frame.width + PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newVerticalScrollView.alwaysBounceVertical = true
            
            self.addChildViewController(vc)
            newVerticalScrollView.addSubview(vc.view)
            horizontalScrollView.addSubview(newVerticalScrollView)
            verticalScrollViews.append(newVerticalScrollView)
            vc.didMove(toParentViewController: self)
            
            vc.view.layer.cornerRadius = 25
            
            newVerticalScrollView.contentSize = CGSize(width: newVerticalScrollView.frame.width, height: pageSize(at: index))
            vc.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: index))
        }
        
        let musicTypeVC = storyboard?.instantiateViewController(withIdentifier: "musicTypePlayerID") as! MusicTypeController
        addChildViewController(musicTypeVC)
        //verticalScrollViews[1].addSubview(musicTypeVC.view)
        musicTypeVC.didMove(toParentViewController: self)
        musicTypeVC.view.layer.masksToBounds = true
        musicTypeVC.view.layer.cornerRadius = 25
        musicTypeVC.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: bluetoothHeight)
        //musicTypeVC.view.removeFromSuperview()
        
        horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.width * 2, height: horizontalScrollView.frame.height)
        horizontalScrollView.contentOffset = CGPoint(x: horizontalScrollView.frame.width, y: 0)
        
        self.view.addSubview(horizontalScrollView)
        
        print("PagesViewController setUpScrollView END")
    }
 
    
    func songsLoaded(count: Int) {
        
        if alreadyLoaded || count <= 2 {
            return
        }
        
        alreadyLoaded = true
        
        itemsCount = count
        
        for vc in childViewControllers {
            vc.didMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        for view in verticalScrollViews {
            view.removeFromSuperview()
        }
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        
        setUpScrollView()
    }
    
    func flipMiddlePageToBack() {
        
        UIView.transition(with: verticalScrollViews[1], duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
            
            self.verticalScrollViews[1].addSubview(self.musicTypeController.view)
            self.libraryViewController.view.removeFromSuperview()
            
        }, completion: { (Bool) -> Void in
            
        })
    }

    func flipMiddlePageToFront() {
        
        UIView.transition(with: verticalScrollViews[1], duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
            
            self.verticalScrollViews[1].addSubview(self.libraryViewController.view)
            self.musicTypeController.view.removeFromSuperview()
            
        }, completion: { (Bool) -> Void in
            
        })
    }
}
