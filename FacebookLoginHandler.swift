//
//  FacebookLoginHandler.swift
//  Peak
//
//  Created by Connor Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import FBSDKLoginKit


class FacebookLoginHandler: NSObject, FBSDKLoginButtonDelegate{
    
    /*MARK: FACEBOOK LOGIN DELEGATE METHODS*/
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        //print("We're about to login")
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //print("We're about to logout")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        fetchProfile()
    }
    
    
    /*MARK: FETCHING USER INFO Methods*/
    private func fetchProfile(){
        
        print("Fetching me Profile")
        let params = ["fields": "email, id, friends"]
        
        let connection = FBSDKGraphRequestConnection()
        
        let req = FBSDKGraphRequest(graphPath: "/me", parameters: params)
        
        //FBSDKGraphRequestHandler
        
        connection.add(req){ connection, result, error in
            
            if let results = result as? [String:Any]{
                
                //get the user id
                let email = results["email"]!
                
                let id = results["id"]!
                
                let userFriends = results["friends"]!
                
                print("The user's email is: \(email)")
                print("The user's id is: \(id)")
                
                //Let's see what we can do with the user's friends
                print(userFriends)
                
                if let newFriends = userFriends as? [String: Any]{
                    
                    if let data = newFriends["data"]{
                        
                        print("Our data was: \(data)")
                    }
                    
                    if let summary = newFriends["summary"] as? [String: Int]{
                        
                        if let count = summary["total_count"]{
                            
                            print("Me friend count is: \(count)")
                        }
                        
                    }
                }
            }
        }
        connection.start()
    }
}
