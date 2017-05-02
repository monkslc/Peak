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
    
    @IBOutlet weak var addToLibraryButton: UIButton!
    
    
    var itemInCell = LibraryItem.MediaItem(MPMediaItem())
    
    //var mediaItemInCell = MPMediaItem()
   
    //var songInCell: Song?
    
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
    
    
    func addItems(){
        
        switch itemInCell{
            
        case .MediaItem(let song):
            albumArt.image = song.artwork?.image(at: CGSize())
            songTitle.text = song.title
            songArtist.text = song.artist
            
        case .GuestItem(let song):
            albumArt.image = song.image
            songTitle.text = song.trackName
            songArtist.text = song.artistName
        }
    }

}
