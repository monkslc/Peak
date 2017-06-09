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
        let cell = BVC.libraryViewController.library.dequeueReusableCell(withIdentifier: "Song Cell", for: indexPath) as! SongCell // ERROR WAS HERE
    
        
        //Update the cell
        var itemToAdd: BasicSong?
        
        if peakMusicController.playerType != .Contributor{
            
            itemToAdd = peakMusicController.currPlayQueue[peakMusicController.systemMusicPlayer.getNowPlayingItemLoc() + 1 + indexPath.row]
        } else{
            
            itemToAdd = peakMusicController.groupPlayQueue[indexPath.row + 1]
        }
    
        
        //Let's get the image
        if let meImage = itemToAdd?.getImage(){
            
            cell.albumArt.image = meImage
        } else{
            
            cell.albumArt.image = #imageLiteral(resourceName: "ProperPeakyIcon")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
                
                cell.albumArt.image = itemToAdd?.getImage() ?? #imageLiteral(resourceName: "ProperPeakyIcon")
                tableView.reloadData()
            }
        }
        
        cell.albumArt.image = itemToAdd?.getImage() ?? #imageLiteral(resourceName: "ProperPeakyIcon")
        cell.songTitle.text = itemToAdd?.getTrackName()
        cell.songArtist.text = itemToAdd?.getArtistName()
        

        //get the time until the song plays
        var timeUntil: Double = 0.0
    
        
        
        //Figure out which queue were looking to show and get the count and the first track wait time
        var count = 0
        if peakMusicController.playerType != .Contributor{
            
            count = peakMusicController.currPlayQueue.count
            
            timeUntil += Double((peakMusicController.systemMusicPlayer.getNowPlayingItem()?.getTrackTimeMillis()) ?? Int(0.0))
        } else{
            
            count = peakMusicController.groupPlayQueue.count
            timeUntil += Double(peakMusicController.groupPlayQueue[0].getTrackTimeMillis())
        }
        
        for index in 0..<count {
            
            //check if we should add the duration, by checking the current index
            if index < indexPath.row {
                
                if peakMusicController.playerType != .Contributor{
                    
                    timeUntil += Double(peakMusicController.currPlayQueue[index + 1].getTrackTimeMillis())
                } else{
                    
                    timeUntil += Double(peakMusicController.groupPlayQueue[index + 1].getTrackTimeMillis())
                }
                
            } else {
                break
            }
        }
        
        cell.songDurationLabel.text = formatTimeInterval(timeUntil)
        
        
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
