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
let rocketSize = CGSize(width: 50, height: 80)



let redFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("RedFireworksSparks", ofType: "sks")!
let redFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(redFireworkEmitterPath) as! SKEmitterNode
let yellowFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("YellowFireworksSparks", ofType: "sks")!
let yellowFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(yellowFireworkEmitterPath) as! SKEmitterNode
let greenFireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("GreenFireworksSparks", ofType: "sks")!
let greenFireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(greenFireworkEmitterPath) as! SKEmitterNode
let flameTrailEmitterPath: String = NSBundle.mainBundle().pathForResource("flameTrail", ofType: "sks")!
let flameTrailEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(flameTrailEmitterPath) as! SKEmitterNode

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
let livesLabel = SKLabelNode(fontNamed:"Helvetica")

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
    var scores: Highscores?
    var numberOfRockets = 0
    private var timer: NSTimer?
    var TimeObserver: NSObjectProtocol?
    
    let launch = SKLabelNode(fontNamed:"Helvetica")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        model = GameModel()
        scores = Highscores.Static.instance
        startObservers()
        
        // Add score text
        scoreLabel.text = "00000"
        scoreLabel.name = "score"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.position = CGPoint(x:CGRectGetMinX(self.frame)+15, y: CGRectGetMaxY(self.frame)-45)
        self.addChild(scoreLabel)
        
        // Add lives text
        livesLabel.text = "5"
        livesLabel.name = "lives"
        livesLabel.fontSize = 30
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesLabel.fontColor = UIColor.yellowColor()
        livesLabel.position = CGPoint(x:CGRectGetMaxX(self.frame)-15, y: CGRectGetMaxY(self.frame)-45)
        self.addChild(livesLabel)
        
        // Add debug launch button
        launch.text = "Tap to begin";
        launch.name = "launch"
        launch.fontSize = 30;
        launch.fontColor = UIColor.whiteColor()
        launch.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        self.addChild(launch)
        
        // Add the debug gameOver button
//        let back = SKLabelNode(fontNamed:"Times New Roman")
//        back.text = "\"Game Ended\""
//        back.fontSize = 40
//        back.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)-40)
//        back.name = "back"
//        back.fontColor = UIColor.whiteColor()
//        self.addChild(back)
        
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
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -10)
        self.physicsWorld.contactDelegate = self
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name == "launch"{
                launch.hidden = true
                launch.removeFromParent()
                activateTimer()
            }
            
            if let nameN = node.name {
                let center = NSNotificationCenter.defaultCenter()
                let notification = NSNotification(name: "fireworkTouched", object: self)
                if nameN.hasPrefix("redR"){
                    exploded(node, color: "red")
                    let rktNum = (nameN as NSString).substringFromIndex(4)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNodeWithName(trlNum){
                        trail.removeFromParent()
                    }
                    center.postNotification(notification)
                }
                    
                else if nameN.hasPrefix("yellowR"){
                    exploded(node, color: "yellow")
                    let rktNum = (nameN as NSString).substringFromIndex(7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNodeWithName(trlNum){
                        trail.removeFromParent()
                    }
                    center.postNotification(notification)
                }
                else if nameN.hasPrefix("greenR"){
                    exploded(node, color: "green")
                    let rktNum = (nameN as NSString).substringFromIndex(6)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNodeWithName(trlNum){
                        trail.removeFromParent()
                    }
                    center.postNotification(notification)
                }
            }
        }
    }
    
////////////////////////////// Collisions ///////////////////////////////////////////////
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
        let a = contact.bodyA
        let b = contact.bodyB
