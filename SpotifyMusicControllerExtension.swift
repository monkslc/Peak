//
//  SpotifyMusicControllerExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

extension SPTAudioStreamingController: SystemMusicPlayer{
    
    func getNowPlayingItemLoc() -> Int {
        
        return 0
    }
    
    func getNowPlayingItem() -> BasicSong? {
        
        return metadata.currentTrack
    }
    
    func getPlayerState() -> MusicPlayerState {
        
        if playbackState.isPlaying{
            
            return MusicPlayerState.playing
        }else{
            return MusicPlayerState.paused
        }
    }
    
    func setShuffleState(state: ShuffleState) {
        
        setShuffle(false){
            
            if $0 != nil{
                print("Error with Setting Shuffle State \($0!)")
            }
        }
    }
    
    func startPlaying() {
        
        self.setIsPlaying(true){
            
            if $0 != nil{
                print("Error with startPlaying \($0!)")
            }
        }
    }
    
    func stopPlaying() {
        
        self.setIsPlaying(false){
            
            if $0 != nil{
                print("Error with stopPlaying \($0!)")
            }
        }
        
    }
    
    func setPlayerQueue(songs: [BasicSong]) {
        
        self.queueSpotifyURI((songs[0] as! SPTTrack).playableUri.absoluteString){
            
            if $0 != nil{
                print("We had an error setting the spotify queue: \($0!)")
            }
        }
    }
    
    func restartSong() {
        
        self.seek(to: 0){
            
            if $0 != nil{
                print("Error restarting our song: \($0!)")
            }
        }
    }
    
    func skipSong() {
        
        self.skipNext(){
            
            if $0 != nil{
                print("We had an error skipping: \($0!)")
            }
        }
    }
    
    func preparePlayerToPlay() {
        
        //Don't need to do anything
    }
    
    func generateNotifications() {
        
        //Not sure what to do here yet
    }
    
    func stopGeneratingNotifications() {
        
        //Not sure what to do here yet either
    }
    
    func setNowPlayingItemToNil() {
        
       //Don't do anything here yet
    }
    
    func getCurrentPlaybackTime() -> Double {
        
        return (self.metadata.currentTrack?.duration)!
    }
    
    func setCurrentPlayTime(_ time: Double) {
        
        seek(to: time){
            
            if $0 != nil{
                print("Error setting the current play time: \($0!)")
            }
        }
    }
    
    func setQueueIds(_ idArray: [String]) {
        
        //Don't need to do this for spotify yet
    }
    
    
    /*MARK: LISTENER METHODS*/
    func playerStateChanged() {
        
        
    }
    
    func libraryChanged() {
        
        
    }
    
    func playerNowPlayingItemChanged() {
        
        
    }
}
