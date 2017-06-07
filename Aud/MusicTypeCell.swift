//
//  MusicTypeCell.swift
//  Aud
//
//  Created by Connor Monks on 6/6/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class MusicTypeCell: UITableViewCell {

    @IBOutlet weak var musicPlayerImage: UIImageView!
    @IBOutlet weak var musicPlayerLabel: UILabel!
    
    @IBOutlet weak var checkMrk: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
