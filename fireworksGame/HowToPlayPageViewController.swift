//
//  HowToPlayPageViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 31/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import UIKit

class HowToPlayPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //weak var dataSource: UIPageViewControllerDataSource? = HowToPlayContentViewController
    var data = TutorialData()
    //var pageViewController : HowToPlayContentViewController!
//    self.dataSource = self
//    self.delegate = self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(0)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let VC = viewController as? HowToPlayContentViewController{
            switch VC.itemIndex{
            case 0:
                return nil
            default:
                return self.viewControllerAtIndex(VC.itemIndex - 1)
            }
        }
        else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let VC = viewController as? HowToPlayContentViewController{
            switch VC.itemIndex{
            case 5:
                return nil
            default:
                return self.viewControllerAtIndex(VC.itemIndex + 1)
            }
        }
        else {
            return nil
        }
    }
    
    func viewControllerAtIndex(ind: Int)-> HowToPlayContentViewController{
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HowToPlayContentViewController") as? HowToPlayContentViewController
        pageContentViewController!.itemIndex = ind
        
        return pageContentViewController!
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return data.tutorialTexts.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    

    
    
}
