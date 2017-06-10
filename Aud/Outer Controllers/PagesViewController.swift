//
//  PagesViewController.swift
//  Peak
//
//  Created by Cameron Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit
import StoreKit
import CloudKit
import MediaPlayer

protocol SongsLoaded {
    func songsLoaded(count: Int)
}

class PagesViewController: UIViewController, UIScrollViewDelegate, SongsLoaded {
    
    var backgroundScrollView: UIScrollView!
    
    var horizontalScrollView: UIScrollView!
    var verticalScrollViews: [UIScrollView] = []
    
    static let halfOfSpaceBetween: CGFloat = 16
    
    static let topBarHeight: CGFloat = 40
    
    var pageIndex: Int {
        set {
            horizontalScrollView.setContentOffset(CGPoint(x: CGFloat(newValue) * horizontalScrollView.frame.width, y: 0), animated: true)
        }
        get {
            return Int(round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width))
        }
    }
    var bluetoothViewController: PopOverBluetoothViewController {
        return childViewControllers[0] as! PopOverBluetoothViewController
    }
    var libraryViewController: LibraryViewController {
        print("\(childViewControllers.count) > 1 CHILDREN")
        print(childViewControllers[1])
        return childViewControllers[1] as! LibraryViewController
    }
    var musicTypeController: MusicTypeController {
        return childViewControllers[2] as! MusicTypeController
    }
    var viewController: UIViewController {
        return childViewControllers[pageIndex]
    }
    
    var bluetoothHeight: CGFloat {
        return self.view.frame.height - 58
    }
    var musicPlayerHeight: CGFloat {
        return self.view.frame.height - 58
    }
    var libraryHeight: CGFloat {
        
        var rowHeight: CGFloat = 75
        if libraryViewController.library.visibleCells.count > 0 {
            rowHeight = libraryViewController.library.visibleCells[0].frame.height
        }
        
        print("ROW HEIGHT: \(rowHeight)")
        print("COUNT: \(itemsCount)")
        
        return max(self.view.frame.height, CGFloat(CGFloat(itemsCount) * rowHeight + 175))
    }
    
    var itemsCount = 0
    
    var isMiddleViewFlipped = false
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gradientView = BackgroundView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 1.5, height: self.view.frame.height))
        gradientView.lightColor = UIColor.peakColor //UIColor(colorLiteralRed: 0.5, green: 0.1, blue: 0.9, alpha: 1.0)
        gradientView.darkColor = UIColor.peakColorDarker //UIColor(colorLiteralRed: 0.7, green: 0.5, blue: 0.9, alpha: 0.0)
        
        /*
        let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 1.5, height: self.view.frame.height))
        backgroundImageView.image = #imageLiteral(resourceName: "landscape.jpg")
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //backgroundImageView.addSubview(blurEffectView)
        */
        
        backgroundScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backgroundScrollView.contentSize = CGSize(width: gradientView.frame.width, height: gradientView.frame.height)
        backgroundScrollView.isScrollEnabled = false
        
        backgroundScrollView.addSubview(gradientView)
        self.view.addSubview(backgroundScrollView)
        
        setUpScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Private Functions
    
    private func pageSize(at index: Int, includingFlip: Bool) -> CGFloat {
        switch index {
        case 0:
            return bluetoothHeight
        case 1:
            return includingFlip && isMiddleViewFlipped ? musicPlayerHeight : libraryHeight
        default:
            return self.view.frame.height
        }

    }
    
    private func setUpScrollView() {
        
        print("PagesViewController setUpScrollView START")
        
        self.view.backgroundColor = UIColor.green
        
        horizontalScrollView = UIScrollView(frame: CGRect(x: -PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: self.view.frame.height))
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.delegate = self
        
        let bluetoothVc = storyboard?.instantiateViewController(withIdentifier: "bluetoothVcID") as! PopOverBluetoothViewController
        
        let middleVc = storyboard?.instantiateViewController(withIdentifier: "mainMiddleVcID") as! LibraryViewController
        middleVc.delegate = parent as? BeastController
        middleVc.libraryUpdatedDelegate = self
        
        for (index, vc) in [bluetoothVc, middleVc].enumerated() {
            
            let newVerticalScrollView = UIScrollView(frame: CGRect(x: CGFloat(index) * horizontalScrollView.frame.width + PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newVerticalScrollView.alwaysBounceVertical = true
            
            self.addChildViewController(vc)
            newVerticalScrollView.addSubview(vc.view)
            horizontalScrollView.addSubview(newVerticalScrollView)
            verticalScrollViews.append(newVerticalScrollView)
            vc.didMove(toParentViewController: self)
            
            vc.view.layer.cornerRadius = 12
            
            newVerticalScrollView.contentSize = CGSize(width: newVerticalScrollView.frame.width, height: pageSize(at: index, includingFlip: false))
            vc.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: index, includingFlip: false))
        }
        
        let musicTypeVC = storyboard?.instantiateViewController(withIdentifier: "musicTypePlayerID") as! MusicTypeController
        addChildViewController(musicTypeVC)
        //verticalScrollViews[1].addSubview(musicTypeVC.view)
        musicTypeVC.didMove(toParentViewController: self)
        musicTypeVC.view.layer.masksToBounds = true
        musicTypeVC.view.layer.cornerRadius = 12
        musicTypeVC.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: musicPlayerHeight)
        //musicTypeVC.view.removeFromSuperview()
        
        horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.width * 2, height: horizontalScrollView.frame.height)
        horizontalScrollView.contentOffset = CGPoint(x: horizontalScrollView.frame.width, y: 0)
        
        self.view.addSubview(horizontalScrollView)
        
        print("PagesViewController setUpScrollView END")
    }
 
    
    func songsLoaded(count: Int) {
        
        if count <= 2 {
            return
        }
        if itemsCount == count {
            return
        }
        
        itemsCount = count
        
        verticalScrollViews[1].contentSize = CGSize(width: self.view.frame.width, height: pageSize(at: 1, includingFlip: true))
        libraryViewController.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: self.view.frame.width, height: libraryHeight)
    }
    
    func flipMiddlePageToBack() {
        
        print("\n\n\nVERTICAL VIEW")
        print(Thread.current.isMainThread)
        print(self.verticalScrollViews[1].subviews.count)
        print(self.verticalScrollViews[1] == self.libraryViewController.view.superview)
        UIView.transition(with: verticalScrollViews[1], duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
            
            self.verticalScrollViews[1].addSubview(self.musicTypeController.view)
            self.libraryViewController.view.removeFromSuperview()
            
        }, completion: { (Bool) -> Void in
            self.verticalScrollViews[1].contentSize = CGSize(width: self.view.frame.width, height: self.musicPlayerHeight)
            self.isMiddleViewFlipped = true
        })
    }

    func flipMiddlePageToFront() {
        
        UIView.transition(with: verticalScrollViews[1], duration: 0.5, options: .transitionFlipFromRight, animations: { () -> Void in
            
            self.verticalScrollViews[1].addSubview(self.libraryViewController.view)
            self.musicTypeController.view.removeFromSuperview()
            
        }, completion: { (Bool) -> Void in
            self.verticalScrollViews[1].contentSize = CGSize(width: self.view.frame.width, height: self.libraryHeight)
            self.isMiddleViewFlipped = false
            self.libraryViewController.userLibrary.fetchLibrary()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let smallPointx = scrollView.contentOffset.x
        let smallWith = scrollView.contentSize.width - scrollView.frame.width
        
        let largeWidth = backgroundScrollView.contentSize.width - backgroundScrollView.frame.width
        let largeX = (smallPointx / smallWith) * largeWidth
        
        //let percent = scrollView.contentOffset.x / scrollView.contentSize.width
        var beginingX = largeX //percent * backgroundScrollView.contentSize.width
        if beginingX < 0 {
            beginingX = 0
        }
        if beginingX + backgroundScrollView.frame.width > backgroundScrollView.contentSize.width {
            beginingX = backgroundScrollView.contentSize.width - backgroundScrollView.frame.width
        }
        backgroundScrollView.setContentOffset(CGPoint(x: beginingX, y: 0), animated: false)
    }
}
