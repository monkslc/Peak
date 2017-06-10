//
//  RecSongCell.swift
//  Aud
//
//  Created by Connor Monks on 6/9/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class RecSongCell: UITableViewCell {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    
    var songID = "Not Set Yet"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
