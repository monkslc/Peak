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
    
    
    //always want one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        //change the return based on the type of player
        if peakMusicController.playerType != .Contributor {
            
            return peakMusicController.currPlayQueue.count - 1 - peakMusicController.systemMusicPlayer.getNowPlayingItemLoc()
        } else {
            
            return peakMusicController.groupPlayQueue.count - 1 //subtract 2 to take into account the song currently playing
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //Get the cell we want to use
        let BVC = peakMusicController.delegate as! BeastController
        let cell = BVC.libraryViewController?.library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell
    
        
        //update the cell depending on the type of player
        if peakMusicController.playerType != .Contributor{
            
            let mediaItemToAdd = peakMusicController.currPlayQueue[peakMusicController.systemMusicPlayer.getNowPlayingItemLoc() + 1 + indexPath.row]
            
            //Check if we can get the image
            if let albumImage = mediaItemToAdd.getImage(){
                
                cell.albumArt.image = albumImage
            } else {
                
                //set a temporary default image then fetch the actual
                cell.albumArt.image = #imageLiteral(resourceName: "ProperPeakyIcon")
                
                //the fetch
                ConnectingToInternet.getSong(id: mediaItemToAdd.getId(), completion: {(song) in
                
                    if song.image != nil{
                        
                        cell.albumArt.image = song.image
                    }
                    
                })
                
            }
            //cell.albumArt.image = mediaItemToAdd.artwork?.image(at: CGSize()) ?? #imageLiteral(resourceName: "defaultAlbum") //Don't totally do away with this until confirming the visual queue picks up the right album
            cell.songTitle.text =  mediaItemToAdd.getTrackName()
            cell.songArtist.text = mediaItemToAdd.getArtistName()
            
            //get the time until the song plays
            var timeUntil: Double = Double((peakMusicController.systemMusicPlayer.getNowPlayingItem()?.getTrackTimeMillis()) ?? Int(0.0))
            for index in 0..<peakMusicController.currPlayQueue.count {
                
                //check if we should add the duration, by checking the current index
                if index < indexPath.row {
                    timeUntil += Double(peakMusicController.currPlayQueue[index].getTrackTimeMillis())
                } else {
                    break
                }
            }
            
            cell.songDurationLabel.text = formatTimeInterval(timeUntil)
        } else {
            //we are a contributor so get the information from the group play queue
            let songToAdd = peakMusicController.groupPlayQueue[indexPath.row + 1]
            
            //get the image
            if songToAdd.image == nil{
                
                cell.albumArt.image = #imageLiteral(resourceName: "ProperPeakyIcon")
            } else {
                
                cell.albumArt.image = songToAdd.image
            }
            
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if peakMusicController.playerType == .Contributor{
            
            return .none
        } else {
            
            return .delete
        }
    }
    
    
    func formatTimeInterval(_ ti: TimeInterval) -> String {
        
        let hours = Int(floor(ti / 3600))
        let minutes = Int(floor((ti - (Double(hours) * 3600)) / 60))
        let seconds = (ti - ((Double(minutes) * 60) + (Double(hours) * 3600))) / 100
        
        
        let secondsFormat = String(format: "%.2f", seconds)
        let choppedSeconds = secondsFormat.replacingOccurrences(of: "0.", with: "")
        var formattedTime = ""
        if hours != 0{
            
            var formattedMinutes = String(Int(minutes))
            if minutes < 10 {
                formattedMinutes = "0" + formattedMinutes
            }
            
            formattedTime = String(hours) + ":" + formattedMinutes + ":" + choppedSeconds
        } else {
            
            formattedTime = String(Int(minutes)) + ":" + choppedSeconds
        }
        return formattedTime
    }
}
