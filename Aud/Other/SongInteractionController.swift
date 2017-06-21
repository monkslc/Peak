//
//  SongInteractionController.swift
//  Peak
//
//  Created by Connor Monks on 4/30/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import MediaPlayer
import UIKit

class SongInteractionController: UIViewController {

    /*MARK: Properties*/

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerOrMusicTypeChanged), name: .playerTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerOrMusicTypeChanged), name: .musicTypeChanged, object: nil)
    }
    
    @IBOutlet weak var songProgressLabel: SongProgressLabel!
    
    @IBOutlet weak var durationLabel: SongProgressLabel!
    
    @IBOutlet weak var songInfoSegment: UISegmentedControl!
    
    @IBOutlet weak var songInfoDisplay: SICSongInfoDisplay!
    
    @IBOutlet weak var songProgressSlider: SicSongProgress!
    
    @IBOutlet weak var volumeSlider: MPVolumeView!
    
    @IBOutlet weak var topVolumeImage: UIImageView!
    
    @IBOutlet weak var bottomVolumeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the duration label enum
        songProgressLabel.progressType = .Beg
        durationLabel.progressType = .End
        
        //Set up the value change for songInfoDisplay
        songInfoSegment.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        
        //Set up the song progress slider
        songProgressSlider.setThumbImage(UIImage(), for: .normal)
        
        //Set up the volume view
        volumeSlider.showsRouteButton = false
        
        songInfoSegment.tintColor = UIColor.peakColor
        volumeSlider.tintColor = UIColor.peakColor
        songProgressSlider.tintColor = UIColor.peakColor
    }
    

    /*MARK: User Interaction Methods*/
    @objc func segmentValueChanged(){
        //Get's called when the user changes value on the segment display
        
        songInfoDisplay.displayingSegment = songInfoSegment.selectedSegmentIndex
    }
    
    
    /*MARK: Notification Methods*/
    @objc func playerOrMusicTypeChanged(){
        
        DispatchQueue.main.async {
            
            if peakMusicController.playerType == .Contributor || peakMusicController.musicType == .Guest{
                
                self.volumeSlider.isHidden = true
                self.topVolumeImage.isHidden = true
                self.bottomVolumeImage.isHidden = true
            } else{
                
                self.topVolumeImage.isHidden = false
                self.bottomVolumeImage.isHidden = false
                self.volumeSlider.isHidden = false
            }
        }
        
    }
    
    
    
}
