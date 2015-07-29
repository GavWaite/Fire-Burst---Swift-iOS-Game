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
        highscores = Highscores.Static.instance
        if let saveData = Persistence.restore() as? SuperSimpleSave {
            println("success!!")
            highscores!.scores = saveData.savedScores
        }
        else {
            println("failure!!")
        }
        if highscores!.scores.count == 0 {
            highscores!.scores["Developer"] = 100
        }
    }
    
    
    
    }