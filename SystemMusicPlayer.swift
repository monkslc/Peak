//
//  SystemMusicPlayer.swift
//  Peak
//
//  Created by Connor Monks on 5/5/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

enum MusicPlayerState{
    
    case playing
    case paused
}

enum ShuffleState{
    
    case on
    case off
}

protocol SystemMusicPlayer{
    
    /*METHODS*/
    func getNowPlayingItem() -> BasicSong?
    func getPlayerState() -> MusicPlayerState
    func getNowPlayingItemLoc() -> Int
    func setShuffleState(state: ShuffleState)
    func startPlaying()
    func stopPlaying()
    func setPlayerQueue(songs: [BasicSong])
    func preparePlayerToPlay()
    func restartSong()
    func skipSong()
    func setNowPlayingItemToNil()
    func getCurrentPlaybackTime() -> Double
    func setCurrentPlayTime(_ time: Double)
    func setQueueIds(_ idArray: [String])
    
    /*NOTIFICATIONS*/
    //generate playback NOTIFICATIONS
    //stop generating playback notifications
    func generateNotifications()
    func stopGeneratingNotifications()
}

