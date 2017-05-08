//
//  GuestMusicController.swift
//  Peak
//
//  Created by Connor Monks on 5/8/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class GuestMusicController: SystemMusicPlayer{
    
    /*METHODS*/
    func getNowPlayingItem() -> BasicSong?{
        
        print("Guest Controller: getNowPlayingItem()")
        return nil
    }
    
    func getPlayerState() -> MusicPlayerState{
        
        print("Guest Controller: getPlayerState()")
        return MusicPlayerState.paused
    }
    
    func getNowPlayingItemLoc() -> Int{
        
        print("Guest Controller: getNowPlayingItemLoc")
        return 0
    }
    
    func setShuffleState(state: ShuffleState){
        
        print("Guest Controller: setShuffleState()")
    }
    
    func startPlaying(){
        
        print("Guest Controller: startPlaying()")
    }
    
    func stopPlaying(){
        
        print("Guest Controller: stopPlaying()")
    }
    
    func setPlayerQueue(songs: [BasicSong]){
        
        print("Guest Controller: setPlayerQueue()")
    }
    
    func preparePlayerToPlay(){
        
        print("Guest Controller: prepareToPlay()")
    }
    
    func restartSong(){
        
        print("Guest Controller: restartSong()")
    }
    
    func skipSong(){
        
        print("Guest Controller: skipSong()")
    }
    
    func setNowPlayingItemToNil(){
        
        print("Guest Controller: setNowPlayingItemToNil()")
    }
    
    func getCurrentPlaybackTime() -> Double{
        
        print("Guest Controller: getCurrentPlaybackTime()")
        return 0.0
    }
    
    func setCurrentPlayTime(_ time: Double){
        
        print("Guest Controller: setCurrentPlayTime()")
    }
    
    func setQueueIds(_ idArray: [String]){
        
        print("Guest Controller: setQueueIds")
    }
    
    
    /*NOTIFICATION METHODS*/
    func playerStateChanged(){
        
        print("Guest Controller: playerStateChanged()")
    }
    
    func libraryChanged(){
        
        print("Guest Controller: libraryChanged()")
    }
    
    func playerNowPlayingItemChanged(){
        
        print("Guest Controller: playerNowPlayingItemChanged()")
    }
    
    /*NOTIFICATIONS*/
    //generate playback NOTIFICATIONS
    //stop generating playback notifications
    func generateNotifications(){
        
        print("Guest Controller: generateNotifications()")
    }
    
    func stopGeneratingNotifications(){
        
        print("Guest Controller: stopGeneratingNotifications()")
    }
}
