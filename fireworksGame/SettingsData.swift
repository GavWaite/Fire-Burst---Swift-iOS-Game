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
    
    //http://stackoverflow.com/questions/27978376/lets-make-mvc-singletons-and-data-sharing-across-multiple-view-controllers-cl
    struct Static {
        static let instance = SettingsData()
    }
}