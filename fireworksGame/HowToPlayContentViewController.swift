//
//  HowToPlayContentViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 31/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import UIKit

class HowToPlayContentViewController: UIViewController {
    
    // PageView tutorial used:
    // http://swiftiostutorials.com/ios-tutorial-using-uipageviewcontroller-create-content-slider-objective-cswift/
    
    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialTitle: UILabel!
    @IBOutlet weak var tutorialText: UILabel!
    
    var itemIndex: Int = 0

    var data = TutorialData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialTitle.text = data.tutorialTitles[itemIndex]
        tutorialText.text = data.tutorialTexts[itemIndex]
        let imgName = data.tutorialImages[itemIndex]
        tutorialImage!.image = UIImage(named: imgName)
    }
    
}