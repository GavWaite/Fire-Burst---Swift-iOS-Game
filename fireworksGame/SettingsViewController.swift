//
//  SettingsViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 31/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var settings: SettingsData?
    var model: Highscores?
    
    @IBOutlet weak var settingsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = SettingsData.Static.instance
        model = Highscores.Static.instance
        settingsSwitch.isOn = settings!.mutedSound
    }
    
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        settings!.mutedSound = settingsSwitch.isOn
        var saveData = SuperSimpleSave()
        saveData.savedScores = self.model!.scores
        saveData.soundMute = self.settings!.mutedSound
        Persistence.save(saveData)
        println("Saved settings data")

        
    }

}
