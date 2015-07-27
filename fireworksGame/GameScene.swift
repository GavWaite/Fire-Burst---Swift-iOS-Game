//
//  GameScene.swift
//  fireworksGame
//
//  Created by Gavin Waite on 20/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

//Set the sprite sizes for the rockets
let rocketSize = CGSize(width: 50, height: 60)

var numberOfRockets = 0

let redFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("RedFireworksSparks", ofType: "sks")!
let redFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(redFireworkEmitterPath) as! SKEmitterNode
let yellowFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("YellowFireworksSparks", ofType: "sks")!
let yellowFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(yellowFireworkEmitterPath) as! SKEmitterNode
let greenFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("GreenFireworksSparks", ofType: "sks")!
let greenFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(greenFireworkEmitterPath) as! SKEmitterNode

let fire = SKAction.moveToY(20, duration: 2)
let death = SKAction.removeFromParent()
let wait = SKAction.waitForDuration(1)
let explode = SKAction.sequence([wait, death])

struct fireworksProbabilities {
    static var redP = 100
    static var yelP = 25
    static var greenP = 5
}

struct GameModel {
    var score = 0
    var time = 0
    var intervalTime = 1.5
    var lives = 5
    var phase = 1
}

let scoreLabel = SKLabelNode(fontNamed:"Helvetica")

struct TimerApp {
    static let NotificationName = "AppLifeCycle" // This is our radio station
    static let MessageKey = "message"
    static let ResignedMessage = "resigned"
    static let ActivatedMessage = "activated"
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let rocketCategory: UInt32 = 0x1 << 0
    let floorCategory: UInt32 = 0x1 << 1
    let nothingCategory: UInt32 = 0x1 << 2
    
    var model: GameModel?
    private var timer: NSTimer?
    var TimeObserver: NSObjectProtocol?
    
    let launch = SKLabelNode(fontNamed:"Helvetica")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        model = GameModel()
        startObservers()
        
        
        // Add score text
        scoreLabel.text = "00000"
        scoreLabel.name = "score"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.position = CGPoint(x:CGRectGetMinX(self.frame)+5, y: CGRectGetMinY(self.frame)+5)
        self.addChild(scoreLabel)
        
        // Add debug launch button
        launch.text = "Launch!";
        launch.name = "launch"
        launch.fontSize = 30;
        launch.fontColor = UIColor.whiteColor()
        launch.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame)+10);
        self.addChild(launch)
        
        // Add the debug gameOver button
        let back = SKLabelNode(fontNamed:"Times New Roman")
        back.text = "\"Game Ended\""
        back.fontSize = 40
        back.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)-40)
        back.name = "back"
        back.fontColor = UIColor.whiteColor()
        self.addChild(back)
        
        // Set up the bottom of screen colision
        let bottomLeft = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame))
        let bottomRight = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame))
        let bottomEdge = SKPhysicsBody(edgeFromPoint: bottomLeft, toPoint: bottomRight)
        bottomEdge.categoryBitMask = floorCategory
        bottomEdge.contactTestBitMask = rocketCategory
        bottomEdge.collisionBitMask = 0
        self.physicsBody = bottomEdge
        
        // Set the scene
        backgroundColor = UIColor.blackColor()
        
        // Set up the gravity
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.81)
        self.physicsWorld.contactDelegate = self
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name == "back" {
                endTheGame()
            }
                
            else if node.name == "launch"{
                launch.hidden = true
                activateTimer()
            }
            
            if let nameN = node.name {
                let center = NSNotificationCenter.defaultCenter()
                let notification = NSNotification(name: "fireworkTouched", object: self)
                if nameN.hasPrefix("redR"){
                    exploded(node, color: "red")
                    center.postNotification(notification)
                }
                    
                else if nameN.hasPrefix("yellowR"){
                    exploded(node, color: "yellow")
                    center.postNotification(notification)
                }
                else if nameN.hasPrefix("greenR"){
                    exploded(node, color: "green")
                    center.postNotification(notification)
                }
            }
        }
    }
    
