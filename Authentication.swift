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
                            
                            completion(nil)
                            //Completion Here
                            //peakMusicController.systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
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
                //Completion Here
                //self.present(alert, animated: true, completion: nil)
                //Downloaded but no iCloud selected
                
                //App was not downloaded
                
            } else {
                
                //self.loadingIndicator.stopAnimating()
                
                //We are yet to get access from the user
                SKCloudServiceController.requestAuthorization({(authorization) in
                    
                    switch authorization {
                        
                    case .authorized:
                        AutheticateWithApple(completion: completion)
                        
                    case .denied:
                        //Completion Here
                        let alert = UIAlertController(title: "Head to settings > Privacy > Media & Apple Music and allow Peak to access Media & Apple Music.", message: nil,preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        completion(alert)
                        
                    default:
                        print("Shouldn't be here")
                    }
                    
                })
                
            }
            
            
        })
        
    }
}
