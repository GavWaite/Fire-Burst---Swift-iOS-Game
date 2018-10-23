//
//  GameScene.swift
//  fireworksGame
//
//  Created by Gavin Waite on 20/07/2015.
//  Copyright (c) 2015 Gavin Waite. All rights reserved.
//

// Overall References
// http://code.tutsplus.com/tutorials/build-an-airplane-game-with-sprite-kit-enemies-emitters--mobile-19916
// Used this for comparison of several ideas, such as the flame trail vs their smoke trail
//
// Example code from the lectures was used for reference and in the case of Persistence.swift was used entirely
//
// The triple finger tap 'Quick Help' Apple Reference was used very frequently


import Foundation
import SpriteKit
import UIKit
import AudioToolbox


//////////// Convenience constants /////////////////

//http://stackoverflow.com/questions/24043904/creating-and-playing-a-sound-in-swift
// File paths and Sound IDs for the sound effects
let explosionPath = Bundle.main.path(forResource: "75328__oddworld__oddworld-explosionecho", ofType: "wav")
let explosionURL = URL(fileURLWithPath: explosionPath!)
var explosionID: SystemSoundID = 0

let launchPath = Bundle.main.path(forResource: "202230__deraj__pop-sound", ofType: "wav")
let launchURL = URL(fileURLWithPath: launchPath!)
var launchID: SystemSoundID = 1

//https://developer.apple.com/library/prerelease/ios/documentation/SpriteKit/Reference/SKAction_Ref/index.html#//apple_ref/occ/clm/SKAction/followPath:speed:
// SKAction shortcuts
let fire = SKAction.moveTo(y: 20, duration: 2)
let death = SKAction.removeFromParent()
let wait = SKAction.wait(forDuration: 1)
let explode = SKAction.sequence([wait, death])

// Timer notification strings
struct TimerApp {
    static let NotificationName = "AppLifeCycle" // This is our radio station
    static let MessageKey = "message"
    static let ResignedMessage = "resigned"
    static let ActivatedMessage = "activated"
}


////////////////////////////////////////// The Game Scene Code //////////////////////////////////////////

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Set the sprite sizes for the rockets
    let rocketSize = CGSize(width: 50, height: 80)
    
    //https://developer.apple.com/library/prerelease/ios/documentation/SpriteKit/Reference/SKPhysicsBody_Ref/#//apple_ref/occ/instp/SKPhysicsBody/collisionBitMask
    //http://www.techotopia.com/index.php/A_Swift_iOS_8_Sprite_Kit_Collision_Handling_Tutorial
    // Set the collison mask categories
    let rocketCategory: UInt32 = 0x1 << 0
    let floorCategory: UInt32 = 0x1 << 1
    let nothingCategory: UInt32 = 0x1 << 2
    
    // Declare the model references
    var model: GameModel?
    var scores: Highscores?
    var settings: SettingsData?
    var emitters: EmitterPaths?
    fileprivate var timer: Timer?
    var TimeObserver: NSObjectProtocol?
    
    var numberOfRockets = 0
    
    // Initialise the game scene labels
    let launch = SKLabelNode(fontNamed:"C7nazara")
    let scoreLabel = SKLabelNode(fontNamed:"Helvetica")
    let livesLabel = SKLabelNode(fontNamed:"Helvetica")
    
//////////////////////// Scene set-up /////////////////////////
    
    override func didMove(to view: SKView) {
        
        model = GameModel() // the current game data
        scores = Highscores.Static.instance
        settings = SettingsData.Static.instance
        emitters = EmitterPaths()
        startObservers()
        AudioServicesCreateSystemSoundID(explosionURL as CFURL, &explosionID)
        AudioServicesCreateSystemSoundID(launchURL as CFURL, &launchID)
        
        // Add score text
        scoreLabel.text = "00000"
        scoreLabel.name = "score"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x:self.frame.minX+15, y: self.frame.maxY-45)
        self.addChild(scoreLabel)
        
        // Add lives text
        livesLabel.text = "5"
        livesLabel.name = "lives"
        livesLabel.fontSize = 30
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.fontColor = UIColor.yellow
        livesLabel.position = CGPoint(x:self.frame.maxX-15, y: self.frame.maxY-45)
        self.addChild(livesLabel)
        
        // Add debug launch button
        launch.text = "Tap to begin";
        launch.name = "launch"
        launch.fontSize = 30;
        launch.fontColor = UIColor.white
        launch.position = CGPoint(x:self.frame.midX, y: self.frame.midY);
        self.addChild(launch)
        
        // Set up the bottom of screen colision
        let bottomLeft = CGPoint(x: self.frame.minX, y: self.frame.minY)
        let bottomRight = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        let bottomEdge = SKPhysicsBody(edgeFrom: bottomLeft, to: bottomRight)
        bottomEdge.categoryBitMask = floorCategory
        bottomEdge.contactTestBitMask = rocketCategory
        bottomEdge.collisionBitMask = 0
        self.physicsBody = bottomEdge
        
        // Set the scene
        backgroundColor = UIColor.black
        
        // Set up the gravity
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -10)
        self.physicsWorld.contactDelegate = self
        
    }
    
