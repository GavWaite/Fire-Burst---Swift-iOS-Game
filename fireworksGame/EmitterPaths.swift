//
//  EmitterPaths.swift
//  fireworksGame
//
//  Created by Gavin Waite on 04/08/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation

class EmitterPaths {

    // Dictionary of color string to path string
    var emitterPathDictionary: [String : String] = [
        "red" : Bundle.main.path(forResource: "RedFireworksSparks", ofType: "sks")!,
        "yellow" : Bundle.main.path(forResource: "YellowFireworksSparks", ofType: "sks")!,
        "green" : Bundle.main.path(forResource: "GreenFireworksSparks", ofType: "sks")!,
        "pink" : Bundle.main.path(forResource: "PinkFireworksSparks", ofType: "sks")!,
        "purple" : Bundle.main.path(forResource: "PurpleFireworksSparks", ofType: "sks")!,
        "orange" : Bundle.main.path(forResource: "OrangeFireworksSparks", ofType: "sks")!,
        "blue" : Bundle.main.path(forResource: "BlueFireworksSparks", ofType: "sks")!,
        "trail" : Bundle.main.path(forResource: "flameTrail", ofType: "sks")!
    ]
}
