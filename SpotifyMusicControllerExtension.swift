//
//  SpotifyMusicControllerExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

extension SPTAudioStreamingController: SystemMusicPlayer, SPTAudioStreamingPlaybackDelegate{
    
    func getNowPlayingItemLoc() -> Int {
        
        return 0
    }
    
    func getNowPlayingItem() -> BasicSong? {
        
        return metadata.currentTrack
    }
    
    func getPlayerState() -> MusicPlayerState {
        
        if playbackState != nil{
            
            if playbackState.isPlaying{
                
                return MusicPlayerState.playing
            }else{
                return MusicPlayerState.paused
            }
        } else {
            
            setIsPlaying(true){
                
                if $0 != nil{
                    print($0!)
                }
            }
        }
        
        return MusicPlayerState.playing
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
        
        print("We are setting the player queue")
        if songs.count > 0{
            
            print("Song.count is in fact > 0")
            
            self.playSpotifyURI((songs[0] as! SPTTrack).playableUri.absoluteString, startingWith: 0, startingWithPosition: 0){
                
                if $0 != nil{
                    print("There was an error with our inital play \($0)")
                }
            }
            
            
            if songs.count > 1{
                
                self.queueSpotifyURI((songs[1] as! SPTTrack).playableUri.absoluteString){
                    
                    if $0 != nil{
                        print("We had an error setting the spotify queue: \($0!)")
                    }
                }
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
        
        self.playbackDelegate = self
    }
    
    func stopGeneratingNotifications() {
        
        //Not sure what to do here yet either
    }
    
    func setNowPlayingItemToNil() {
        
       //Don't do anything here yet
    }
    
    func getCurrentPlaybackTime() -> Double {
        
       
       /*NEED TO FIND A WAY TO STORE THE VALUE FOR THE TIME*/
        return 0.0
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
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
    }
    
    func libraryChanged() {
        
        
    }
    
    func playerNowPlayingItemChanged() {
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
    }
    
    /*MARK: Playback Delegate methods*/
    public func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        
        playerNowPlayingItemChanged()
    }
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        
        playerStateChanged()
    }
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        
        /*THIS IS WHERE WE CAN GET THE POSITION OF THE AUDIO PLAYER BUT WE HAVE TO FIGURE OUT A WAY TO STORE THE VALUE*/
    }

}
