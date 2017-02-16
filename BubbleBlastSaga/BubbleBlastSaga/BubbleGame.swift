//
//  BubbleGame.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import Foundation

class BubbleGame {
    
    // model
    private let bubbleGridModel: BubbleGridModel
    private let bubbleGrid: UICollectionView
    private let gameArea: UIView
    
    // game engine
    private let gameEngine: GameEngine
    
    // Game settings: What is it for?
    // In the future I want to allow the user to customize bubble speed, etc.
    // Those will go in here. For now, it only has the time step.
    private let gameSettings: GameSettings
    
    init(gameSettings: GameSettings, bubbleGridModel: BubbleGridModel, bubbleGrid: UICollectionView,
         gameArea: UIView) {
        
        self.gameSettings = gameSettings
        self.bubbleGridModel = bubbleGridModel
        self.bubbleGrid = bubbleGrid
        self.gameArea = gameArea
        
        // setup game engine
        let renderer = Renderer(canvas: gameArea)
        let physicsEngine = PhysicsEngine()
        let gameEngine = GameEngine(physicsEngine: physicsEngine, renderer: renderer,
            gameSettings: gameSettings)
        
        let bubbleGameLogic = BubbleGameLogic(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, gameEngine: gameEngine)
        
        let collisionHandler = BubbleGameCollisionHandler(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, bubbleGameLogic: bubbleGameLogic,
            gameEngine: gameEngine)
        
        physicsEngine.collisionHandler = collisionHandler
        
        self.gameEngine = gameEngine
    }
    
    // Starts the bubble game running
    func startGame() {
        // Setup game
        setupGame()
        // Start the game engine
        gameEngine.startGameLoop()
    }
    
    // Setup the game
    private func setupGame() {
        // For now only set up game walls, maybe in the future more setup code
        // like setup obstacles?
        setupBubbleGameWalls()
    }
    
    // Setup the game walls in the bubble game
    func setupBubbleGameWalls() {
        // Left wall
        let leftWallPosition = CGPoint(x: gameArea.frame.origin.x, y: gameArea.frame.origin.y)
        let leftWall = GameWall(wallType: .SideWall, position: leftWallPosition,
            size: CGSize(width: Constants.wallWidth, height: gameArea.frame.height))
        
        // Right wall
        let rightWallPosition = CGPoint(x: gameArea.frame.origin.x + gameArea.frame.width,
            y: gameArea.frame.origin.y)
        let rightWall = GameWall(wallType: .SideWall, position: rightWallPosition,
            size: CGSize(width: Constants.wallWidth, height: gameArea.frame.height))
        
        // Top wall
        let topWallPosition = CGPoint(x: gameArea.frame.origin.x, y: gameArea.frame.origin.y)
        let topWall = GameWall(wallType: .TopWall, position: topWallPosition,
            size: CGSize(width: gameArea.frame.width, height: Constants.wallWidth))
        
        // Add the walls
        gameEngine.register(gameObject: leftWall)
        gameEngine.register(gameObject: rightWall)
        gameEngine.register(gameObject: topWall)
    }
    
    // Fires a bubble from the given start position, with a given angle at a 
    // fixed speed.
    func fireBubble(from startPosition: CGPoint, at angle: CGFloat) {
    
        let bubbleSize = getStandardBubbleSize()
        let nextCannonBubble = getNextCannonBubble()
        
        // Prepare the associated bubble image
        let bubbleImage = getBubbleImage(for: nextCannonBubble)
        bubbleImage.frame.size = bubbleSize
        bubbleImage.center = startPosition
        
        // Prepare the cannon bubble
        nextCannonBubble.center = startPosition
        nextCannonBubble.radius = getBubbleHitBoxRadius(from: bubbleSize)
        
        // Get the angle and velocity for the bubble
        let totalVelocity = Constants.bubbleSpeed
        let velocityX = totalVelocity * cos(angle)
        let velocityY = totalVelocity * sin(angle)
        nextCannonBubble.velocity = CGVector(dx: velocityX, dy: velocityY)
        
        // Fire!
        gameEngine.register(gameObject: nextCannonBubble, with: bubbleImage)
    }
    
    // Returns the standard size of a game bubble according to the size of the bubble cell
    // in the current bubble grid collection view.
    private func getStandardBubbleSize() -> CGSize {
        return bubbleGrid.visibleCells[0].frame.size
    }
    
    // Returns the hit box radius from the actual bubble size.
    // This is needed as we want to reduce the hitbox to be some percentage of the actual
    // bubble size.
    private func getBubbleHitBoxRadius(from actualBubbleSize: CGSize) -> CGFloat {
        let bubbleRadius = actualBubbleSize.width * CGFloat(0.5)
        return bubbleRadius * CGFloat(Constants.bubbleHitBoxSizePercentage)
    }
    
    // Randomly generates the next cannon bubble and returns it.
    private func getNextCannonBubble() -> GameBubble {
        let randomGameBubbleNumber = arc4random() % Constants.numberOfBubbles
        switch randomGameBubbleNumber {
        case 0: return ColoredBubble(color: .Red)
        case 1: return ColoredBubble(color: .Blue)
        case 2: return ColoredBubble(color: .Orange)
        case 3: return ColoredBubble(color: .Green)
        default: return ColoredBubble(color: .Red)
        }
    }
    
    // Returns the bubble image associated with the given game bubble.
    private func getBubbleImage(for gameBubble: GameBubble) -> UIImageView {
        guard let coloredBubble = gameBubble as? ColoredBubble else {
            return UIImageView()
        }
        
        switch coloredBubble.color {
        case .Red: return UIImageView(image: UIImage(named: Constants.redBubbleImage))
        case .Blue: return UIImageView(image: UIImage(named: Constants.blueBubbleImage))
        case .Orange: return UIImageView(image: UIImage(named: Constants.orangeBubbleImage))
        case .Green: return UIImageView(image: UIImage(named: Constants.greenBubbleImage))
        }
    }
}