//
//  VisualQueueController.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import Foundation
import UIKit


class VisualQueueController: NSObject, UITableViewDelegate, UITableViewDataSource{
    
    
    var library = UITableView()
    
    //always want one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peakMusicController.currPlayQueue.count - 1 - peakMusicController.systemMusicPlayer.indexOfNowPlayingItem
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mediaItemToAdd = peakMusicController.currPlayQueue[peakMusicController.systemMusicPlayer.indexOfNowPlayingItem + 1 + indexPath.row]
        
        let cell = library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
        
        cell.albumArt.image = mediaItemToAdd.artwork?.image(at: CGSize())
        cell.songTitle.text =  mediaItemToAdd.title
        cell.songArtist.text = mediaItemToAdd.artist
        
        //get the time until the song plays
        var timeUntil: Double = (peakMusicController.systemMusicPlayer.nowPlayingItem?.playbackDuration)!
        for index in 0..<peakMusicController.currPlayQueue.count {
            
            //check if we should add the duration, by checking the current index
            if index < indexPath.row {
                timeUntil += Double(peakMusicController.currPlayQueue[index].playbackDuration)
            }
        }
        
        cell.songDurationLabel.text = formatTimeInterval(timeUntil)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    //Method to delete items from queue
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let indexOfItemToDelete = indexPath.row + 1
            UIView.animate(withDuration: 0.5, animations: {
                
                tableView.cellForRow(at: indexPath)?.center.x -= 1000
            }, completion: {(finished) in
                
                peakMusicController.currPlayQueue.remove(at: indexOfItemToDelete)
                tableView.reloadData()
            })
        }
    }
    
    func formatTimeInterval(_ ti: TimeInterval) -> String {
        
        let minutes = floor(ti / 60)
        let seconds = (ti - (minutes * 60)) / 100
        let secondsFormat = String(format: "%.2f", seconds)
        let choppedSeconds = secondsFormat.replacingOccurrences(of: "0.", with: "")
        let formattedTime = String(Int(minutes)) + ":" + choppedSeconds
        return formattedTime
    }
}
