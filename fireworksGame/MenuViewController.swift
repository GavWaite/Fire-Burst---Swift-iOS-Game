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
    var settings: SettingsData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highscores = Highscores.Static.instance
        settings = SettingsData.Static.instance
        if let saveData = Persistence.restore() as? SuperSimpleSave {
            println("Save data loaded successfully")
            highscores!.scores = saveData.savedScores
            settings!.mutedSound = saveData.soundMute
        }
        else {
            println("First time playing, no save data")
        }
        if highscores!.scores.count == 0 {
            highscores!.scores["Developer"] = 15200
            println("Added developer score of 15200")
        }
    }
    
    
    
    }