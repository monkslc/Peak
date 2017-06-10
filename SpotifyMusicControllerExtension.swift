//
//  SpotifyMusicControllerExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

extension SPTAudioStreamingController: SystemMusicPlayer, SPTAudioStreamingPlaybackDelegate{
    
    /*PRIVATE STRUCT TO STORE PROPERTIES*/
    private struct customProperties{
        
        static var trackTime: TimeInterval?
    }
    
    
    /*PROPERTIES*/
    var currentTrackTime: TimeInterval?{
        
        get{
           
            return objc_getAssociatedObject(self, &customProperties.trackTime) as? TimeInterval ?? 0.0
        }
        set{
            
            if let unwrappedValue = newValue{
                
                objc_setAssociatedObject(self, &customProperties.trackTime, unwrappedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func getNowPlayingItemLoc() -> Int {
        
        //Get the current track
        if let track = getNowPlayingItem(){
            
            //Loop through the queue and see where it is
            var counter = 0
            for song in peakMusicController.currPlayQueue{
                
                if song.isEqual(to: track){
                    
                    return counter
                }
                counter += 1
            }
        }
        
        return 0
    }
    
    func getNowPlayingItem() -> BasicSong? {
        
        if metadata != nil{
            return metadata.currentTrack
        } else {
            return nil
        }
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
        
        return MusicPlayerState.paused
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
        
        /*ONLY PLAY IF THE SONG IS NOT EQUAL TO THE CURRENTLY PLAYING SONG*/
        
    
        if songs.count > 0{
            
            if metadata == nil{
                
                self.playSpotifyURI(songs[0].getId(), startingWith: 0, startingWithPosition: 0){
                    if $0 != nil{
                        
                        print("There was an error with our initial play \($0!)")
                    }
                }
                
            } else if metadata.currentTrack?.isEqual(to: songs[0]) != true {
                
                self.playSpotifyURI((songs[0] as! SPTPartialTrack).playableUri.absoluteString, startingWith: 0, startingWithPosition: 0) {
                    
                    if $0 != nil {
                        print("There was an error with our inital play \($0!)")
                    }
                }
            }
            
            updateSpotifyQueue()
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
        
        self.setRepeat(.off){
            
            if $0 != nil{
                
                print("We had an error turning off our repeat mode: \($0!)")
            }
        }
        
        do{
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch{
            
            print("Why the fuck did I get this error?")
        }
        
        self.playbackDelegate = self
    }
    
    func stopGeneratingNotifications() {
        
        //Not sure what to do here yet either
    }
    
    func setNowPlayingItemToNil() {
        
       //Don't do anything here yet
    }
    
    func getCurrentPlaybackTime() -> Double {
        
        if currentTrackTime != nil{
            
            return currentTrackTime!
        } else{
            
            return 0.0
        }
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
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerStateChanged))
    }
    
    func libraryChanged() {
        
        
    }
    
    func playerNowPlayingItemChanged() {
        
        
        if peakMusicController.playerType != .Contributor{
            
            NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
        }
        
    }
    
    /*MARK: Playback Delegate methods*/
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        
        playerStateChanged()
    }
    
   public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        
        currentTrackTime = position
    }
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        
        switch event{
            
        case SPPlaybackNotifyTrackChanged:
            updateSpotifyQueue()
            playerNowPlayingItemChanged()
            
        default:
            break
        }

    }
    
    public func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        
        print("Our Audio Streaming Did Pop Queue")
    }
    
    private func updateSpotifyQueue(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
            
            //Lets get the next song to play
            if peakMusicController.currPlayQueue.count > self.getNowPlayingItemLoc() + 1{
                
                let track = peakMusicController.currPlayQueue[self.getNowPlayingItemLoc() + 1]
                
                
                if self.metadata.nextTrack == nil || self.metadata.nextTrack!.isEqual(to: track) == false{
                    //We know we need to queue now
                    
                    
                    self.queueSpotifyURI((track as! SPTPartialTrack).playableUri.absoluteString){
                        
                        print("Successful Queue of \(track)")
                        if $0 != nil{
                            print("Error Qeueing next track in audioStreaming \($0!)")
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        
        
    }

}
