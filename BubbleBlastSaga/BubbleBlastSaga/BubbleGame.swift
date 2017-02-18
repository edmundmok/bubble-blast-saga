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
    let bubbleCannon = BubbleCannon()
    
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
        // Setup Walls
        setupBubbleGameWalls()
        
        // Setup grid
        setupBubbleGrid()
    }
    
    // Setup the game walls in the bubble game
    func setupBubbleGameWalls() {
        // Left wall
        let leftWallPosition = CGPoint(x: gameArea.frame.origin.x, y: gameArea.frame.origin.y)
        let leftWall = GameWall(wallType: .SideWall, position: leftWallPosition,
            size: CGSize(width: Constants.wallLength, height: gameArea.frame.height))
        
        // Right wall
        let rightWallPosition = CGPoint(x: gameArea.frame.origin.x + gameArea.frame.width,
            y: gameArea.frame.origin.y)
        let rightWall = GameWall(wallType: .SideWall, position: rightWallPosition,
            size: CGSize(width: Constants.wallLength, height: gameArea.frame.height))
        
        // Top wall
        let topWallPosition = CGPoint(x: gameArea.frame.origin.x, y: gameArea.frame.origin.y)
        let topWall = GameWall(wallType: .TopWall, position: topWallPosition,
            size: CGSize(width: gameArea.frame.width, height: Constants.wallLength))
        
        // Bottom wall - move it SLIGHTLY below the screen, so that the bubble doesnt 
        // immediately trigger the collision at the bottom edge of the screen but rather
        // fly down a little first, so that it looks like it flew to eternity instead of
        // being terminated at the edge (aesthetic purposes)
        let bottomWallPosition = CGPoint(x: gameArea.frame.origin.x,
            y: gameArea.frame.maxY + getStandardBubbleSize().width * Constants.bottomWallMultiplier)
        let bottomWall = GameWall(wallType: .BottomWall, position: bottomWallPosition,
            size: CGSize(width: gameArea.frame.width, height: Constants.wallLength))
        
        // Add the walls
        gameEngine.register(gameObject: leftWall)
        gameEngine.register(gameObject: rightWall)
        gameEngine.register(gameObject: topWall)
        gameEngine.register(gameObject: bottomWall)
    }
    
    // Setup the bubble grid for the bubble game
    func setupBubbleGrid() {
        let presentBubblesIndexPath = bubbleGridModel.getIndexPathOfBubblesInGrid()
        
        for presentBubbleIndexPath in presentBubblesIndexPath {
            let bubbleSize = getStandardBubbleSize()
            guard let gameBubble = bubbleGridModel.getGameBubble(at: presentBubbleIndexPath) else {
                continue
            }
            
            // Get position
            guard let bubbleLocation = bubbleGrid.cellForItem(at: presentBubbleIndexPath)?.center else {
                continue
            }
            
            // Prepare the associated bubble image
            let bubbleImage = BubbleGameUtility.getBubbleImage(for: gameBubble)
            bubbleImage.frame.size = bubbleSize
            bubbleImage.center = bubbleLocation
            
            gameBubble.center = bubbleLocation
            gameBubble.radius = getBubbleHitBoxRadius(from: bubbleSize)
            
            gameEngine.register(gameObject: gameBubble, with: bubbleImage)
        }
    }
    
    // Fires a bubble from the given start position, with a given angle at a 
    // fixed speed.
    func fireBubble(from startPosition: CGPoint, at angle: CGFloat) {
        
        // TODO: Consider moving the actual firing into the cannon class
    
        let bubbleSize = getStandardBubbleSize()
        let nextCannonBubble = bubbleCannon.currentBubble
        
        // Prepare the associated bubble image
        let bubbleImage = BubbleGameUtility.getBubbleImage(for: nextCannonBubble)
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
        
        // reload
        bubbleCannon.reloadCannon()
    }
    
    func swapCannonBubble() {
        bubbleCannon.swapCurrentWithNextBubble()
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
}
