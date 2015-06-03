//
//  GameScene.swift
//  Breakout
//
//  Created by Training on 28/11/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

let BALL_RESTITUTION: CGFloat = 0.5
let BALL_MASS: CGFloat = 0.1
let BALL_FRICTION: CGFloat = 0.2
let BALL_ALLOWS_ROTATION: Bool = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    let worldCategoryName = "world"
    let ballCategoryName = "ball"
    let platformCategoryName = "platform"
    let powerMeterCategoryName = "power-meter-"
    
    let ghostCategory:UInt32 = 0x1
    let ballCategory:UInt32 = 0x2
    let bottomCategory:UInt32 = 0x3
    let platformCategory:UInt32 = 0x4
    let tileMapCategory:UInt32 = 0x5
    let worldCategory:UInt32 = 0x6
    
    var gameScene: GameScene!
    var world: SKNode!
    var ball: Ball!
    var powerMeter: PowerMeter!
    var backgroundMusicPlayer = AVAudioPlayer()
    
    var _maxFingerDragLength: CGFloat!
    var _maxJumpHeight: CGFloat!
    var _originLocation: CGPoint!
    var _lastDy: CGFloat = 0.0

    
    override func didMoveToView(view: SKView) {
        self.initGameScene()
    }
    
    func initGameScene() {
        setupScene()
        setupWorld()
        setupBall()
        //setupJumpLines()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupScene() {
        self.scaleMode = .AspectFill
        self.physicsWorld.contactDelegate = self
        self.anchorPoint = CGPointMake(0.5, 0.5)
    }
    
    func setupWorld() {
        world = self.childNodeWithName(worldCategoryName)
        world.name = worldCategoryName
        
        let worldRect = CGRectMake(0, 0, world.frame.size.width, world.frame.size.height)
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: worldRect)
//        worldBorder.categoryBitMask = worldCategory
        self.world.physicsBody = worldBorder
        
        _maxFingerDragLength = self.frame.height / 4

        powerMeter = PowerMeter()
        powerMeter.name = powerMeterCategoryName
        world.addChild(powerMeter)
        
        setupPlatforms()
    }
    
    func setupPlatforms() {
        for i in 0..<world.children.count {
            var child = world.children[i] as! SKSpriteNode
            if child.name == platformCategoryName {
                child.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(child.frame.size.width, child.frame.size.height))
                child.physicsBody?.dynamic = false
//                child.physicsBody?.categoryBitMask = platformCategory
//                child.physicsBody?.contactTestBitMask = ballCategory
//                child.physicsBody?.collisionBitMask = ballCategory
            }
        }
    }
    
    func setupJumpLines() {
        var midline = SKShapeNode(rect: CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, 1))
        midline.strokeColor = SKColor.grayColor()
        world.addChild(midline)
        
        var topline = SKShapeNode(rect: CGRectMake(0, self.frame.size.height, self.frame.size.width, 1))
        topline.strokeColor = SKColor.grayColor()
        world.addChild(topline)
        
        var line = SKShapeNode(rect: CGRectMake(0, ball.diameter * 1, self.frame.size.width, 1))
        line.strokeColor = SKColor.blueColor()
        world.addChild(line)
        
        var line2 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 2, self.frame.size.width, 1))
        line2.strokeColor = SKColor.blueColor()
        world.addChild(line2)
        
        var line3 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 3, self.frame.size.width, 1))
        line3.strokeColor = SKColor.blueColor()
        world.addChild(line3)
        
        var line4 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 4, self.frame.size.width, 1))
        line4.strokeColor = SKColor.blueColor()
        world.addChild(line4)
        
        var line5 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 5, self.frame.size.width, 1))
        line5.strokeColor = SKColor.blueColor()
        world.addChild(line5)
        
        var line6 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 6, self.frame.size.width, 1))
        line6.strokeColor = SKColor.blueColor()
        world.addChild(line6)
        
        var line7 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 7, self.frame.size.width, 1))
        line7.strokeColor = SKColor.blueColor()
        world.addChild(line7)
        
        var line8 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 8, self.frame.size.width, 1))
        line8.strokeColor = SKColor.blueColor()
        world.addChild(line8)
        
        var line9 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 9, self.frame.size.width, 1))
        line9.strokeColor = SKColor.blueColor()
        world.addChild(line9)
        
        var line10 = SKShapeNode(rect: CGRectMake(0, ball.diameter * 10, self.frame.size.width, 1))
        line10.strokeColor = SKColor.blueColor()
        world.addChild(line10)
    }
    
    func setupBall() {
        ball = Ball(size: CGSizeMake(self.frame.width / 10, self.frame.width / 10))
        ball.name = ballCategoryName
        ball.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        world.addChild(ball)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if touchedNode.name == ballCategoryName {
            ball.isTouched = true
        }
        
        _originLocation = touchLocation
        showPowerMeter(touchLocation)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        showPowerMeter(touchLocation)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        hidePowerMeter()
        
        userInteractionEnabled = false
        
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if touchedNode.name == ballCategoryName && powerMeter.powerLevel == 0 && ball.isTouched {
            ball.switchBallType(ball.ballType.rawValue + 1)
            ball.lockBallType = true
        }
        
        if powerMeter.powerLevel > 0 {
            let velocity = getVelocity(_originLocation, releaseLocation: touchLocation)
            launchBall(velocity)
        }
    
        powerMeter.powerLevel = 0
        _originLocation = nil
        ball.isTouched = false
    }
    
    func getVelocity(originLocation: CGPoint, releaseLocation: CGPoint) -> CGVector {
        let degrees = PhysicsHelper.getAngleBetweenPoints(originLocation, pointB: releaseLocation) * CGFloat(-180.0 / M_PI)
        
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        
        // Apply a percentage to the amount of force that will be applied to dx/dy
        if degrees >= 0 {
            if degrees < 45 {
                dx = -1
                dy = degrees / 45
            } else if degrees <= 90 {
                dx = (degrees - 90) / 45
                dy = 1
            } else if degrees <= 135 {
                dx = (degrees - 90) / 45
                dy = 1
            } else if degrees <= 180 {
                dx = 1
                dy = (180 - degrees) / 45
            }
        } else {
            if degrees >= -45 {
                dx = -1
                dy = degrees / 45
            } else if degrees >= -90 {
                dx = (-degrees - 90) / 45
                dy = -1
            } else if degrees >= -135 {
                dx = (-degrees - 90) / 45
                dy = -1
            } else if degrees >= -180 {
                dx = 1
                dy = (-degrees - 180) / 45
            }
        }
        
        var forceModifiers = getForceModifiers(originLocation, releaseLocation: releaseLocation)
        
        dx *= forceModifiers.forceMultiplier * forceModifiers.dxModifier
        dy *= forceModifiers.forceMultiplier
        
        return CGVectorMake(dx, dy)
    }
    
    func getForceModifiers(originLocation: CGPoint, releaseLocation: CGPoint) -> (forceMultiplier: CGFloat, dxModifier: CGFloat) {
        // These tweaks will make movement more predictable and organic feeling.
        // The values were determined from lots of playtesting.
        let powerLevel: CGFloat = CGFloat(getPowerLevel(originLocation, toLocation: releaseLocation))
        switch powerLevel {
        case 13:
            return (0, 1.0)
        case 12:
            return (0, 1.0)
        case 11:
            return (0, 1.0)
        case 10:
            return (160, 1.0)
        case 9:
            return (145, 0.95)
        case 8:
            return (135, 0.90)
        case 7:
            return (120, 0.85)
        case 6:
            return (111, 0.80)
        case 5:
            return (101, 0.75)
        case 4:
            return (90, 0.70)
        case 3:
            return (79, 0.65)
        case 2:
            return (65, 0.50)
        case 1:
            return (47, 0.45)
        default:
            return (0, 0)
        }
    }
    
    func getPowerLevel(fromLocation: CGPoint, toLocation: CGPoint) -> Int {
        let power = PhysicsHelper.distanceBetweenPoints(fromLocation, second: toLocation)
        powerMeter.power = power > _maxFingerDragLength ? _maxFingerDragLength : power
        
        if powerMeter.power >= _maxFingerDragLength && ball.ballType == BallType.Power {
            return 10
        } else if powerMeter.power > _maxFingerDragLength * 0.9 && ball.ballType == BallType.Power {
            return 9
        } else if powerMeter.power > _maxFingerDragLength * 0.8 && ball.ballType == BallType.Power {
            return 8
        } else if powerMeter.power > _maxFingerDragLength * 0.7 {
            return 7
        } else if powerMeter.power > _maxFingerDragLength * 0.6 {
            return 6
        } else if powerMeter.power > _maxFingerDragLength * 0.5 {
            return 5
        } else if powerMeter.power > _maxFingerDragLength * 0.4 {
            return 4
        } else if powerMeter.power > _maxFingerDragLength * 0.3 {
            return 3
        } else if powerMeter.power > _maxFingerDragLength * 0.2 {
            return 2
        } else if powerMeter.power > _maxFingerDragLength * 0.1 {
            return 1
        }
        
        return 0
    }

    func showPowerMeter(location: CGPoint) {
        powerMeter.hidden = false
        updatePowerMeter(_originLocation, toLocation: location)
    }
    
    func hidePowerMeter() {
        powerMeter.hidden = true
    }
    
    func updatePowerMeter(fromLocation: CGPoint, toLocation: CGPoint) {
        powerMeter.powerLevel = getPowerLevel(fromLocation, toLocation: toLocation)
        
        if powerMeter.powerLevel > 0 {
            powerMeter.hidden = false
        
            let width = ball.diameter * 0.50
            let height = width + (0.85 * width) * CGFloat(powerMeter.powerLevel)
            
            powerMeter.anchorPoint = CGPointMake(0.5, 0.0)
            powerMeter.texture = SKTexture(imageNamed: powerMeterCategoryName + String(powerMeter.powerLevel))
            powerMeter.size = CGSizeMake(width, height)
            
            let position = CGPointMake(self.ball.position.x, self.ball.position.y)
            powerMeter.position = position
            
            var endNode = SKNode()
            endNode.position = CGPointMake(self.ball.position.x + (fromLocation.x - toLocation.x), self.ball.position.y + (fromLocation.y - toLocation.y))
            
            PhysicsHelper.rotateNode(powerMeter, endNode: endNode, toFaceNode: ball)
        } else {
            powerMeter.hidden = true
        }
    }
    
    func launchBall(velocity: CGVector) {
        ball.physicsBody?.dynamic = true
        ball.physicsBody?.restitution = BALL_RESTITUTION
        ball.physicsBody?.applyImpulse(velocity)
        ball.lockBallType = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ball.ballType == BallType.Sticky {
            ball.physicsBody?.velocity = CGVectorMake(0, 0)
            ball.physicsBody?.dynamic = false
        } else if ball.ballType == BallType.Ghost {
        
        }
        
        ball.contactCount += 1
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if ball.ballType == BallType.Ghost && ball.contactCount == 0 {
//            ball.physicsBody?.categoryBitMask = ghostCategory
//            ball.physicsBody?.contactTestBitMask = worldCategory
//            ball.physicsBody?.collisionBitMask = worldCategory
        } else {
//            ball.physicsBody?.categoryBitMask = ballCategory
//            ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory
//            ball.physicsBody?.collisionBitMask = worldCategory | platformCategory
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }

    override func didFinishUpdate() {
        if ball.position.y > self.frame.size.height / 2 {
            centerOnNode(ball)
        } else {
            centerOnBottom()
        }
        
        switch ball.ballType {
        case BallType.Normal:
            break
        case BallType.Sticky:
            break
        case BallType.Power:
            break
        case BallType.Ghost:
            break
        case BallType.Safety:
            break
        default:
            break
        }
        
        if !ball.isMoving {
            userInteractionEnabled = true
            ball.contactCount = 0
            
            if !ball.lockBallType {
                ball.switchBallType(0)
            }
        }
    }
    
    func centerOnNode(node: SKNode) {
        var cameraPositionInScene: CGPoint = node.scene!.convertPoint(node.position, fromNode: node.parent!)

        node.parent!.position = CGPointMake(node.parent!.position.x, node.parent!.position.y - cameraPositionInScene.y)
    }
    
    func centerOnBottom() {
        self.world.position = CGPointMake(-self.frame.size.width / 2, -self.frame.size.height / 2)
    }
}