//
//  Authentication.swift
//  Aud
//
//  Created by Connor Monks on 6/10/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import CloudKit
import MediaPlayer
import StoreKit

class Authentication{
    
/*MARK: AUTHENTICATION METHODS*/
    static func AutheticateWithApple(completion: @escaping (UIAlertController?) -> Void){
        
        
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
                
                //We're all set to go lets see if we can go
                if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
                    
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
                
                
            } else if capability.contains(SKCloudServiceCapability.musicCatalogPlayback){
                
                let alert = UIAlertController(title: "Apple Music", message: "Is Apple Music Downloaded?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                    
                    //prompt the user to change their settings
                    let subLert = UIAlertController(title: nil, message: "Head to Settings > Music > Switch on iCloud Music Library", preferredStyle: .alert)
                    subLert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    alert.parent?.present(subLert, animated: true, completion: nil)
                   // self.present(subLert, animated: true, completion: nil)
                    //Completion Here
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No, take me there.", style: .default, handler: {(aciton) in
                    
                    let url = URL.init(string: "https://itunes.apple.com/subscribe?app=music&at=1000l4QJ&ct=14&itscg=1002")
                    UIApplication.shared.open(url!, options: [:], completionHandler: {
                        (foo) -> Void in
                        
                        print(foo)
                    })
                    
                }))
                
                
                completion(alert)
                
            } else {
                
                //We are yet to get access from the user
                SKCloudServiceController.requestAuthorization({(authorization) in
                    
                    switch authorization {
                        
                    case .authorized:
                        AutheticateWithApple(completion: completion)
                        
                    case .denied:
                        //Completion Here
                        print("Creating Alert")
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "Head to settings > Privacy > Media & Apple Music and allow Peak to access Media & Apple Music.", message: nil,preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            completion(alert)
                        }
                        
                        
                    default:
                        print("Shouldn't be here")
                    }
                    
                })
                
            }
            
            
        })
        
    }
    
    
    static func AuthenticateWithSpotify(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //start up the player so we can get the authentication access
        peakMusicController.systemMusicPlayer = SPTAudioStreamingController.sharedInstance()
        
        //Create the delegate for this
        (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).delegate = appDelegate
        
        
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
        
        DispatchQueue.main.async {
            
            if auth?.session != nil{
                
                (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).login(withAccessToken: auth?.session.accessToken)
                
                
            } else{
                
                let authURL = auth?.spotifyWebAuthenticationURL()
                
                authViewController = SFSafariViewController(url: authURL!)
                appDelegate.window?.rootViewController?.present(authViewController!, animated: true, completion: nil)
            }
        }
        
    }
    
    
/*MARK: SUPPORT METHODS*/
}
