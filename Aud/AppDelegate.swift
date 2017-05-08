//  This is for all our new features post V1
//  AppDelegate.swift
//  Aud
//
//  Created by Connor Monks on 3/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    
    var shortcutItem: UIApplicationShortcutItem?
    
    
    /*MARK: SPOTIFY APPLICATION DELEGATE METHODS*/
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //Get a token refresh service
        
        //check if the url is what we expect
        
        if (auth?.canHandle(url))!{
            
            print("Auth can handle our url")
            
            authViewController?.dismiss(animated: true, completion: nil)
            authViewController = nil
            
            auth?.handleAuthCallback(withTriggeredAuthURL: url){ error, session in
                
                if session != nil{
                    
                    DispatchQueue.global().async {
                        
                        (peakMusicController.systemMusicPlayer as! SPTAudioStreamingController).login(withAccessToken: auth?.session.accessToken)
                        
                    }
                    
                    
                    //print("OUr token refresh URL is: \(auth?.tokenRefreshURL)")
                    //print("Our token type was: \(session?.tokenType)")
                    //print("Our access token was: \(session?.accessToken)")
                    //print("Our refresh token URL was: \(session?.encryptedRefreshToken)")
                }
                
            }
            
        } else{
            print("Auth can't handle our url")
        }

        return true
    }
    
    /*MARK: SPOTIFY AUDIO STREAMING DELEGATE METHODS*/
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("OUR SPOTIFY LOGIN WAS SUCCESSFUL")
        NotificationCenter.default.post(Notification(name: .spotifyLoginSuccessful))
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("\n\n\nOK HERE WE ARE.\nSpotify Audio Streaming Logged Out\n\n\n")
    }
    
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("\n\n\nOK HERE WE ARE.\nSpotify Audio Streaming Did Disconnect\n\n\n")
    }
    
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("\n\n\nOK HERE WE ARE.\nSpotify Audio Streaming Did Reconnect\n\n\n")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        
        /********THIS IS WHERE WE NEED TO REFRESH THE TOKEN*****/
        
        print("\nOK HERE WE ARE.\nSpotify Audio Streaming Did Receive an ERROR\n")
        print(error)
        
        //
        
        //Ok let's try reconnecting and see if that works
        //print("OUr encrypted refresh token is \(auth?.session.encryptedRefreshToken)")
        auth?.renewSession(auth?.session){ err, session in
            
            
            
            print("Ok so we should be renewing the session")
            if err != nil{
                
                print("Error renewing session: \(err!)")
                return
            }
            
            //NO error so keep going
            print("There was no error in renewing the token")
            
            
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        
        print("\n\n\nOK HERE WE ARE.\nSpotify Audio Streaming Did Receive a Message\n\n\n")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("\n\n\nOK HERE WE ARE.\nSpotify Audio Streaming DId Encounter Temp Error\n\n\n")
    }
    
    /*MARK: NOT SPOTIFY STUFF*/
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        if CheckInternetConnection.isConnectedToWifi() {
            GettingTopCharts.defaultGettingTopCharts.searchTopCharts()
        }
        
        var performShortcutDelegate = true
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            self.shortcutItem = shortcutItem
            
            performShortcutDelegate = false
        }
        
        return !performShortcutDelegate
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        guard let shortcut = shortcutItem else { return }
        
        _ = handleShortcut(shortcutItem: shortcut)
        
        self.shortcutItem = nil
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        peakMusicController.systemMusicPlayer.stopPlaying()
        self.saveContext()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        
        var succeeded = true
        
        switch shortcutItem.type {
        case "appleMusicId":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedAppleMusicForceTouchNotification"), object: nil)
        case "djId":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedDjForceTouchNotification"), object: nil)
        default:
            print("\n\nERROR: THIS SHOULD NEVER HAPPEN: App Delegate.handleShortcut: DONT KNOW SHORTCUT \(shortcutItem.type)\n\n")
            succeeded = false
        }
        
        return succeeded
        
    }
    
    
    /*MARK: CORE DATA STUFF ***********DO******NOT*******DELETE*******EVER*/
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

