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
        "red" : NSBundle.mainBundle().pathForResource("RedFireworksSparks", ofType: "sks")!,
        "yellow" : NSBundle.mainBundle().pathForResource("YellowFireworksSparks", ofType: "sks")!,
        "green" : NSBundle.mainBundle().pathForResource("GreenFireworksSparks", ofType: "sks")!,
        "pink" : NSBundle.mainBundle().pathForResource("PinkFireworksSparks", ofType: "sks")!,
        "purple" : NSBundle.mainBundle().pathForResource("PurpleFireworksSparks", ofType: "sks")!,
        "orange" : NSBundle.mainBundle().pathForResource("OrangeFireworksSparks", ofType: "sks")!,
        "blue" : NSBundle.mainBundle().pathForResource("BlueFireworksSparks", ofType: "sks")!,
        "trail" : NSBundle.mainBundle().pathForResource("flameTrail", ofType: "sks")!
    ]
}