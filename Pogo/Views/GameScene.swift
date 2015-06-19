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
let BALL_MASS: CGFloat = 0.13
let BALL_FRICTION: CGFloat = 0.2
let BALL_ALLOWS_ROTATION: Bool = false

let worldCategoryName = "world"
let ballCategoryName = "ball"
let platformCategoryName = "platform"
let powerMeterCategoryName = "power-meter-"
let safetyNetCategoryName = "safetyNet"

let worldCategory:UInt32 = 0x1
let ballCategory:UInt32 = 0x2
let bottomCategory:UInt32 = 0x3
let platformCategory:UInt32 = 0x4
let safetyNetCategory:UInt32 = 0x5

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameScene: GameScene!
    var world: Level!
    var ball: Ball!
    var powerMeter: PowerMeter!
    var safetyNet: SKShapeNode!
//    var backgroundMusicPlayer = AVAudioPlayer()
    var _maxJumpHeight: CGFloat!
    var _originLocation: CGPoint!
    var _lastDy: CGFloat = 0.0
    var _currentSurfaceBitMask:UInt32!
    
    override func didMoveToView(view: SKView) {
        self.initGameScene()
    }
    
    func initGameScene() {
        setupScene()
        setupWorld()
        setupBall()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
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
        world = Level(size: CGSizeMake(self.size.width, 10000), ballDiameter: self.frame.size.width / 10)
        world.position = CGPointMake(0, 0)
        self.addChild(world)
        self.backgroundColor = SKColor.whiteColor()
    }
        
    func setupBall() {
        self.ball = Ball(size: CGSizeMake(self.size.width / 10, self.size.width / 10))
        self.ball.name = ballCategoryName
        self.ball.position = CGPointMake(self.size.width / 2, 0)
        self.world.addChild(ball)
        
        self.ball.physicsBody?.categoryBitMask = ballCategory
        self.ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory | safetyNetCategory
        self.ball.physicsBody?.collisionBitMask = worldCategory | platformCategory | safetyNetCategory
        
        self.powerMeter = PowerMeter(width: self.ball.diameter * 0.50, maxDragDistance: self.frame.height / 4)
        self.powerMeter.name = powerMeterCategoryName
        self.powerMeter.zPosition = -1
        self.world.addChild(self.powerMeter)
    }
    
    func getVelocity(originLocation: CGPoint, releaseLocation: CGPoint) -> CGVector {
        let degrees = PhysicsHelper.getAngleBetweenPoints(originLocation, pointB: releaseLocation) * CGFloat(-180.0 / M_PI)
        let forceModifiers = getForceModifiers(originLocation, releaseLocation: releaseLocation)
        var force = getForce(degrees)
        
        force.dx *= forceModifiers.multiplier * forceModifiers.dxModifier
        force.dy *= forceModifiers.multiplier
        
        return CGVectorMake(force.dx, force.dy)
    }
    
    func getForce(degrees: CGFloat) -> (dx: CGFloat, dy: CGFloat) {
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

        return (dx, dy)
    }
    
    func getForceModifiers(originLocation: CGPoint, releaseLocation: CGPoint) -> (multiplier: CGFloat, dxModifier: CGFloat) {
        // These tweaks will make movement more predictable and organic feeling.
        // The values were determined from lots of playtesting.
        switch powerMeter.powerLevel {
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
    
    func launchBall(velocity: CGVector) {
        if _currentSurfaceBitMask == safetyNetCategory {
            safetyNet.removeFromParent()
        }
        
        if ball.ballType == BallType.Ghost {
            ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory | safetyNetCategory
            ball.physicsBody?.collisionBitMask = worldCategory
        } else if ball.ballType == BallType.Safety {
            createSafetyNet(ball.position)
            ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory | safetyNetCategory
            ball.physicsBody?.collisionBitMask = worldCategory | platformCategory | safetyNetCategory
        }
        
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
        _currentSurfaceBitMask = secondBody.categoryBitMask
        
        if ball.ballType == BallType.Sticky {
            ball.physicsBody?.velocity = CGVectorMake(0, 0)
            ball.physicsBody?.dynamic = false
        } else if ball.ballType == BallType.Ghost && !ball.hasUsedGhost && firstBody.categoryBitMask != worldCategory {
            ball.hasUsedGhost = true
        }
        
        ball.contactCount += 1
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if ball.ballType == BallType.Ghost && !ball.hasUsedGhost {
            ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory | safetyNetCategory
            ball.physicsBody?.collisionBitMask = worldCategory
        } else {
            ball.physicsBody?.contactTestBitMask = worldCategory | platformCategory | safetyNetCategory
            ball.physicsBody?.collisionBitMask = worldCategory | platformCategory | safetyNetCategory
        }
    }
    
    func createSafetyNet(position: CGPoint) {
        if let node = world.childNodeWithName(safetyNetCategoryName) {
            node.removeFromParent()
        }
        
        safetyNet = SKShapeNode(rectOfSize: CGSizeMake(self.frame.size.width, 1))
        safetyNet.name = safetyNetCategoryName
        safetyNet.position = CGPointMake(self.frame.size.width / 2, position.y - ball.radius - 1)
        safetyNet.strokeColor = SKColor.orangeColor()
        world.addChild(safetyNet)
        
        safetyNet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        safetyNet.physicsBody?.dynamic = false
        safetyNet.physicsBody?.categoryBitMask = safetyNetCategory
        safetyNet.physicsBody?.contactTestBitMask = 0x0
        safetyNet.physicsBody?.collisionBitMask = 0x0
    }
    
    func centerOnNode(node: SKNode) {
        let cameraPositionInScene: CGPoint = node.scene!.convertPoint(node.position, fromNode: node.parent!)

        node.parent!.position = CGPointMake(node.parent!.position.x, node.parent!.position.y - cameraPositionInScene.y)
    }
    
    func centerOnBottom() {
//        var cameraPositionInScene: CGPoint = node.scene!.convertPoint(node.position, fromNode: node.parent!)
//        
//        node.parent!.position = CGPointMake(node.parent!.position.x - cameraPositionInScene.x, node.parent!.position.y - cameraPositionInScene.y)
        self.world.position = CGPointMake(-self.frame.size.width / 2, -self.frame.size.height / 2)
//        self.world.position = CGPointMake(-ball.position.x, -self.frame.size.height / 2)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch?
        let touchLocation = touch?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation!)
        
        ball.isTouched = touchedNode.name == ballCategoryName
        _originLocation = touchLocation
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch?
        let touchLocation = touch?.locationInNode(self)
        
        powerMeter.update(_originLocation, dragToLocation: touchLocation!, originLocation: ball.position)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        userInteractionEnabled = false
        
        let touch = touches.first as UITouch?
        let touchLocation = touch?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation!)
        
        if touchedNode.name == ballCategoryName && powerMeter.powerLevel == 0 && ball.isTouched {
            ball.switchBallType(ball.ballType.rawValue + 1)
            ball.lockBallType = true
        }
        
        if powerMeter.powerLevel > 0 {
            let velocity = getVelocity(_originLocation, releaseLocation: touchLocation!)
            launchBall(velocity)
        }
        
        powerMeter.hide()
        powerMeter.powerLevel = 0
        _originLocation = nil
        ball.isTouched = false
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    override func didFinishUpdate() {
        if ball.position.y > self.frame.size.height / 2 {
            centerOnNode(ball)
        } else {
            centerOnBottom()
        }
        
        if let node = world.childNodeWithName(safetyNetCategoryName) {
            if ball.position.y < node.position.y {
                node.removeFromParent()
            }
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
        }
        
        if !ball.isMoving {
            userInteractionEnabled = true
            ball.contactCount = 0
            ball.hasUsedGhost = false
            
            if !ball.lockBallType {
                ball.switchBallType(0)
            }
            
            powerMeter.allowExtraPower = ball.ballType == BallType.Power
        }
    }
}