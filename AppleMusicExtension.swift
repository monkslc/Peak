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
    
    func getNowPlayingItemLoc() -> Int {
        
        return indexOfNowPlayingItem
    }
    
    func getNowPlayingItem() -> BasicSong? {
        
        return nowPlayingItem
    }
    
    func getPlayerState() -> MusicPlayerState {
        
        switch playbackState{
            
        case .playing:
            return MusicPlayerState.playing
            
        default:
            return MusicPlayerState.paused
        }
    }
    
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
        
        var mediaItems = [MPMediaItem]()
        for song in songs{
            mediaItems.append(song as! MPMediaItem)
        }
        
        setQueue(with: MPMediaItemCollection(items: mediaItems))
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
        
        beginGeneratingPlaybackNotifications()
    }
    
    func stopGeneratingNotifications() {
        
        endGeneratingPlaybackNotifications()
    }
    
    func setNowPlayingItemToNil() {
        
        nowPlayingItem = nil
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
}
