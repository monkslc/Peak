//
//  BluetoothTableViewCell.swift
//  Peak
//
//  Created by Cameron Monks on 4/8/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

class BluetoothTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        loader.stopAnimating()
        loader.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            loader.isHidden = false
            loader.startAnimating()
        }
    }
    
}
