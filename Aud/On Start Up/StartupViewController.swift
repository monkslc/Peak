//
//  StartupViewController.swift
//  Aud
//
//  Created by Cameron Monks on 6/10/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//
import UIKit
import StoreKit
import CloudKit
import MediaPlayer

//Spotify Authentication tools
let auth = SPTAuth.defaultInstance()
var authViewController: SFSafariViewController?

class StartupViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet var welcomeLabel: UILabel!
    
    //var dateStarted: Date!
    //var timeNeeded: TimeInterval = 1.0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeLabel.text = "Welcome \(getUserName())"
        
        makePeakGlow()
        
        peakMusicController.systemMusicPlayer = GuestMusicController()
        
        //dateStarted = Date()
        
        switch peakMusicController.musicType {
        case .AppleMusic:
            print("LOGIN IN AS APPLE MUSIC")
            loginAsAppleMusic()
        case.Spotify:
            print("LOG IN AS SPOTIFY")
            loginWithSpotify()
        default:
            print("LOG IN AS GUEST")
            loginAsGuest()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func makePeakGlow() {
        addGradientMaskToView(view: welcomeLabel, gradientWidth: 30)
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
    
    func loginAsAppleMusic() {
        
        Authentication.AutheticateWithApple(){ errorAlert in
            
            if errorAlert != nil{
                
                self.present(errorAlert!, animated: true, completion: nil)
                return
            }
            
            peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
            self.moveToBeastController()
        }
    }
    
    func loginAsGuest() {
        
        self.moveToBeastController()
    }
    
    
    
    
    /*MARK: SPOTIFY SIGN IN METHOD*/
    func loginWithSpotify() {
        
        //Add the listener for spotify authentication
        NotificationCenter.default.addObserver(self, selector: #selector(spottyLoginWasSuccess), name: .spotifyLoginSuccessful, object: nil)
        
        Authentication.AuthenticateWithSpotify(safariViewControllerDelegate: self)
    }
    
    //Login with spotify was successful so we can segue
    @objc func spottyLoginWasSuccess(){
        
        moveToBeastController()
    }
    
    
    // private functions
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = segue.destination
    }
     
 
    
    // Notifications
    
    func handleApplicationDidBecomeActive(notification: NSNotification) {
        makePeakGlow()
    }
    
    func moveToBeastController() {
        
        self.performSegue(withIdentifier: "Segue To Beast", sender: nil)
    }
    
    
/*MARK: SAFARI VIEW CONTROLLER METHODS*/
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        let alert = UIAlertController(title: "Failed to authenticate with Spotify", message: "We will now sign you in as a Guest", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default){ alert in
            
            peakMusicController.systemMusicPlayer = GuestMusicController()
            self.loginAsGuest()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
