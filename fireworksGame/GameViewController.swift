//
//  GameViewController.swift
//  fireworksGame
//
//  Created by Gavin Waite on 20/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            var sceneData = Data(bytesNoCopy: path, count: .DataReadingMappedIfSafe, deallocator: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var gameOverObs: NSObjectProtocol?
    var model: GameModel?
    var scores: Highscores?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservers()
        model = GameModel()
        scores = Highscores()
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.size = self.view.frame.size
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.all.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func startObservers() {
        let center = NotificationCenter.default
        let uiQueue = OperationQueue.main
        center.addObserver(self, selector: #selector(GameViewController.gameOver), name: NSNotification.Name(rawValue: "goToGameOver"), object: nil)
    }

    // http://stackoverflow.com/questions/21578391/presenting-uiviewcontroller-from-skscene
    func gameOver() {
        self.performSegue(withIdentifier: "gameOver", sender: self)
    }
}
