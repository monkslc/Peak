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
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumImage), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: peakMusicController.systemMusicPlayer)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    /*MARK: Notification Methods*/
    
    func updateAlbumImage(){
        //Update the album image when the song changes
        
        image = peakMusicController.systemMusicPlayer.getNowPlayingItem()?.getImage() ?? #imageLiteral(resourceName: "ProperPeakyAlbumView")
    }
    

    
}
