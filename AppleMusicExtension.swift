//
//  AppleMusicExtension.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPMusicPlayerController: SystemMusicPlayer {
    
    
/*MARK: PROPERTIES*/
    var nowPlaying: BasicSong? {
        
        return nowPlayingItem
    }
    
    var nowPlayingLoc: Int {
        
        return indexOfNowPlayingItem
    }
    
    var playerState: MusicPlayerState {
        
        switch playbackState{
            
        case .playing:
            return MusicPlayerState.playing
            
        default:
            return MusicPlayerState.paused
        }
    }
    
/*MARK: METHODS*/
    func setShuffleState(state: ShuffleState) {
        
        switch state{
            
        case .off:
            shuffleMode = .off
            
        default:
            break
        }
    }
    
    func startPlaying() {
        
        play()
    }
    
    func stopPlaying() {
        
        pause()
    }
    
    func setPlayerQueue(songs: [BasicSong]) {
        
        setQueue(with: MPMediaItemCollection(items: songs as! [MPMediaItem]))
    }
    
    func restartSong() {
        
        skipToBeginning()
    }
    
    func skipSong() {
        
        skipToNextItem()
    }
    
    func preparePlayerToPlay() {
        
        prepareToPlay()
    }
    
    func generateNotifications() {
        
        repeatMode = .none
        
        beginGeneratingPlaybackNotifications()
        
        //Add the listeners for the class
        NotificationCenter.default.addObserver(self, selector: #selector(libraryChanged), name: .MPMediaLibraryDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStateChanged), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(playerNowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: self)
        MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()
    }
    
    func stopGeneratingNotifications() {
        
        endGeneratingPlaybackNotifications()
    }
    
    func setNowPlayingItemToNil() {
        
        
        nowPlayingItem = nil
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
    }
    
    func getCurrentPlaybackTime() -> Double {
        
        return currentPlaybackTime
    }
    
    func setCurrentPlayTime(_ time: Double) {
        
        currentPlaybackTime = time
    }

    func setQueueIds(_ idArray: [String]) {
        
        
        setQueueWithStoreIDs(idArray)
    }
    
    /*MARK: LISTENER METHODS*/
    func libraryChanged(){
        
        print("Our Library changed, pushing me notification")
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerLibraryChanged))
    }
    
    func playerStateChanged() {
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerStateChanged))
    }
    
    func playerNowPlayingItemChanged() {
        
        NotificationCenter.default.post(Notification(name: .systemMusicPlayerNowPlayingChanged))
    }
    
    
}