////////////////////////////// Collisions ///////////////////////////////////////////////
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let a = contact.bodyA
        let b = contact.bodyB
        let direction = contact.contactNormal.dy
        
        println("\(b.node!.name!) just hit the floor with direction \(direction)")
        if direction == 1.0 {
            model!.lives--
            if model!.lives < 1 {
                endTheGame()
            }
        }
        
    }
    
    
 ///////////////////////////// Observering and Timing ///////////////////////////////////////////////
    func startObservers() {
        let center = NSNotificationCenter.defaultCenter()
        let uiQueue = NSOperationQueue.mainQueue()
        center.addObserver(self, selector: "addToScore", name: "fireworkTouched", object: nil)
    }
    
    func activateTimer() {
        assert(timer == nil && model != nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(model!.intervalTime, target: self,
            selector: "handleTimer", userInfo: nil, repeats: true)
    }
    
    func cancelTimer() {
        assert(timer != nil)
        timer!.invalidate()
        timer = nil
    }
    
    func handleTimer() {
        if model!.intervalTime > 0.5{
            model!.intervalTime = model!.intervalTime - 0.02
        }
        
        if model!.score / model!.phase > 50 {
            model!.phase++
            model!.intervalTime = 1.5
        }
        
        for n in 1...model!.phase {
            setUpNewRocket()
        }
        if timer != nil && timer!.timeInterval != model!.intervalTime  {
            cancelTimer()
        }
        if timer == nil {
            activateTimer()
        }
        
    }

///////////////////////////////// Actions ////////////////////////////////////////
    
    func endTheGame() {
        cancelTimer()
        self.removeAllChildren()
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(
            name: "goToGameOver", object: self)
        center.postNotification(notification)
    }
    
    func addToScore() {
        model!.score++
    }
    
    func exploded(node: SKNode, color: String){
        let explosion: SKEmitterNode
        switch color{
        case "red":
            explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(redFireworkEmitterPath) as! SKEmitterNode
        case "yellow":
            explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(yellowFireworkEmitterPath) as! SKEmitterNode
        case "green":
            explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(greenFireworkEmitterPath) as! SKEmitterNode
        default:
            explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(redFireworkEmitterPath) as! SKEmitterNode
        }
        
        let deathLoc = node.position
        node.removeFromParent()
        explosion.position = deathLoc
        self.addChild(explosion)
        explosion.zPosition = CGFloat(-1)
        explosion.runAction(explode)
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        scoreLabel.text = "\(model!.score)"
        
    }
    
    func setUpNewRocket() {
        // Decide what kind of rocket to fire
        let roll = Int(arc4random_uniform(100))
        if fireworksProbabilities.greenP > roll {
            fireRocket("green")
        }
        else if fireworksProbabilities.yelP > roll {
            fireRocket("yellow")
        }
        else {
            fireRocket("red")
        }
    }
    
    
    
    func fireRocket(color: String) {
        let rocket: SKSpriteNode
        
        switch color{
        case "red":
            rocket = SKSpriteNode(color: UIColor.redColor(), size: rocketSize)
            rocket.name="redR\(numberOfRockets)"
        case "yellow":
            rocket = SKSpriteNode(color: UIColor.yellowColor(), size: rocketSize)
            rocket.name="yellowR\(numberOfRockets)"
        case "green":
            rocket = SKSpriteNode(color: UIColor.greenColor(), size: rocketSize)
            rocket.name="greenR\(numberOfRockets)"
        default:
            assertionFailure("werid color rocket")
            rocket = SKSpriteNode(color: UIColor.blueColor(), size: rocketSize)
        }
        
        let leftX = Int(CGRectGetMinX(self.frame)) + 30
        let rightX = Int(CGRectGetMaxX(self.frame)) - 30
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(CGRectGetMinY(self.frame))
        
        rocket.position = CGPoint(x:Xposition, y:Yposition)
        rocket.physicsBody = SKPhysicsBody(rectangleOfSize: rocket.size)
        rocket.physicsBody!.dynamic = true
        rocket.physicsBody!.mass = 0.01
        rocket.physicsBody!.categoryBitMask = rocketCategory
        rocket.physicsBody!.contactTestBitMask = floorCategory
        rocket.physicsBody!.collisionBitMask = 0
        numberOfRockets++
        
        self.addChild(rocket)
        let velocity = 700 + Int(arc4random_uniform(UInt32(100)))
        println("Rocket launched with velocity \(velocity)")
        rocket.physicsBody?.applyForce(CGVector(dx: 0, dy: velocity))
    }
}
