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
    
    @IBAction func addScoreButton(_ sender: AnyObject) {
        var inputTextField: UITextField?
        //http://stackoverflow.com/questions/24172593/access-input-from-uialertcontroller
        let namePrompt = UIAlertController(title: "Enter Name", message: "Entering name for leaderboard", preferredStyle: UIAlertControllerStyle.alert)
        
        namePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let currentScoreForName = self.score.scores[inputTextField!.text!]
            let newScore = self.score.tempScore
            if newScore > currentScoreForName! {
                self.score.scores[inputTextField!.text!] = self.score.tempScore
                self.scoreLabel.text = "\(self.score.tempScore) ✅"
                self.descripLabel.text = "New Personal Best!"
            }
            else {
                self.scoreLabel.text = "\(self.score.tempScore) ❌"
                self.descripLabel.text = "Previous best: \(currentScoreForName!)"
            }
            self.addScoreButtonOutlet.isHidden = true
            var saveData = SuperSimpleSave()
            saveData.savedScores = self.score.scores
            Persistence.save(saveData)
        }))
        
        namePrompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            //http://stackoverflow.com/questions/6943016/uitextfield-auto-capitalization-type-iphone-app
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            inputTextField = textField
        })
        
        present(namePrompt, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score.tempScore)"
    }
    
}
