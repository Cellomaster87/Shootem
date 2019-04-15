//
//  GameScene.swift
//  Shootem
//
//  Created by Michele Galvagno on 15/04/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: - Properties
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var ammonitions: SKSpriteNode!
    var ammonitionsLeft = 6 {
        didSet {
            ammonitions.texture = SKTexture(imageNamed: "ammo\(ammonitionsLeft)")
        }
    }
    
    override func didMove(to view: SKView) {
        createBackground()
        createWater()
        createOverlay()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK: - Helper methods
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 512, y: 384)
        background.size = view!.frame.size
        background.blendMode = .replace
        addChild(background)
        
        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 512, y: 300)
        grass.size = CGSize(width: view!.frame.width, height: grass.frame.height)
        addChild(grass)
        grass.zPosition = 100
    }
    
    func createWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let movementUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let movementDown = movementUp.reversed()
            let sequence = SKAction.sequence([movementUp, movementDown])
            let repeatForever = SKAction.repeatForever(sequence)
            node.run(repeatForever)
        }
        
        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: 512, y: 180)
        waterBackground.size = CGSize(width: view!.frame.width, height: waterBackground.frame.height)
        waterBackground.zPosition = 200
        addChild(waterBackground)
        
        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: 512, y: 120)
        waterForeground.size = CGSize(width: view!.frame.width, height: waterForeground.frame.height)
        waterForeground.zPosition = 300
        addChild(waterForeground)
        
        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }
    
    func createOverlay() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 512 , y: 384)
        curtains.size = view!.frame.size
        curtains.zPosition = 400
        addChild(curtains)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 750, y: 55)
        gameScore.zPosition = 500
        gameScore.fontSize = 40
        gameScore.fontColor = .white
        addChild(gameScore)
        
        ammonitions = SKSpriteNode(imageNamed: "ammo6")
        ammonitions.position = CGPoint(x: 274, y: 67)
        ammonitions.xScale = 1.5
        ammonitions.yScale = 1.5
        ammonitions.zPosition = 500
        addChild(ammonitions)
    }
}
