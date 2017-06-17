//
//  GuestMusicController.swift
//  Peak
//
//  Created by Connor Monks on 5/8/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

class GuestMusicController: SystemMusicPlayer{
    
    
/*MARK: PROPERTIES*/
    var nowPlaying: BasicSong? {
        
        return nil
    }
    
    var nowPlayingLoc: Int {
        
        return 0
    }
    
    var playerState: MusicPlayerState {
        
        return MusicPlayerState.paused
    }
    /*METHODS*/
    
    func setShuffleState(state: ShuffleState){
        
    }
    
    func startPlaying(){
        
    }
    
    func stopPlaying(){
        
    }
    
    func setPlayerQueue(songs: [BasicSong]){
        
    }
    
    func preparePlayerToPlay(){
        
    }
    
    func restartSong(){
        
    }
    
    func skipSong(){
        
    }
    
    func setNowPlayingItemToNil(){
        
        peakMusicController.currPlayQueue = []
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
    }
    
    func getCurrentPlaybackTime() -> Double{
        
        return 0.0
    }
    
    func setCurrentPlayTime(_ time: Double){
        
    }
    
    func setQueueIds(_ idArray: [String]){
        
    }
    
    
    /*NOTIFICATION METHODS*/
    func playerStateChanged(){
        
    }
    
    func libraryChanged(){
        
    }
    
    func playerNowPlayingItemChanged(){
        
    }
    
    /*NOTIFICATIONS*/
    func generateNotifications(){
        
    }
    
    func stopGeneratingNotifications(){
        
    }
}
