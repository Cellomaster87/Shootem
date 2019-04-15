//
//  Target.swift
//  Shootem
//
//  Created by Michele Galvagno on 15/04/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import SpriteKit

class Target: SKNode {
    var target: SKSpriteNode!
    var stick: SKSpriteNode!
    
    func createTarget() {
        let stickType = Int.random(in: 0...2)
        let targetType = Int.random(in: 0...3)
        
        stick = SKSpriteNode(imageNamed: "stick\(stickType)")
        target = SKSpriteNode(imageNamed: "target\(targetType)")
        
        target.name = "target" // to identify it later for destruction
        target.position.y += 116 // why this? Possibly the offset from the bottom of the screen
        
        addChild(stick)
        addChild(target)
    }
    
    func isHit() {
        removeAllActions()
        target.name = nil
        
        let animationTime = 0.2
        target.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        stick.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        run(SKAction.fadeOut(withDuration: animationTime))
        run(SKAction.moveBy(x: 0, y: -30, duration: animationTime))
        run(SKAction.scaleX(by: 0.8, y: 0.7, duration: animationTime))
    }
}
