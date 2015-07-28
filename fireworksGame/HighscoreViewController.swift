//
//  HighscoreViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 27/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import UIKit

struct Identifiers {
    static let basicCell = "scoreCell"
}

class HighscoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var highscores: Highscores?
    
    
    @IBOutlet weak var leaderboard: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboard.dataSource = self
        leaderboard.delegate = self
        highscores = Highscores.Static.instance
    }

    
    /////// Set up table view /////////
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highscores!.scores.count
    }
    
    ////////// Fill table view ///////////
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.basicCell, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = "\(indexPath.row + 1): \(highscores!.sortedScores[indexPath.row].name)"
        cell.detailTextLabel!.text = "\(highscores!.sortedScores[indexPath.row].value)"
        return cell
    }
}