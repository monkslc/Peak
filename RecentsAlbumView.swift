//
//  RecentsAlbumView.swift
//  Peak
//
//  Created by Connor Monks on 3/16/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class RecentsAlbumView: UIImageView {

    /*MARK: PROPERTIES*/
    var itemWithImage: BasicSong!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    //Do some setup stuff
    /*MARK: METHODS*/
    func setUp(_ song: BasicSong){
        
        //set up the border
        layer.cornerRadius = 5
        clipsToBounds = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        
        //Add the song info
        image = song.getImage()
        itemWithImage = song
    }
}
