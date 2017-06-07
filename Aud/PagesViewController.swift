//
//  PagesViewController.swift
//  Peak
//
//  Created by Cameron Monks on 6/4/17.
//  Copyright © 2017 Connor Monks. All rights reserved.
//

import UIKit

protocol SongsLoaded {
    func songsLoaded(count: Int)
}

class PagesViewController: UIViewController, UIScrollViewDelegate, SongsLoaded {

    var horizontalScrollView: UIScrollView!
    var verticalScrollViews: [UIScrollView] = []
    
    static let halfOfSpaceBetween: CGFloat = 16
    
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
        print(childViewControllers.count)
        return childViewControllers[1] as! LibraryViewController
    }
    var viewController: UIViewController {
        return childViewControllers[pageIndex]
    }
    
    var bluetoothHeight: CGFloat {
        return self.view.frame.height - 58
    }
    var libraryHeight: CGFloat {
        
        var rowHeight: CGFloat = 100
        if libraryViewController.library.visibleCells.count > 0 {
            rowHeight = libraryViewController.library.visibleCells[0].frame.height
        }
        
        return max(self.view.frame.height, CGFloat(CGFloat(itemsCount) * rowHeight))
    }
    
    var itemsCount = 0
    
    var alreadyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //NotificationCenter.default.addObserver(self, selector: #selector(libraryUpdated(notification:)), name: Notification.Name.systemMusicPlayerLibraryChanged, object: nil)
        
        // Do any additional setup after loading the view.
        //setUpScrollView()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(libraryUpdated(notiication:)), name: Notification.Name.systemMusicPlayerLibraryChanged, object: nil)
        
        
        setUpScrollView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Private Functions
    
    private func pageSize(at index: Int) -> CGFloat {
        switch index {
        case 0:
            return bluetoothHeight
        case 1:
            return libraryHeight
        default:
            return self.view.frame.height
        }

    }
    
    private func setUpScrollView() {
        
        self.view.backgroundColor = UIColor.green
        
        let topBarHeight: CGFloat = 58
        
        horizontalScrollView = UIScrollView(frame: CGRect(x: -PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: self.view.frame.height))
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.delegate = self
        
        let bluetoothVc = storyboard?.instantiateViewController(withIdentifier: "bluetoothVcID") as! PopOverBluetoothViewController
        
        let middleVc = storyboard?.instantiateViewController(withIdentifier: "mainMiddleVcID") as! LibraryViewController
        middleVc.delegate = parent as? LibraryViewControllerDelegate
        middleVc.libraryUpdatedDelegate = self
        
        for (index, vc) in [bluetoothVc, middleVc].enumerated() {
            
            let newVerticalScrollView = UIScrollView(frame: CGRect(x: CGFloat(index) * horizontalScrollView.frame.width + PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newVerticalScrollView.alwaysBounceVertical = true
            
            self.addChildViewController(vc)
            newVerticalScrollView.addSubview(vc.view)
            horizontalScrollView.addSubview(newVerticalScrollView)
            verticalScrollViews.append(horizontalScrollView)
            vc.didMove(toParentViewController: self)
            
            vc.view.layer.cornerRadius = 25
            
            newVerticalScrollView.contentSize = CGSize(width: newVerticalScrollView.frame.width, height: pageSize(at: index))
            vc.view.frame = CGRect(x: 0, y: topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: index))
        }
        
        horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.width * 2, height: horizontalScrollView.frame.height)
        horizontalScrollView.contentOffset = CGPoint(x: horizontalScrollView.frame.width, y: 0)
        
        self.view.addSubview(horizontalScrollView)
    }
 
    
    // Scroll Delegates
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        /*
        switch pageIndex {
        case 0:
            innerScrollView.frame.size = CGSize(width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: pageIndex))
            
            innerScrollView.contentSize = CGSize(width: innerScrollView.frame.width * 2, height: innerScrollView.frame.height)
            innerScrollView.contentOffset = CGPoint(x: CGFloat(pageIndex) * innerScrollView.frame.width, y: 0)
            
            outerScrollView.contentSize = CGSize(width: outerScrollView.frame.width, height: innerScrollView.frame.maxY)
        case 1:
            innerScrollView.frame.size = CGSize(width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: pageIndex))
            
            innerScrollView.contentSize = CGSize(width: innerScrollView.frame.width * 2, height: innerScrollView.frame.height)
            innerScrollView.contentOffset = CGPoint(x: innerScrollView.frame.width, y: 0)
            
            outerScrollView.contentSize = CGSize(width: outerScrollView.frame.width, height: innerScrollView.frame.maxY)
        default:
            break
        }
 */
    }
    
    
    // Notification
    
    func libraryUpdated(notification: NSNotification) {
        
        if verticalScrollViews.count > 1 {
            verticalScrollViews[1].contentSize = CGSize(width: self.view.frame.width, height: libraryHeight)
        }
    }

    func songsLoaded(count: Int) {
        
        if alreadyLoaded || count <= 2 {
            return
        }
        
        alreadyLoaded = true
        
        itemsCount = count
        
        var rowHeight: CGFloat = 100
        if libraryViewController.library.visibleCells.count > 0 {
            rowHeight = libraryViewController.library.visibleCells[0].frame.height
        }
        
        for vc in childViewControllers {
            vc.didMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        
        for view in verticalScrollViews {
            view.removeFromSuperview()
        }
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        
        setUpScrollView()
        
        print("COUNT: \(count)")
        print("COUNT: \(libraryViewController.userLibrary.itemsInLibrary.count)")
        /*
        print(horizontalScrollView.contentSize)
        print(verticalScrollViews[1].contentSize)
        let foo = horizontalScrollView.contentSize
        verticalScrollViews[1].contentSize = CGSize(width: self.view.frame.width, height: CGFloat(count) * rowHeight + 100)
        horizontalScrollView.contentSize = foo
        print(horizontalScrollView.contentSize)
        print(verticalScrollViews[1].contentSize)
        */
    }
}
