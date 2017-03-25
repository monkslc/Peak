//
//  VolumeView.swift
//  Peak
//
//  Created by Connor Monks on 3/20/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import MediaPlayer

class VolumeView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var volumeSlider = MPVolumeView()
    var minimumVolumeIcon = UIImageView()
    var maximumVolumeIcon = UIImageView()

    
    func setUp(){
        
        setUpVolumeSlider()
        setUpIcons()
    }
    
    func setUpVolumeSlider(){
        
        volumeSlider = MPVolumeView(frame: CGRect(x: bounds.minX + 40 , y: bounds.midY - 15, width: (bounds.width - 80), height: 30))
        volumeSlider.setRouteButtonImage(nil, for: .normal)
        volumeSlider.showsRouteButton = false
        volumeSlider.tintColor = UIColor.peakColor
        volumeSlider.isUserInteractionEnabled = true
        addSubview(volumeSlider)
    }
    
    func setUpIcons(){
        
        minimumVolumeIcon = UIImageView(frame: CGRect(x: bounds.minX + 25, y: bounds.midY - 7.5, width: 15, height: 15))
        minimumVolumeIcon.image = #imageLiteral(resourceName: "Low Volume Filled-50")
        addSubview(minimumVolumeIcon)
        
        maximumVolumeIcon = UIImageView(frame: CGRect(x: bounds.maxX - 40, y: bounds.midY - 7.5, width: 15, height: 15))
        maximumVolumeIcon.image = #imageLiteral(resourceName: "High Volume Filled-50")
        addSubview(maximumVolumeIcon)
    }
}
