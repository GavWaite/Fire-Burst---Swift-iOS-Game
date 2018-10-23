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
        // http://stackoverflow.com/questions/11068498/connect-uitableview-datasource-delegate-to-base-uiviewcontroller-class
        leaderboard.dataSource = self
        leaderboard.delegate = self
        highscores = Highscores.Static.instance
    }

    
    /////// Set up table view /////////
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highscores!.scores.count
    }
    
    ////////// Fill table view ///////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.basicCell, for: indexPath) 
        cell.textLabel!.text = "\(indexPath.row + 1): \(highscores!.sortedScores[indexPath.row].name)"
        cell.detailTextLabel!.text = "\(highscores!.sortedScores[indexPath.row].value)"
        return cell
    }
}
