//
//  Level.swift
//  Pogo
//
//  Created by Daniel Maness on 6/4/15.
//  Copyright (c) 2015 Daniel Maness. All rights reserved.
//

import Foundation
import SpriteKit

class Level: SKNode {
    var size: CGSize
    let minMargin: Int
    let maxMarginY: Int
    let minWidth: Int
    let minHeight: Int
    let maxWidth: Int
    let maxHeight: Int
    let fillColor = SKColor.grayColor()
    let strokeColor = SKColor.darkGrayColor()
    
    init(size: CGSize, ballDiameter: CGFloat) {
        self.size = CGSizeMake(size.width, size.height)
        self.minMargin = Int(ballDiameter)
        self.maxMarginY = Int(ballDiameter * 10)
        self.minWidth = Int(ballDiameter / 4)
        self.maxWidth = Int(size.width / 2)
        self.minHeight = Int(ballDiameter / 4)
        self.maxHeight = Int(self.maxWidth)
        
        super.init()
        
        setupWorld()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.size = CGSizeMake(0, 0)
        self.minMargin = 0
        self.maxMarginY = 0
        self.minWidth = 0
        self.maxWidth = 0
        self.minHeight = 0
        self.maxHeight = 0
        
        super.init(coder: aDecoder)
    }
    
    func randomRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func setupWorld() {
        self.name = worldCategoryName
        
        let worldRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: worldRect)
        self.physicsBody = worldBorder
        self.physicsBody?.categoryBitMask = worldCategory
        self.physicsBody?.contactTestBitMask = ballCategory
        self.physicsBody?.collisionBitMask = ballCategory
        
        createPlatforms()
    }
    
    func createPlatforms() {
        let numXCells = 15
        let cellSize = Int(self.size.width) / numXCells
        let maxCell = 9
//        let previousXCell = 0
        var previousYCell = 0
        
        let numPlatforms = 100
//        var previousX = minMargin
//        var previousY = minMargin
//        var previousWidth = 0
//        var previousHeight = 0
        
        for _ in 0..<numPlatforms {
            let xCell = randomRange(0, upper: numXCells)
            let x = xCell * cellSize
            
            let yCell = randomRange(previousYCell + 4, upper: previousYCell + maxCell)
            previousYCell = yCell
            let y = yCell * cellSize
            
            let platformSize = randomRange(1, upper: 8)
            let width = platformSize * cellSize
            let height = cellSize
//            let width = randomRange(minWidth, upper: maxWidth)
//            let height = minHeight //randomRange(minHeight, upper: maxHeight)
//            let x = randomRange(width + minMargin, upper: Int(self.size.width) - minMargin)
//            let y = randomRange(previousY + minMargin - height/2, upper: previousY + maxMarginY - height/2)
            
            let platform = SKSpriteNode(imageNamed: "platform-section")
            platform.size = CGSizeMake(CGFloat(width), CGFloat(height))
            platform.position = CGPointMake(CGFloat(x), CGFloat(y))
            platform.name = platformCategoryName
            self.addChild(platform)
            
            platform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(CGFloat(width), CGFloat(height)))
            platform.physicsBody?.dynamic = false
            platform.physicsBody?.categoryBitMask = platformCategory
            platform.physicsBody?.contactTestBitMask = 0x0
            platform.physicsBody?.collisionBitMask = 0x0
            
//            previousX = x
//            previousY = y
//            previousWidth = width
//            previousHeight = height
        }
    }
}