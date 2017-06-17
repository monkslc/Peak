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
    
    /*PROPERTIES*/
    var nowPlaying: BasicSong? {get}
    var nowPlayingLoc: Int {get}
    var playerState: MusicPlayerState {get}
    
    /*METHODS*/
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
    
    
    /*NOTIFICATION METHODS*/
    func playerStateChanged()
    func libraryChanged()
    func playerNowPlayingItemChanged()
    
    /*NOTIFICATIONS*/
    //generate playback NOTIFICATIONS
    //stop generating playback notifications
    func generateNotifications()
    func stopGeneratingNotifications()
}