//        let aname = a.node?.name
//        let bname = b.node?.name
//        println("\(aname) just hit \(bname)")
        let direction = contact.contactNormal.dy
        
        if direction == 1.0 {
            println("\(b.node!.name!) just hit the floor with direction \(direction)")
            b.node!.removeFromParent()
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
        scores!.tempScore = model!.score
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
        explosion.particleZPosition = CGFloat(-1)
        explosion.runAction(explode)
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        scoreLabel.text = "\(model!.score)"
        livesLabel.text = "\(model!.lives) ❤️"
        
        for i in 0...numberOfRockets {
            if let trl = self.childNodeWithName("trail\(i)"){
                if let red  = self.childNodeWithName("redR\(i)"){
//                            if red.physicsBody!.velocity.dy > 1308 {
//                                println("Weird rocket initial speed of \(red.physicsBody!.velocity.dy)")
//                                red.physicsBody!.velocity.dy = 1307
//                            }
                    let up = red.physicsBody!.velocity.dy >= 0
                    let pos = red.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        red.yScale = -1
                    }
                }
                if let yel  = self.childNodeWithName("yellowR\(i)"){
                    let up = yel.physicsBody!.velocity.dy >= 0
                    let pos = yel.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        yel.yScale = -1
                    }
                    
                }
                if let grn  = self.childNodeWithName("greenR\(i)"){
                    let up = grn.physicsBody!.velocity.dy >= 0
                    let pos = grn.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        grn.yScale = -1
                    }
                }
            }
        }
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
        let trail: SKEmitterNode
        
        // Initialise the rocket, depending on the color
        switch color{
        case "red":
            //rocket = SKSpriteNode(color: UIColor.redColor(), size: rocketSize)
            rocket = SKSpriteNode(imageNamed: "redRocket")
            rocket.size = rocketSize
            rocket.name="redR\(numberOfRockets)"
        case "yellow":
            rocket = SKSpriteNode(imageNamed: "yellowRocket")
            rocket.size = rocketSize
            rocket.name="yellowR\(numberOfRockets)"
        case "green":
            rocket = SKSpriteNode(imageNamed: "greenRocket")
            rocket.size = rocketSize
            rocket.name="greenR\(numberOfRockets)"
        default:
            assertionFailure("werid color rocket")
            rocket = SKSpriteNode(color: UIColor.blueColor(), size: rocketSize)
        }
        
        trail = NSKeyedUnarchiver.unarchiveObjectWithFile(flameTrailEmitterPath) as! SKEmitterNode
        trail.name = "trail\(numberOfRockets)"
        
        // Decide where to randomly launch the rocket from
        let leftX = Int(CGRectGetMinX(self.frame)) + 30
        let rightX = Int(CGRectGetMaxX(self.frame)) - 30
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(CGRectGetMinY(self.frame))
        rocket.position = CGPoint(x: Xposition, y: Yposition)
        trail.position = CGPoint(x: rocket.position.x + 25, y:rocket.position.y)
        trail.zPosition = CGFloat(-2)
        trail.particleZPosition = CGFloat(-2)
        
        // Set up the physics body for the rocket
        rocket.physicsBody = SKPhysicsBody(rectangleOfSize: rocket.size)
        rocket.physicsBody!.dynamic = true
        rocket.physicsBody!.mass = CGFloat(0.01)
        rocket.physicsBody!.categoryBitMask = rocketCategory
        rocket.physicsBody!.contactTestBitMask = floorCategory
        rocket.physicsBody!.collisionBitMask = 0
        numberOfRockets++
        
        // Add the rocket and apply a random vertical force to it
        self.addChild(rocket)
        self.addChild(trail)
        // 157 is the point to metre ratio
        //http://stackoverflow.com/questions/29676701/suvat-maths-dont-add-up-in-spritekits-physics-engine-ios-objective-c
        let frameHeight = (self.frame.height - 50)*157
        // using u^2 = -2gs
        let maxVel = Double(round(sqrt(frameHeight*20)))
        let initialVel = Int(round(maxVel*0.8))
        let randomVel = Int(maxVel) - initialVel
        println("Frame: \(frameHeight), Velocity = \(initialVel) + \(randomVel)")
        let velocity = CGFloat(initialVel + Int(arc4random_uniform(UInt32(randomVel))))
        println("Rocket \(rocket.name) of mass \(rocket.physicsBody!.mass) launched with velocity \(velocity)")
        rocket.physicsBody!.velocity.dy = velocity

    }
}
