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

protocol TapDelegate {
    func tapDelegateScreenTapped(tap: UITouch) -> Bool
}

protocol Page {
    func pageDidStick()
    func pageIsShown()
    func pageLeft()
}

class PagesViewController: UIViewController, UIScrollViewDelegate, SongsLoaded, PageScrolViewDelagate, TapDelegate {
    
    var backgroundScrollView: UIScrollView!
    
    var horizontalScrollView: UIScrollView!
    var verticalScrollViews: [UIScrollView] = []
    
    static let halfOfSpaceBetween: CGFloat = 16
    
    static let topBarHeight: CGFloat = 58
    
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
        //print("\(childViewControllers.count) > 1 CHILDREN")
        //print(childViewControllers[1])
        return childViewControllers[1] as! LibraryViewController
    }
    var musicTypeController: MusicTypeController {
        return childViewControllers[2] as! MusicTypeController
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
        
        return self.view.frame.height + PagesViewController.topBarHeight
        //return max(self.view.frame.height, CGFloat(CGFloat(itemsCount) * rowHeight + 175))
    }
    
    var lastPageIndex = 1
    
    var itemsCount = 0
    
    var isMiddleViewFlipped = false
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.tapGestureDelegate = self
        
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 1.5, height: self.view.frame.height))//BackgroundView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 1.5, height: self.view.frame.height))
        gradientView.firstColor = UIColor.peakColor //UIColor(colorLiteralRed: 0.5, green: 0.1, blue: 0.9, alpha: 1.0)
        gradientView.secondColor = UIColor.peakColorLighter //UIColor(colorLiteralRed: 0.7, green: 0.5, blue: 0.9, alpha: 0.0)
        
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
    
    private func getViewControllerAtPageIndex(_ index: Int) -> UIViewController {
        switch index {
        case 0:
            return bluetoothViewController
        default:
            return isMiddleViewFlipped ? musicTypeController : libraryViewController
        }
    }
    
    private func setUpScrollView() {
        
        print("PagesViewController setUpScrollView START")
        
        self.view.backgroundColor = UIColor.green
        
        horizontalScrollView = UIScrollView(frame: CGRect(x: -PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width + PagesViewController.halfOfSpaceBetween * 2, height: self.view.frame.height))
        
        horizontalScrollView.isPagingEnabled = true
        //horizontalScrollView.canCancelContentTouches = true
        //horizontalScrollView.delaysContentTouches = true
        horizontalScrollView.delegate = self
        
        //horizontalScrollView.isScrollEnabled = false
        
        let bluetoothVc = storyboard?.instantiateViewController(withIdentifier: "bluetoothVcID") as! PopOverBluetoothViewController
        
        let middleVc = storyboard?.instantiateViewController(withIdentifier: "mainMiddleVcID") as! LibraryViewController
        middleVc.delegate = parent as? BeastController
        middleVc.libraryUpdatedDelegate = self
        
        for (index, vc) in [bluetoothVc, middleVc].enumerated() {
            
            let newVerticalScrollView = PageScrolView(frame: CGRect(x: CGFloat(index) * horizontalScrollView.frame.width + PagesViewController.halfOfSpaceBetween, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newVerticalScrollView.alwaysBounceVertical = true
            newVerticalScrollView.pageScrolViewDelagate = self
            newVerticalScrollView.delegate = self
            newVerticalScrollView.canCancelContentTouches = false
            newVerticalScrollView.delaysContentTouches = false
            newVerticalScrollView.scrollsToTop = false
            
            self.addChildViewController(vc)
            newVerticalScrollView.addSubview(vc.view)
            horizontalScrollView.addSubview(newVerticalScrollView)
            verticalScrollViews.append(newVerticalScrollView)
            vc.didMove(toParentViewController: self)
            
            vc.view.layer.cornerRadius = 12
            
            vc.view.frame = CGRect(x: 0, y: PagesViewController.topBarHeight, width: horizontalScrollView.frame.width - PagesViewController.halfOfSpaceBetween * 2, height: pageSize(at: index, includingFlip: false))
            newVerticalScrollView.contentSize = CGSize(width: newVerticalScrollView.frame.width, height: vc.view.frame.maxY)
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
        
        (libraryViewController.library as UIScrollView).delegate = self
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
            //self.libraryViewController.userLibrary.recents = []
            //self.libraryViewController.userLibrary.itemsInLibrary = []
            //self.libraryViewController.userLibrary.fetchLibrary()
        })
    }
    
    
/* MARK: Scroll View Delegate */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if horizontalScrollView == scrollView {
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
            /*
        else if isMiddleViewFlipped {
            
        }
        else if verticalScrollViews[1] == scrollView {
            print(verticalScrollViews[1].contentOffset.y - PagesViewController.topBarHeight)
            if verticalScrollViews[1].contentOffset.y >= PagesViewController.topBarHeight {
                verticalScrollViews[1].isScrollEnabled = false
                verticalScrollViews[1].setContentOffset(CGPoint(x: 0, y: PagesViewController.topBarHeight), animated: false)
                libraryViewController.library.isScrollEnabled = true
            }
        }
        else if (libraryViewController.library as UIScrollView) == scrollView {
            if scrollView.contentOffset.y <= 0 {
                verticalScrollViews[1].setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                verticalScrollViews[1].isScrollEnabled = true
                libraryViewController.library.isScrollEnabled = false
                libraryViewController.library.bounces = false
            }
            else if scrollView.contentOffset.y > 10 {
                libraryViewController.library.bounces = true
            }
            else  {
                libraryViewController.library.bounces = false
            }
        }
 */
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if horizontalScrollView == scrollView {
            let index = pageIndex
            
            if index == lastPageIndex {
                return
            }
            
            if let page = getViewControllerAtPageIndex(index) as? Page {
                page.pageDidStick()
            }
            
            if let page = getViewControllerAtPageIndex(lastPageIndex) as? Page {
                page.pageLeft()
            }
            
            lastPageIndex = index
        }
        else if verticalScrollViews[1] == scrollView {
            
        }
    }
    
    
/* MARK: PagesScrollViewDelegate */
    
    func changeInTouches(currentScrollView: PageScrolView, change: CGFloat) {
        
        let innerScrollView: UIScrollView! = (currentScrollView == verticalScrollViews[1]) ? (isMiddleViewFlipped ? nil : libraryViewController.library) : nil
        
        func moveOuterScroll(change: CGFloat) {
            let newY = currentScrollView.contentOffset.y - change
            currentScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
        }
        func moveInnerScroll(change: CGFloat) {
            // penis
            if innerScrollView == self.libraryViewController.library {
                self.libraryViewController.scrollViewDidScroll(innerScrollView)
            }
            let newY = innerScrollView.contentOffset.y - change
            innerScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
        }
        
        
        // Make sure the imporssible doesnt happen
        if currentScrollView.contentOffset.y > PagesViewController.topBarHeight {
            currentScrollView.setContentOffset(CGPoint(x: 0, y: PagesViewController.topBarHeight), animated: false)
        }
        if innerScrollView != nil && innerScrollView.contentOffset.y < 0 {
            innerScrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        
        if innerScrollView != nil && innerScrollView.contentOffset.y > 0 {
            //print("1")
            moveInnerScroll(change: change)
        }
        else if currentScrollView.contentOffset.y >= PagesViewController.topBarHeight {
            if change < 0 && innerScrollView != nil {
                //print("2")
                moveInnerScroll(change: change)
            }
            else {
                //print("3")
                moveOuterScroll(change: change)
            }
        }
        else {
            //print("4")
            moveOuterScroll(change: change)
        }
    }
    
    func useVelocityAtEndOfSwipe(currentScrollView: PageScrolView, velocity: CGFloat) {
        
        if horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width != CGFloat(pageIndex) {
            swipeHorizontally(currentScrollView: currentScrollView, velocity: 0)
        }
        
        let innerScrollView: UIScrollView! = (currentScrollView == verticalScrollViews[1]) ? (isMiddleViewFlipped ? nil : libraryViewController.library) : nil
        
        let velocity = velocity > 2000 ? 2000 : velocity < -2000 ? -2000 : velocity
        
        func moveOuterScroll(change: CGFloat) {
            
            let change = change / 5
            
            var newY = currentScrollView.contentOffset.y - change
            var leftOver: CGFloat = 0
            if newY < 0 {
                leftOver = -newY
                newY = 0
            }
            
            UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                
                currentScrollView.contentOffset = CGPoint(x: 0, y: newY)
            }, completion: { _ in
                
                if leftOver != 0 {
                    moveInnerScroll(change: leftOver)
                }
                
                if currentScrollView.contentOffset.y > PagesViewController.topBarHeight {
                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                        
                        currentScrollView.contentOffset = CGPoint(x: 0, y: PagesViewController.topBarHeight)
                    }, completion: nil)
                }
            })
            
            //verticalScrollViews[1].setContentOffset(CGPoint(x: 0, y: newY), animated: false)
        }
        func moveInnerScroll(change: CGFloat) {
            
            if innerScrollView == nil {
                return
            }
            
            let change = change / 5 //min(self.view.frame.height, change)
            
            var newY = innerScrollView.contentOffset.y - change //min(self.view.frame.height, change)
            var leftovers: CGFloat = 0
            if newY < 0 {
                leftovers = -newY
                newY = 0
            }
            
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                
                // penis
                if innerScrollView == self.libraryViewController.library {
                    self.libraryViewController.scrollViewDidScroll(innerScrollView)
                }
                innerScrollView.contentOffset = CGPoint(x: 0, y: newY)
            }, completion: { _ in
                if leftovers != 0 {
                    moveOuterScroll(change: leftovers)
                }
                
                if innerScrollView.contentOffset.y > innerScrollView.contentSize.height - innerScrollView.frame.height {
                    
                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                        
                        // penis
                        if innerScrollView == self.libraryViewController.library {
                            self.libraryViewController.scrollViewDidScroll(innerScrollView)
                        }
                        innerScrollView.contentOffset = CGPoint(x: 0, y: innerScrollView.contentSize.height - innerScrollView.frame.height)
                    }, completion: nil)
                }
                
            })
        }
        
        
        
        if currentScrollView.contentOffset.y < 0 {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                currentScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
        }
        if innerScrollView != nil && innerScrollView.contentOffset.y > innerScrollView.contentSize.height - innerScrollView.frame.height {
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                innerScrollView.contentOffset = CGPoint(x: 0, y: innerScrollView.contentSize.height - innerScrollView.frame.height)
            }, completion: nil)
        }
        
        if currentScrollView.contentOffset.y > PagesViewController.topBarHeight {
            currentScrollView.setContentOffset(CGPoint(x: 0, y: PagesViewController.topBarHeight), animated: false)
        }
        if innerScrollView != nil && innerScrollView.contentOffset.y < 0 {
            innerScrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        if innerScrollView != nil && innerScrollView.contentOffset.y > 0 {
            //print("1")
            moveInnerScroll(change: velocity)
        }
        else if currentScrollView.contentOffset.y >= PagesViewController.topBarHeight {
            if velocity < 0 {
                //print("2")
                moveInnerScroll(change: velocity)
            }
            else {
                //print("3")
                moveOuterScroll(change: velocity)
            }
        }
        else {
            //print("4")
            moveOuterScroll(change: velocity)
        }
    }
    
    func swipeHorizontally(currentScrollView: PageScrolView, translation: CGFloat) {
        let newX = horizontalScrollView.contentOffset.x - translation
        horizontalScrollView.setContentOffset(CGPoint(x: newX, y: 0), animated: false)
    }
    
    func swipeHorizontally(currentScrollView: PageScrolView, velocity: CGFloat) {
        
        if currentScrollView.contentOffset.y < 0 {
            currentScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        var index = 0
        var lowestDistance = abs(self.horizontalScrollView.contentOffset.x - self.verticalScrollViews[0].frame.minX)
        for i in 1..<self.verticalScrollViews.count {
            let newDistance = abs(self.horizontalScrollView.contentOffset.x - self.verticalScrollViews[i].frame.minX)
            
            if newDistance <= lowestDistance {
                index = i
                lowestDistance = newDistance
            }
        }
        
        let realIndex = horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width
        
        print(velocity)
        if abs(velocity) > 500 { // } || abs(realIndex - CGFloat(index)) > 50 {
            if realIndex != CGFloat(index) {
                if realIndex > CGFloat(index) && self.verticalScrollViews.count - 1 > index {
                    index += 1
                }
                else if index > 0 && realIndex < CGFloat(self.verticalScrollViews.count - 1) {
                    index -= 1
                }
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            
            self.horizontalScrollView.contentOffset = CGPoint(x: CGFloat(index) * self.horizontalScrollView.frame.width, y: 0)
        }, completion: nil)
        
        /*
        var newVelocity: CGFloat = 0
        if velocity > 0 {
            newVelocity = -horizontalScrollView.contentOffset.x
        }
        else {
            newVelocity = horizontalScrollView.frame.width - horizontalScrollView.contentOffset.x
        }
        
        let velocity = newVelocity
        
        let newX = self.horizontalScrollView.contentOffset.x - velocity
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
            
            self.horizontalScrollView.contentOffset = CGPoint(x: newX, y: 0)
        }, completion: {  _ in
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                
                var index = 0
                var lowestDistance = abs(self.horizontalScrollView.contentOffset.x - self.verticalScrollViews[0].frame.minX)
                for i in 1..<self.verticalScrollViews.count {
                    let newDistance = abs(self.horizontalScrollView.contentOffset.x - self.verticalScrollViews[i].frame.minX)
                    
                    if newDistance <= lowestDistance {
                        index = i
                        lowestDistance = newDistance
                    }
                }
                
                self.horizontalScrollView.contentOffset = CGPoint(x: CGFloat(index) * self.horizontalScrollView.frame.width, y: 0)
            }, completion: nil)
        })
 */
    }
    
/* MARK: UITAPDELEGATE */
    func tapDelegateScreenTapped(tap: UITouch) -> Bool {
        
        if tap.location(in: self.view).y > 50 {
            return false
        }
        
        if pageIndex < 0 || pageIndex >= verticalScrollViews.count {
            return false
        }
        
        let currentScrollView = verticalScrollViews[pageIndex]
        
        let innerScrollView: UIScrollView! = (currentScrollView == verticalScrollViews[1]) ? (isMiddleViewFlipped ? nil : libraryViewController.library) : nil
        
        if innerScrollView != nil && innerScrollView.contentOffset.y > 0 {
            
            
            innerScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
        else {
            currentScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
        
        return true
    }
}
