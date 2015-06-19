//
//  PowerMeter.swift
//  Pogo
//
//  Created by Daniel Maness on 6/17/15.
//  Copyright (c) 2015 Daniel Maness. All rights reserved.
//

import Foundation
import SpriteKit

class PowerMeter: SKSpriteNode {
    var dragFromLocation: CGPoint?
    var dragToLocation: CGPoint?
    var dragDistance: CGFloat = 0.0
    var maxDragDistance: CGFloat = 0.0
    var powerLevel: Int = 0
    var width: CGFloat?
    var allowExtraPower: Bool = false
    
    var height: CGFloat {
        get {
            return self.width! + (0.85 * self.width!) * CGFloat(self.powerLevel)
        }
    }
    
    func setPowerLevel(dragFromLocation: CGPoint, dragToLocation: CGPoint) {
        let distance = PhysicsHelper.distanceBetweenPoints(dragFromLocation, second: dragToLocation)
        self.dragDistance = distance > self.maxDragDistance ? self.maxDragDistance : distance
        
        if self.dragDistance >= self.maxDragDistance && allowExtraPower {
            self.powerLevel = 10
        } else if self.dragDistance > self.maxDragDistance * 0.9 && allowExtraPower {
            self.powerLevel = 9
        } else if self.dragDistance > self.maxDragDistance * 0.8 && allowExtraPower {
            self.powerLevel = 8
        } else if self.dragDistance > self.maxDragDistance * 0.7 {
            self.powerLevel = 7
        } else if self.dragDistance > self.maxDragDistance * 0.6 {
            self.powerLevel = 6
        } else if self.dragDistance > self.maxDragDistance * 0.5 {
            self.powerLevel = 5
        } else if self.dragDistance > self.maxDragDistance * 0.4 {
            self.powerLevel = 4
        } else if self.dragDistance > self.maxDragDistance * 0.3 {
            self.powerLevel = 3
        } else if self.dragDistance > self.maxDragDistance * 0.2 {
            self.powerLevel = 2
        } else if self.dragDistance > self.maxDragDistance * 0.1 {
            self.powerLevel = 1
        } else {
            self.powerLevel = 0
        }
    }
    
    init(width: CGFloat, maxDragDistance: CGFloat) {
        self.width = width
        self.maxDragDistance = maxDragDistance
        let texture = SKTexture(imageNamed: "power-meter-1")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.anchorPoint = CGPointMake(0.5, 0)
        self.hidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func show(location: CGPoint) {
        self.texture = SKTexture(imageNamed: powerMeterCategoryName + String(self.powerLevel))
        self.size = CGSizeMake(self.width!, self.height)
        self.position = CGPointMake(location.x, location.y)
        self.hidden = false
    }
    
    func hide() {
        self.hidden = true
    }
    
    func update(dragFromLocation: CGPoint, dragToLocation: CGPoint, originLocation: CGPoint) {
        self.setPowerLevel(dragFromLocation, dragToLocation: dragToLocation)
        
        if self.powerLevel > 0 {
            self.show(originLocation)
            
            let endNode = SKNode()
            endNode.position = CGPointMake(originLocation.x + (dragFromLocation.x - dragToLocation.x), originLocation.y + (dragFromLocation.y - dragToLocation.y))
            
            PhysicsHelper.rotateNode(self, endNode: endNode, toFacePosition: originLocation)
        } else {
            self.hide()
        }
    }
}