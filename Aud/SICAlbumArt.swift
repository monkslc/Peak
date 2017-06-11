//
//  SICAlbumArt.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class SICAlbumArt: UIImageView {

    /*MARK: Initilizers*/
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Set the appearance of the view
        clipsToBounds = true
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
            
        //Add the listeners
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumImage), name: .systemMusicPlayerNowPlayingChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumImage), name: .groupQueueChanged, object: nil)
        
        updateAlbumImage()
    }
    
    /*MARK: Notification Methods*/
    
    func updateAlbumImage(){
        //Update the album image when the song changes
        
        if peakMusicController.playerType != .Contributor{
            
            DispatchQueue.main.async {
                
                
                self.image = peakMusicController.systemMusicPlayer.getNowPlayingItem()?.getImage() ?? #imageLiteral(resourceName: "Peak Logo Proper Album")
            }

        } else{
            
            if peakMusicController.groupPlayQueue.count > 0{
                
                DispatchQueue.main.async {
                    
                    self.image = peakMusicController.groupPlayQueue[0].getImage() ?? #imageLiteral(resourceName: "Peak Logo Proper Album")
                }
                
            } else{
                
                DispatchQueue.main.async {
                    self.image = #imageLiteral(resourceName: "Peak Logo Proper Album")
                }
                
            }
            
        }
        
    }
    
    
}