/////////////////////////// User touches the scene //////////////////////////////
    
    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "launch"{
                launch.isHidden = true
                launch.removeFromParent()
                activateTimer()
            }
            
            // A rocket has been tapped to explode
            if let nameN = node.name {
                let center = NotificationCenter.default
                let notification = Notification(name: Notification.Name(rawValue: "fireworkTouched"), object: self)
                if nameN.hasPrefix("redR"){
                    exploded(node, color: "red")
                    let rktNum = (nameN as NSString).substring(from: 4)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("orangeR"){
                    exploded(node, color: "orange")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("yellowR"){
                    exploded(node, color: "yellow")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("greenR"){
                    exploded(node, color: "green")
                    let rktNum = (nameN as NSString).substring(from: 6)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("blueR"){
                    exploded(node, color: "blue")
                    let rktNum = (nameN as NSString).substring(from: 5)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("purpleR"){
                    exploded(node, color: "purple")
                    let rktNum = (nameN as NSString).substring(from: 7)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
                else if nameN.hasPrefix("pinkR"){
                    exploded(node, color: "pink")
                    let rktNum = (nameN as NSString).substring(from: 5)
                    let trlNum = "trail\(rktNum)"
                    if let trail = self.childNode(withName: trlNum){
                        trail.removeFromParent()
                    }
                    center.post(notification)
                }
            }
        }
    }
    
///////////////////////////////////// Collisions ///////////////////////////////////////////////
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let a = contact.bodyA // This will be the floor
        let b = contact.bodyB // This will be the rocket
        if let A = a.node!.name {
            assertionFailure("Non- floor collison, a is \(A)")
        }
        
        let direction = contact.contactNormal.dy
        
        if direction == 1.0 { // Direction 1.0 means straight down, as apposed to the -1.0 when rocket launches
            b.node!.removeFromParent()
            model!.lives -= 1
            if model!.lives < 1 {
                endTheGame()
            }
        }
    }
    
    
 ///////////////////////////// Observering and Timing ///////////////////////////////////////////////
    func startObservers() {
        let center = NotificationCenter.default
        let uiQueue = OperationQueue.main
        center.addObserver(self, selector: #selector(GameScene.addToScore), name: NSNotification.Name(rawValue: "fireworkTouched"), object: nil)
    }
    
    func activateTimer() {
        assert(timer == nil && model != nil)
        timer = Timer.scheduledTimer(timeInterval: model!.intervalTime, target: self,
            selector: #selector(GameScene.handleTimer), userInfo: nil, repeats: true)
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
        
        if model!.score / model!.phase > 5000 {
            model!.phase += 1
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
        let center = NotificationCenter.default
        let notification = Notification(
            name: Notification.Name(rawValue: "goToGameOver"), object: self)
        center.post(notification)
    }
    
    func addToScore() {
        model!.score += 100
    }
    
    func exploded(_ node: SKNode, color: String){
        let explosion: SKEmitterNode
        
        //http://stackoverflow.com/questions/24083938/adding-a-particle-emitter-to-the-flappyswift-project
        //http://goobbe.com/questions/4782463/adding-emitter-node-to-sks-file-and-using-it-xcode-6-0-swift
        // Load the correct explosion SKEmitterNode
        explosion = NSKeyedUnarchiver.unarchiveObject(withFile: emitters!.emitterPathDictionary[color]!) as! SKEmitterNode
        
        // Add the explosion emitter
        let deathLoc = node.position
        node.removeFromParent()
        explosion.position = deathLoc
        self.addChild(explosion)
        playExplode()
        explosion.zPosition = CGFloat(-1)
        explosion.particleZPosition = CGFloat(-1)
        explosion.run(explode)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        scoreLabel.text = "\(model!.score)"
        livesLabel.text = "\(model!.lives) ❤️"
        
        // Update the position of the flame trails and flip the sprites if necessary
        for i in 0...numberOfRockets {
            if let trl = self.childNode(withName: "trail\(i)"){
                if let red = self.childNode(withName: "redR\(i)"){
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
                else if let yel = self.childNode(withName: "yellowR\(i)"){
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
                else if let ora = self.childNode(withName: "orangeR\(i)"){
                    let up = ora.physicsBody!.velocity.dy >= 0
                    let pos = ora.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        ora.yScale = -1
                    }
                }
                else if let grn = self.childNode(withName: "greenR\(i)"){
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
                else if let blu = self.childNode(withName: "blueR\(i)"){
                    let up = blu.physicsBody!.velocity.dy >= 0
                    let pos = blu.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        blu.yScale = -1
                    }
                }
                else if let pur = self.childNode(withName: "purpleR\(i)"){
                    let up = pur.physicsBody!.velocity.dy >= 0
                    let pos = pur.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        pur.yScale = -1
                    }
                }
                else if let pin = self.childNode(withName: "pinkR\(i)"){
                    let up = pin.physicsBody!.velocity.dy >= 0
                    let pos = pin.position
                    if up {
                        trl.position = CGPoint(x: pos.x, y:pos.y)
                    }
                    else {
                        trl.removeFromParent()
                        pin.yScale = -1
                    }
                }
            }
        }
    }
    
    // Decide what kind of rocket to fire
    func setUpNewRocket() {
        // http://stackoverflow.com/questions/24007129/how-does-one-generate-a-random-number-in-apples-swift-language
        let roll = Int(arc4random_uniform(7))
        
        switch roll{
        case 0:
            fireRocket("red")
        case 1:
            fireRocket("orange")
        case 2:
            fireRocket("yellow")
        case 3:
            fireRocket("green")
        case 4:
            fireRocket("blue")
        case 5:
            fireRocket("purple")
        case 6:
            fireRocket("pink")
        default:
            assertionFailure("Invalid rocket number was rolled")
        }
    }
    
    
    func fireRocket(_ color: String) {
        let rocket: SKSpriteNode
        let trail: SKEmitterNode
        
        // Initialise the rocket, depending on the color
        let rktName: String = "\(color)Rocket"
        let RName: String = "\(color)R"
        rocket = SKSpriteNode(imageNamed: rktName)
        rocket.size = rocketSize
        rocket.name = "\(RName)\(numberOfRockets)"
        
        // Initialise the flame trail
        trail = NSKeyedUnarchiver.unarchiveObject(withFile: emitters!.emitterPathDictionary["trail"]!) as! SKEmitterNode
        trail.name = "trail\(numberOfRockets)"
        
        // Decide where to randomly launch the rocket from
        let leftX = Int(self.frame.minX) + 30
        let rightX = Int(self.frame.maxX) - 30
        let Xdistance = rightX - leftX
        let Xposition = leftX + Int(arc4random_uniform(UInt32(Xdistance)))
        let Yposition = Int(self.frame.minY)
        rocket.position = CGPoint(x: Xposition, y: Yposition)
        trail.position = CGPoint(x: rocket.position.x + 25, y:rocket.position.y)
        trail.zPosition = CGFloat(-2)
        trail.particleZPosition = CGFloat(-2)
        
        // Set up the physics body for the rocket
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.physicsBody!.isDynamic = true
        rocket.physicsBody!.mass = CGFloat(0.01)
        rocket.physicsBody!.categoryBitMask = rocketCategory
        rocket.physicsBody!.contactTestBitMask = floorCategory
        rocket.physicsBody!.collisionBitMask = 0
        numberOfRockets += 1
        
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
        //println("Frame: \(frameHeight), Velocity = \(initialVel) + \(randomVel)")
        let velocity = CGFloat(initialVel + Int(arc4random_uniform(UInt32(randomVel))))
        //println("Rocket \(rocket.name) of mass \(rocket.physicsBody!.mass) launched with velocity \(velocity)")
        rocket.physicsBody!.velocity.dy = velocity
        playLaunch()
    }
    
/////////// Play sounds ////////////////
    
    func playExplode(){
        if !settings!.mutedSound {
            AudioServicesPlaySystemSound(explosionID)
        }
    }
    
    func playLaunch(){
        if !settings!.mutedSound {
            AudioServicesPlaySystemSound(launchID)
        }
    }
}
