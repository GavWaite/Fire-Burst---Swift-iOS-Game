//
//  highscores.swift
//  fireworksGame
//
//  Created by Gavin Waite on 27/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation

struct Score {
    var value: Int
    var name: String
}

class Highscores{
    var scores: [String : Int] = [:]
    var tempScore: Int = 0

    var sortedScores: [Score]{
        var sortedArr = Array(scores.keys).sorted({self.scores[$0] > self.scores[$1]})
        let n = sortedArr.count
        var scoreArr = [Score]()
        
        for i in 0...(n-1){
            let xValue = self.scores[sortedArr[i]]!
            let xName = sortedArr[i]
            var x = Score(value: xValue, name: xName)
            scoreArr.append(x)
        }
        return scoreArr
    }
    
    struct Static {
        static let instance = Highscores()
    }
}