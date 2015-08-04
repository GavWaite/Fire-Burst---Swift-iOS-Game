//
//  SettingsData.swift
//  fireworksGame
//
//  Created by Gavin Waite on 31/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation

class SettingsData {
    
    var mutedSound = false
    
    struct Static {
        static let instance = SettingsData()
    }
}