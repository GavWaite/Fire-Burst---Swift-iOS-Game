//
//  GameScene.swift
//  fireworksGame
//
//  Created by Gavin Waite on 20/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

import SpriteKit
import UIKit

//Set the sprites for the rockets
let rocketSize = CGSize(width: 20, height: 80)
let redBasicRocket = SKSpriteNode(color: UIColor.redColor(), size: rocketSize)
let yellowRocket = SKSpriteNode(color: UIColor.yellowColor(), size: rocketSize)
let greenRocket = SKSpriteNode(color: UIColor.greenColor(), size: rocketSize)


let fireworkEmitterPath: String = NSBundle.mainBundle().pathForResource("FireworksSparks", ofType: "sks")!
let fireworkEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(fireworkEmitterPath) as! SKEmitterNode

let fire = SKAction.moveToY(20, duration: 2)
let death = SKAction.removeFromParent()
let wait = SKAction.waitForDuration(1)
let explode = SKAction.sequence([wait, death])

class GameScene: SKScene, SKPhysicsContactDelegate {
    

    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Add debug launch button
        let launch = SKLabelNode(fontNamed:"Helvetica")
        launch.text = "Launch!";
        launch.name = "launch"
        launch.fontSize = 30;
        launch.fontColor = UIColor.whiteColor()
        launch.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-50);
        self.addChild(launch)
        
        // Set the debug button
        let back = SKLabelNode(fontNamed:"Times New Roman")
        back.text = "\"Game Ended\""
        back.fontSize = 40
        back.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        back.name = "back"
        back.fontColor = UIColor.whiteColor()
        self.addChild(back)
        
        //Init
        redBasicRocket.name = "redR"
        yellowRocket.name = "yellowR"
        greenRocket.name = "greenR"
        
        
        // Set the scene
        backgroundColor = UIColor.blackColor()
        
        // Set up the gravity
//        self.physicsWorld.gravity = CGVector(0.0, -9.8)
//        self.physicsWorld.contactDelegate = self;
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let node = self.nodeAtPoint(location)
            
            if node.name == "back" {
                let center = NSNotificationCenter.defaultCenter()
                let notification = NSNotification(
                    name: "goToGameOver", object: self)
                center.postNotification(notification)
                println("Notification sent")
            }
            
            if node.name == "redR" {
                exploded(node)
            }

//
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)

            
            
        }
    }
   
    func exploded(node: SKNode){
        let deathLoc = node.position
        node.removeFromParent()
        fireworkEmitterNode.position = deathLoc
        self.addChild(fireworkEmitterNode)
        fireworkEmitterNode.runAction(explode)
    }
    
    struct fireworksProbabilities {
        static var redP = 100
        static var yelP = 0
        static var greenP = 0
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
    }
    
    func setUpNewRocket() {
        // Decide what kind of rocket to fire
        let roll = Int(arc4random_uniform(100))
        if fireworksProbabilities.greenP > roll {
            fireGreenRocket()
        }
        else if fireworksProbabilities.yelP > roll {
            fireYellowRocket()
        }
        else {
            fireRedRocket()
        }
    }
    
    func fireGreenRocket() {
        return
    }
    
    func fireYellowRocket() {
        return
    }
    
    func fireRedRocket() {
        let leftX = Int(CGRectGetMinX(self.frame))
        let rightX = Int(CGRectGetMaxX(self.frame))
        let Xdistance = rightX - leftX
        let Xposition = Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(CGRectGetMaxX(self.frame)) + 30
        redBasicRocket.position = CGPoint(x:Xposition, y:Yposition)
        self.addChild(redBasicRocket)
    }
}
