//
//  firework.swift
//  fireworksGame
//
//  Created by Gavin Waite on 26/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import SpriteKit

enum rocketColor {
    case red
    case yellow
    case green
}

class firework: SKSpriteNode {
    var type: rocketColor = .red
    
}