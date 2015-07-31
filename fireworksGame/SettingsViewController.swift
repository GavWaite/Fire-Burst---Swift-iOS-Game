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
    
    @IBOutlet weak var settingsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = SettingsData.Static.instance
        settingsSwitch.on = settings!.mutedSound
    }
    
    
    @IBAction func switchToggled(sender: UISwitch) {
        settings!.mutedSound = settingsSwitch.on
    }

}
