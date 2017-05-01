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
    
    @IBOutlet weak var durationLabel: SongProgressLabel!
    
    @IBOutlet weak var songInfoSegment: UISegmentedControl!
    
    @IBOutlet weak var songInfoDisplay: SICSongInfoDisplay!
    
    @IBOutlet weak var songProgressSlider: SicSongProgress!
    
    @IBOutlet weak var volumeSlider: MPVolumeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the duration label enum
        durationLabel.progressType = .End
        
        //Set up the value change for songInfoDisplay
        songInfoSegment.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        
        //Set up the song progres slider
        songProgressSlider.setThumbImage(UIImage(), for: .normal)
        
        //Set up the volume view
        volumeSlider.showsRouteButton = false
        
    }
    

    
    

    /*MARK: User Interaction Methods*/
    func segmentValueChanged(){
        //Get's called when the user changes value on the segment display
        
        songInfoDisplay.displayingSegment = songInfoSegment.selectedSegmentIndex
    }
    
    
}
