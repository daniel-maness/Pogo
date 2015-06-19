//
//  PhysicsHelper.swift
//  Pogo
//
//  Created by Daniel Maness on 6/3/15.
//  Copyright (c) 2015 Daniel Maness. All rights reserved.
//

import Foundation
import SpriteKit

class PhysicsHelper {
    class func speed(velocity: CGVector) -> Float {
        let dx = Float(velocity.dx)
        let dy = Float(velocity.dy)
        
        return sqrtf(dx*dx + dy*dy)
    }
    
    class func angularSpeed(velocity: CGFloat) -> Float {
        return abs(Float(velocity))
    }
    
    // This is a more reliable test for a physicsBody at "rest"
    class func nearlyAtRest(node: SKNode) -> Bool {
        let threshold:Float = 0.5
        
        return (self.speed(node.physicsBody!.velocity) < threshold
            && self.angularSpeed(node.physicsBody!.angularVelocity) < threshold)
    }
    
    class func distanceBetweenPoints(first: CGPoint, second: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(second.x - first.x), Float(second.y - first.y)))
    }
    
    class func rotateNode(nodeA: SKNode, endNode: SKNode, toFaceNode nodeB: SKNode) {
        let dx = nodeB.position.x - endNode.position.x
        let dy = nodeB.position.y - endNode.position.y
        let angle: CGFloat = atan2(dy, dx)
        
        nodeA.zRotation = angle + convertDegreesToRadians(90)
    }
    
    class func rotateNode(nodeA: SKNode, endNode: SKNode, toFacePosition position: CGPoint) {
        let dx = position.x - endNode.position.x
        let dy = position.y - endNode.position.y
        let angle: CGFloat = atan2(dy, dx)
        
        nodeA.zRotation = angle + convertDegreesToRadians(90)
    }
    
    class func getAngleBetweenPoints(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let dx = pointB.x - pointA.x
        let dy = pointB.y - pointA.y
        let angle: CGFloat = atan2(dy, dx)
        
        return angle
    }
    
    class func convertDegreesToRadians(angle: CGFloat) -> CGFloat {
        return angle * 0.01745329252
    }
}