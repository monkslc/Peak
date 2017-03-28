//  AuthViewController.swift
//  Peak
//
//  Created by Connor Monks on 3/18/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import StoreKit

class AuthViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var welcomeToLabel: UILabel!
    
    @IBOutlet weak var appleMusicButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        welcomeToLabel.text = "Hello \(getUserName())\nWelcome  To Peak"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //This methods makes it so it automatically segues to apple music without user interaction on welcome screen
        if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
            
            print("authorized, maybe not performing segue because it hasn't been identified yet")
            //performSegue(withIdentifier: "Segue to Apple Music", sender: nil)
        }
        
    }
    
    @IBAction func checkAppleAuthentication() {
        
        loadingIndicator.startAnimating()
        //check if we have authorization to the user's apple music
        SKCloudServiceController.requestAuthorization({(authorization) in
            
            switch authorization{
                
            case .authorized:
                print("authorized")
                //authorized so segue
                self.loadingIndicator.stopAnimating()
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        
                        self.performSegue(withIdentifier: "Segue to Apple Music", sender: nil)
                    }
                }
                
                
            case .denied:
                self.loadingIndicator.stopAnimating()
                self.instructUserToAllowUsToAppleMusic()

            case .notDetermined:
                print("Can't be determined")
                self.loadingIndicator.stopAnimating()
                
            case .restricted:
                print("Restricted")
                
                self.loadingIndicator.stopAnimating()
            }
            
        })
        
        
    }
    
    //Let the user know how to give us access to apple music
    func instructUserToAllowUsToAppleMusic(){
        
        let alert = UIAlertController(title: "Head to settings > Privacy > Media & Apple Music and allow Peak to access Media & Apple Music.", message: nil,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        self.loadingIndicator.stopAnimating()
    }
    
    //let the user know their access to apple music is restricted
    func alertRestrictedAccess(){
        
        let alert = UIAlertController(title: "Access to Apple Music is restricted.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:
            .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        self.loadingIndicator.stopAnimating()
    }
    
    // used to get the name of the user
    private func getUserName() -> String {
        let name = UIDevice.current.name
        
        if name.contains(" iPhone") {
            if name.contains("’") {
                return name.subString(toIndex: name.indexOf(target: "’"))
            }
            else if name.contains("'") {
                return name.subString(toIndex: name.indexOf(target: "'"))
            }
            else {
                return name.subString(toIndex: name.indexOf(target: " iPhone"))
            }
        }
        
        return name
    }
    
}
