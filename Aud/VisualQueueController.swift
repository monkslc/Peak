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
    
    
    var library = UITableView() //Need this to get the cell
    
    //always want one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        //change the return based on the type of player
        if peakMusicController.playerType != .Contributor {
            
            return peakMusicController.currPlayQueue.count - 1 - peakMusicController.systemMusicPlayer.indexOfNowPlayingItem
        } else {
            
            return peakMusicController.groupPlayQueue.count - 1 //subtract 2 to take into account the song currently playing
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
    
        
        //update the cell depending on the type of player
        if peakMusicController.playerType != .Contributor{
            
            let mediaItemToAdd = peakMusicController.currPlayQueue[peakMusicController.systemMusicPlayer.indexOfNowPlayingItem + 1 + indexPath.row]
            cell.albumArt.image = mediaItemToAdd.artwork?.image(at: CGSize()) ?? #imageLiteral(resourceName: "defaultAlbum")
            cell.songTitle.text =  mediaItemToAdd.title
            cell.songArtist.text = mediaItemToAdd.artist
            
            //get the time until the song plays
            var timeUntil: Double = (peakMusicController.systemMusicPlayer.nowPlayingItem?.playbackDuration)!
            for index in 0..<peakMusicController.currPlayQueue.count {
                
                //check if we should add the duration, by checking the current index
                if index < indexPath.row {
                    timeUntil += Double(peakMusicController.currPlayQueue[index].playbackDuration)
                } else {
                    break
                }
            }
            
            cell.songDurationLabel.text = formatTimeInterval(timeUntil)
        } else {
            //we are a contributor so get the information from the group play queue
            let songToAdd = peakMusicController.groupPlayQueue[indexPath.row + 1]
            
            cell.albumArt.image = songToAdd.image
            cell.songTitle.text = songToAdd.trackName
            cell.songArtist.text = songToAdd.artistName
            
            //get the time until the song plays
            var timeUntil: Double = Double(songToAdd.trackTimeMillis / 1000)
            for index in 0..<peakMusicController.groupPlayQueue.count {
                
                if index < indexPath.row {
                    
                    timeUntil += Double(peakMusicController.groupPlayQueue[index].trackTimeMillis / 1000)
                }
            }
            
            cell.songDurationLabel.text = formatTimeInterval(timeUntil)
            
        }
        
        cell.backgroundColor = UIColor.clear
        
        //show the duration label
        cell.songDurationLabel.isHidden = false
        
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //A cell got moved so the currently playing queue should update
        
        //Get the song we need to move
        let indexOfItemToMove = sourceIndexPath.row + 1
        let itemToMove = peakMusicController.currPlayQueue[indexOfItemToMove]
        
        //remove and reinsert the item at the appropriate index
        peakMusicController.currPlayQueue.remove(at: indexOfItemToMove)
        peakMusicController.currPlayQueue.insert(itemToMove, at: destinationIndexPath.row + 1)
        
        
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return .none
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
