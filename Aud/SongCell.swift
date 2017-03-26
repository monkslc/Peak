//  
//  SongCell.swift
//  Aud
//
//  Created by Connor Monks on 3/11/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class SongCell: UITableViewCell {

    @IBOutlet weak var albumArt: UIImageView!
    
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var songArtist: UILabel!
    
    @IBOutlet weak var songDurationLabel: UILabel!
    
    
    var mediaItemInCell = MPMediaItem()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Draw a corner radius for the image
        albumArt.layer.borderWidth = 1.0
        albumArt.layer.borderColor = UIColor.lightGray.cgColor
        albumArt.layer.cornerRadius = 3
        albumArt.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
