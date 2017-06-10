//
//  PersonDetailCell.swift
//  Aud
//
//  Created by Connor Monks on 6/9/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class PersonDetailCell: UITableViewCell {
    
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
