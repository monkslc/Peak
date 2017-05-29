//
//  NotificationExtension.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation

extension Notification.Name{
    
    //Peak Music Controller related extensions
    static let musicTypeChanged = Notification.Name("MusicTypeChanged")
    static let playerTypeChanged = Notification.Name("PlayerTypeChanged")
    static let groupQueueChanged = Notification.Name("GroupQueueChanged")
    static let currPlayQueueChanged = Notification.Name("CurrPlayQueueChanged")
    
    //Song Time Update
    static let updateSongTime = Notification.Name("UpdateSongTime")
    
    //System Music PLayer extension
    static let systemMusicPlayerStateChanged = Notification.Name("StateChanged")
    static let systemMusicPlayerLibraryChanged = Notification.Name("LibraryChanged")
    static let systemMusicPlayerNowPlayingChanged = Notification.Name("NowPlayingItemChanged")
    
    //Spotify Notification extension
    static let spotifyLoginSuccessful = Notification.Name("SpottyLoggedIn")

}
