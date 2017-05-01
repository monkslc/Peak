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
    
    //Song Time Update
    static let updateSongTime = Notification.Name("UpdateSongTime")
}
