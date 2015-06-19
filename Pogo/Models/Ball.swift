//
//  Ball.swift
//  Pogo
//
//  Created by Daniel Maness on 6/3/15.
//  Copyright (c) 2015 Daniel Maness. All rights reserved.
//

import Foundation
import SpriteKit

enum BallType: Int {
    case Normal = 0, Power, Sticky, Ghost, Safety
}

class Ball: SKSpriteNode {
    var ballType: BallType = BallType.Normal
    var isTouched: Bool = false
    var lockBallType: Bool = false
    var contactCount: Int = 0
    var hasUsedGhost: Bool = false
    var powerUpInventory: [Int] = [1, 3, 3, 3, 3]
    
    private let ballTypes: [BallType] = [BallType.Normal, BallType.Power, BallType.Sticky, BallType.Ghost, BallType.Safety]
    
    var diameter: CGFloat {
        return self.size.width
    }
    
    var radius: CGFloat {
        return self.diameter / 2
    }
    
    var isMoving: Bool {
        if PhysicsHelper.nearlyAtRest(self) {
            return false
        }
        
        return true
    }
    
    init(size: CGSize) {
        let texture = SKTexture(imageNamed: "ball")
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        self.setPhysics(nil, restitution: nil, friction: nil, allowsRotation: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPhysics(mass: CGFloat!, restitution: CGFloat!, friction: CGFloat!, allowsRotation: Bool!) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.physicsBody?.mass = mass == nil ? BALL_MASS : mass
        self.physicsBody?.restitution = restitution == nil ? BALL_RESTITUTION : restitution
        self.physicsBody?.friction = friction == nil ? BALL_FRICTION : friction
        self.physicsBody?.allowsRotation = allowsRotation == nil ? BALL_ALLOWS_ROTATION : allowsRotation
    }
    
    func switchBallType(ballTypeIndex: Int) {
        if ballTypeIndex >= self.ballTypes.count {
            switchBallType(0)
        } else {
            if powerUpInventory[ballTypeIndex] > 0 {
                self.ballType = ballTypes[ballTypeIndex]
                updateBallTexture()
                return
            }
            
            switchBallType(ballTypeIndex + 1)
        }
    }
    
    func updateBallTexture() {
        switch self.ballType {
        case BallType.Normal:
            self.texture = SKTexture(imageNamed: "ball")
        case BallType.Sticky:
            self.texture = SKTexture(imageNamed: "ball-sticky")
        case BallType.Power:
            self.texture = SKTexture(imageNamed: "ball-power")
        case BallType.Ghost:
            self.texture = SKTexture(imageNamed: "ball-ghost")
        case BallType.Safety:
            self.texture = SKTexture(imageNamed: "ball-safety")
        }
    }
}