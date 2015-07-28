//
//  MenuViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 27/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    
    var highscores: Highscores?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highscores = Highscores()
    }
}