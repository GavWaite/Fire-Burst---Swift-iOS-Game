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
    
    var data = TutorialData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(0)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as [AnyObject] as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    func viewControllerAtIndex(_ ind: Int)-> HowToPlayContentViewController{
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "HowToPlayContentViewController") as? HowToPlayContentViewController
        pageContentViewController!.itemIndex = ind
        
        return pageContentViewController!
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return data.tutorialTexts.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    

    
    
}
