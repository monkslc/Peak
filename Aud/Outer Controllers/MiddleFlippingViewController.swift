//
//  MiddleFlippingViewController.swift
//  Aud
//
//  Created by Cameron Monks on 6/6/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//
/*
import UIKit

class MiddleFlippingViewController: UIViewController {
    
    var libraryViewController: LibraryViewController {
        return childViewControllers[0] as! LibraryViewController
    }
    var musicTypeController: MusicTypeController {
        return childViewControllers[1] as! MusicTypeController
    }
    
    private var isFlipped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let middleVc = myStoryBoard.instantiateViewController(withIdentifier: "mainMiddleVcID") as! LibraryViewController
        middleVc.delegate = parent as? BeastController
        middleVc.libraryUpdatedDelegate = self
        
        addChildViewController(middleVc)
        self.view.addSubview(middleVc.view)
        middleVc.didMove(toParentViewController: self)
        
        let musicTypeVC = myStoryBoard.instantiateViewController(withIdentifier: "musicTypePlayerID") as! MusicTypeController
        addChildViewController(musicTypeVC)
        view.addSubview(musicTypeVC.view)
        musicTypeVC.didMove(toParentViewController: self)
        
        musicTypeVC.view.removeFromSuperview()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func flipView() {
        if isFlipped {
            UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
                
                self.view.addSubview(self.musicTypeController.view)
                
                self.libraryViewController.view.removeFromSuperview()
                
            }, completion: { (Bool) -> Void in
                
                self.isFlipped = false
            })
        }
        else {
            UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
                
                self.view.addSubview(self.libraryViewController.view)
                
                self.musicTypeController.view.removeFromSuperview()
                
            }, completion: { (Bool) -> Void in
                
                self.isFlipped = true
            })
        }
    }
        
}
*/
 
