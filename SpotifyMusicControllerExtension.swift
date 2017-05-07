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
        
        print("Setting the player queue")
        
        if songs.count > 0{

            //Set the first song in the queue to playing
            self.playSpotifyURI((songs[0] as! SPTTrack).playableUri.absoluteString, startingWith: 0, startingWithPosition: 0){
                
                if $0 != nil{
                    print("There was an error with our inital play \($0!)")
                }
            }
            
            //Queue the second song
            /*if songs.count > 1{
                
                //Set a delay, otherwise it won't queue
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) ) {
                    
                    self.queueSpotifyURI((songs[1] as! SPTTrack).playableUri.absoluteString){
                        
                        if $0 != nil{
                            print("We had an error setting the spotify queue: \($0!)")
                        }
                    }
                }
            }*/
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
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerStateChanged))
    }
    
    func libraryChanged() {
        
        
    }
    
    func playerNowPlayingItemChanged() {
        
        //Update the play queue when the song changes
        self.setPlayerQueue(songs: peakMusicController.currPlayQueue)
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
    }
    
    /*MARK: Playback Delegate methods*/
    public func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        
        //print("Audio Streaming Did Skip")
        //playerNowPlayingItemChanged()
    }
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        
        playerStateChanged()
    }
    
   /* public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        
        /*WE GET THE POSITION HERE, NOW WE NEED TO FIND A WAY TO SET IT*/
    }*/
    
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        
        //Check if the previous song equals the 0th item in the current play queue, if it does our song changed
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
            
            //Check if the song that is playing changed
            if (metadata.currentTrack?.isEqual(to: peakMusicController.currPlayQueue[0]))! == false{
                
                self.playerNowPlayingItemChanged()
            }
            
        
            //Lets get the next song to play
            if peakMusicController.currPlayQueue.count > self.getNowPlayingItemLoc() + 1{
                
                let track = peakMusicController.currPlayQueue[self.getNowPlayingItemLoc() + 1]
                
                if metadata.nextTrack == nil || metadata.nextTrack!.isEqual(to: track) == false{
                    
                    print("Ok we are gonna want to queue \(track.getTrackName()) right about now")
                    //We know we need to queue now
                    self.queueSpotifyURI((track as! SPTTrack).playableUri.absoluteString){
                            
                        if $0 != nil{
                            print("Error Qeueing next track in audioStreaming \($0!)")
                        }
                    }
                        
                    print("\nOk should be all queued up now\n")
                }
            }
            
        }
        
        
        
    }
    
    

}
