//
//  GameOverViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 27/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import UIKit

class GameOverViewController: UIViewController {
    
    var score = Highscores.Static.instance
    

    @IBOutlet weak var addScoreButtonOutlet: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    
    @IBAction func addScoreButton(sender: AnyObject) {
        var inputTextField: UITextField?
        let namePrompt = UIAlertController(title: "Enter Name", message: "Entering name for leaderboard", preferredStyle: UIAlertControllerStyle.Alert)
        
        namePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let currentScoreForName = self.score.scores[inputTextField!.text]
            let newScore = self.score.tempScore
            if newScore > currentScoreForName {
                self.score.scores[inputTextField!.text] = self.score.tempScore
                self.scoreLabel.text = "\(self.score.tempScore) ✅"
                self.descripLabel.text = "New Personal Best!"
            }
            else {
                self.scoreLabel.text = "\(self.score.tempScore) ❌"
                self.descripLabel.text = "Previous best: \(currentScoreForName!)"
            }
            self.addScoreButtonOutlet.hidden = true
            var saveData = SuperSimpleSave()
            saveData.savedScores = self.score.scores
            Persistence.save(saveData)
        }))
        
        namePrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
            inputTextField = textField
        })
        
        presentViewController(namePrompt, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score.tempScore)"
    }
    
}