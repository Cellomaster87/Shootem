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
    
    var gameTimer: Timer?
    var timerLabel: SKLabelNode!
    var timeRemaining = 60 {
        didSet {
            timerLabel.text = "Time: \(timeRemaining)"
        }
    }
    
    var targetCreationTimer: Timer?
    var targetCreationInterval = 0.8
    var targetSpeed = 4.0
    var targetsCreated = 0
    
    var isGameOver = false // a very useful switch
    
    // MARK: - Scene creation and management
    override func didMove(to view: SKView) {
        createBackground()
        createWater()
        createOverlay()
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        // Reload ammonitions
        if nodesAtPoint.contains(where: { $0.name == "ammonitions" }) {
            reload()
            return
        }
        
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
                // why it doesn't launch at the same size?
            }
        } else {
            if ammonitionsLeft > 0 {
                run(SKAction.playSoundFileNamed("shot", waitForCompletion: false))
                ammonitionsLeft -= 1
                shot(at: location)
            } else {
                run(SKAction.playSoundFileNamed("empty", waitForCompletion: false))
            }
        }
    }
    
    // MARK: - Game Logic
    func startGame() {
        run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
        
        score = 0; ammonitionsLeft = 6; timeRemaining = 60
        
        targetCreationTimer?.invalidate()
        targetCreationTimer = Timer.scheduledTimer(timeInterval: targetCreationInterval, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
    }
    
    @objc func createTarget() {
        let target = Target()
        target.create()
        var isMovingRight = true // sets whether the target is moving from left to right or viceversa
        
        // on which level to create it
        let level = Int.random(in: 0...2)
        switch level {
        case 0:
            // in front of the grass
            target.zPosition = 150
            target.position.y = 280
            target.setScale(0.7) // give a sense of perspective
        case 1:
            // in front of the water background
            target.zPosition = 250
            target.position.y = 220
            target.setScale(0.85)
            isMovingRight = false
        default:
            // in front of the water foreground
            target.zPosition = 350
            target.position.y = 150
        }
        
        // Configure movement
        let move: SKAction
        if isMovingRight {
            target.position.x = -100 // just out of the screen to the left
            move = SKAction.moveTo(x: 1124, duration: targetSpeed)
        } else {
            target.position.x = 1124 // just out of the screen to the right
            move = SKAction.moveTo(x: -100, duration: targetSpeed)
        }
        
        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        target.run(sequence)
        addChild(target)
    }
    
    func reload() {
        guard ammonitionsLeft == 0 else { return }
        ammonitionsLeft = 6
        run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
        // image is automatically updated by the didSet property observer
    }
    
    func shot(at location: CGPoint) {        
        let hitNodes = nodes(at: location).filter { $0.name == "target" }
        
        guard let hitNode = hitNodes.first else { return }
        guard let parentNode = hitNode.parent as? Target else { return } // why is this? Because each target is composed of a target and of a stick.
        
//        switch parentNode.target.name {
//        case "bigTarget":
//            score += 20
//        case "maleDuckTarget":
//            score -= 5
//        case "femaleDuckTarget":
//            score -= 10
//        case "showerDuckTarget":
//            score += 5
//        default:
//            score += 0
//        }
        
        parentNode.isHit()
        score += 3
    }
    
    @objc func updateGameTimer() {
        timeRemaining -= 1
        if timeRemaining == 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        isGameOver = true
        
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.alpha = 0
        gameOverTitle.setScale(2)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 1, duration: 0.3)
        let sequence = SKAction.sequence([fadeIn, scaleDown])
        
        gameOverTitle.run(sequence)
        gameOverTitle.zPosition = 900
        gameOverTitle.position = CGPoint(x: 512, y: 384)
        addChild(gameOverTitle)
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
        gameScore.position = CGPoint(x: 924, y: 725)
        gameScore.zPosition = 500
        gameScore.fontColor = .white
        addChild(gameScore)
        
        ammonitions = SKSpriteNode(imageNamed: "ammo6")
        ammonitions.position = CGPoint(x: 512, y: 67)
        ammonitions.xScale = 1.5
        ammonitions.yScale = 1.5
        ammonitions.zPosition = 500
        ammonitions.name = "ammonitions"
        addChild(ammonitions)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "Time: 60"
        timerLabel.position = CGPoint(x: 100, y: 725)
        timerLabel.zPosition = 500
        addChild(timerLabel)
    }
}
