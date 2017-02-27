//
//  BubbleGame.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import Foundation
import PhysicsEngine

class BubbleGame {
    
    // model
    private let bubbleGridModel: BubbleGridModel
    private let bubbleGrid: UICollectionView
    private let gameArea: UIView
    private let bubbleGameAnimator: BubbleGameAnimator
    
    // non-private so that others can query if needed
    let bubbleCannon: BubbleCannon
    let bubbleGameStats = BubbleGameStats()
    let bubbleGameEvaluator: BubbleGameEvaluator
    
    // game related
    private let gameEngine: GameEngine
    private let gameSettings: GameSettings
    
    // Massive init that initializes the entire bubble game and 
    // all its related components.
    init(gameSettings: GameSettings, bubbleGridModel: BubbleGridModel,
        bubbleGrid: UICollectionView, gameArea: UIView) {
        
        self.gameSettings = gameSettings
        self.bubbleGridModel = bubbleGridModel
        self.bubbleGrid = bubbleGrid
        self.gameArea = gameArea
        
        // setup game engine
        let renderer = Renderer(canvas: gameArea)
        let physicsEngine = PhysicsEngine()
        let gameEngine = GameEngine(physicsEngine: physicsEngine, renderer: renderer,
            gameSettings: gameSettings)
        
        let bubbleGameAnimator = BubbleGameAnimator(gameArea: gameArea, renderer: renderer,
            bubbleGrid: bubbleGrid)
        
        let bubbleGameEvaluator = BubbleGameEvaluator(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
        
        let bubbleGameLogic = BubbleGameLogic(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, gameEngine: gameEngine,
            bubbleGameAnimator: bubbleGameAnimator, bubbleGameStats: bubbleGameStats,
            bubbleGameEvaluator: bubbleGameEvaluator)
        
        let collisionHandler = BubbleGameCollisionHandler(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, bubbleGameLogic: bubbleGameLogic,
            gameEngine: gameEngine)
        
        physicsEngine.collisionHandler = collisionHandler
        
        self.bubbleCannon = BubbleCannon(bubbleGridModel: bubbleGridModel)
        self.gameEngine = gameEngine
        self.bubbleGameAnimator = bubbleGameAnimator
        self.bubbleGameEvaluator = bubbleGameEvaluator
    }
    
    // Starts the bubble game running, performing 
    // any necessary setups.
    func startGame() {
        // Setup game
        setupGame()
        // Start the game engine
        gameEngine.startGameLoop()
    }
    
    // Pauses the bubble game.
    func pauseGame() {
        gameEngine.stopGameLoop()
    }
    
    // Ends the bubble game, stopping the game loop
    // and removing all game object images from the renderer.
    func endGame() {
        // Stop the game loop
        gameEngine.stopGameLoop()
        
        // Clear the canvas
        gameEngine.renderer.deregisterAllImages()
    }
    
    // Setup the game
    private func setupGame() {
        // Setup Walls
        setupBubbleGameWalls()
        
        // Setup grid
        setupBubbleGrid()
    }
    
    // Setup the game walls in the bubble game
    private func setupBubbleGameWalls() {

        let wallThickness = Constants.wallThickness
        
        // Side wall height
        let sideWallHeight = gameArea.frame.height * Constants.sideWallHeightMultiplier
        
        // Horizontal wall (top and bottom) width
        let horizontalWallWidth = gameArea.frame.width
            + (Constants.horizontalWallWidthMultiplier * wallThickness)
        
        // Left wall
        let leftWallPosition = CGPoint(x: gameArea.frame.origin.x - wallThickness,
            y: gameArea.frame.origin.y)
        
        let leftWall = GameWall(wallType: .SideWall, position: leftWallPosition,
            size: CGSize(width: wallThickness, height: sideWallHeight))
        
        // Right wall
        let rightWallPosition = CGPoint(x: gameArea.frame.origin.x + gameArea.frame.width,
            y: gameArea.frame.origin.y)
        
        let rightWall = GameWall(wallType: .SideWall, position: rightWallPosition,
            size: CGSize(width: wallThickness, height: sideWallHeight))
        
        // Top wall
        let topWallPosition = CGPoint(x: gameArea.frame.origin.x - wallThickness,
            y: gameArea.frame.origin.y - wallThickness)
        
        let topWall = GameWall(wallType: .TopWall, position: topWallPosition,
            size: CGSize(width: horizontalWallWidth, height: wallThickness))
        
        // Bottom wall - specifically placed slightly below screen bottom edge
        let bottomWallPosition = CGPoint(x: gameArea.frame.origin.x - wallThickness,
            y: gameArea.frame.maxY + (getStandardBubbleSize().width * Constants.bottomWallMultiplier))
        
        let bottomWall = GameWall(wallType: .BottomWall, position: bottomWallPosition,
            size: CGSize(width: horizontalWallWidth, height: wallThickness))
        
        // Add the walls
        gameEngine.register(gameObject: leftWall)
        gameEngine.register(gameObject: rightWall)
        gameEngine.register(gameObject: topWall)
        gameEngine.register(gameObject: bottomWall)
    }
    
    // Setup the bubble grid for the bubble game
    private func setupBubbleGrid() {
        // Get all the present bubble index paths
        let presentBubblesIndexPath = bubbleGridModel.getIndexPathOfBubblesInGrid()
        
        // Get the standard bubble size
        let bubbleSize = getStandardBubbleSize()
        
        for presentBubbleIndexPath in presentBubblesIndexPath {
            
            // Ensure that there is indeed a game bubble at the index path,
            // and that we can get the bubble location in the grid.
            guard let gameBubble = bubbleGridModel.getGameBubble(at: presentBubbleIndexPath),
                let bubbleLocation = bubbleGrid.cellForItem(at: presentBubbleIndexPath)?.center else {
                    
                continue
            }
            
            // Prepare the associated bubble image
            let bubbleImage = BubbleGameUtility.getBubbleImage(for: gameBubble)
            bubbleImage.frame.size = bubbleSize
            bubbleImage.center = bubbleLocation
            
            // Set the actual game bubble attributes
            gameBubble.center = bubbleLocation
            gameBubble.radius = getBubbleHitBoxRadius(from: bubbleSize)
            
            // Register the game bubble into the game engine with the associated image
            gameEngine.register(gameObject: gameBubble, with: bubbleImage)
        }
    }
    
    // Fires a bubble from the given start position, with the given angle, at a
    // fixed speed.
    // Returns a boolean representing whether a bubble was fired or not.
    func fireBubble(from startPosition: CGPoint, at angle: CGFloat) -> Bool {
        
        // Check if there is still ammo to use to fire more bubbles.
        guard bubbleGameEvaluator.canFire() else {
            // If no more ammo, cannot fire anymore. Return false.
            return false
        }
        
        // Otherwise, we can fire!
        // Update game stats to account for new bubble shot.
        bubbleGameStats.incrementBubblesShot()
        
        // Get the standard bubble size, and the bubble to be fired.
        let bubbleSize = getStandardBubbleSize()
        let bubbleToFire = bubbleCannon.currentBubble
        
        // Prepare the associated bubble image
        let bubbleImage = BubbleGameUtility.getBubbleImage(for: bubbleToFire)
        bubbleImage.frame.size = bubbleSize
        bubbleImage.center = startPosition
        
        // Prepare the cannon bubble
        bubbleToFire.center = startPosition
        bubbleToFire.radius = getBubbleHitBoxRadius(from: bubbleSize)
        
        // Get the angle and velocity for the bubble
        bubbleToFire.velocity = getVelocity(for: angle)
        
        // Fire!
        gameEngine.register(gameObject: bubbleToFire, with: bubbleImage)
        
        // Reload the cannon
        bubbleCannon.reloadCannon()
        
        // Bubble was shot, so return true
        return true
    }
    
    // Returns the appropriate velocity vector at the given angle.
    private func getVelocity(for angle: CGFloat) -> CGVector {
        let velocityX = Constants.bubbleSpeed * cos(angle)
        let velocityY = Constants.bubbleSpeed * sin(angle)
        return CGVector(dx: velocityX, dy: velocityY)
    }
    
    // Get the trajectory points starting from the given startPosition and 
    // at the given angle. The trajectory points end when the simulated trajectory
    // bubble stops moving or has simulated to a certain limit number of steps.
    func getTrajectoryPoints(from startPosition: CGPoint, at angle: CGFloat) -> [CGPoint] {
        // Compute attributes of a normal bubble to give the trajectory bubble
        let bubbleSize = getStandardBubbleSize()
        let radius = getBubbleHitBoxRadius(from: bubbleSize)
        
        // Compute the velocity for the trajectory bubble
        let velocityVector = getVelocity(for: angle)
        
        // Create the trajectory bubble
        let trajectoryBubble = TrajectoryBubble(radius: radius, center: startPosition,
            velocity: velocityVector)
        
        // Array to store trajectory points, starting with the start position
        var trajectoryPoints = [startPosition]

        // Run simulation to obtain trajectory points
        for _ in 0..<Constants.trajectoryPointsCount {
            
            // run simulation using the physics engine
            // without actually registering to the game engine
            // to prevent complications with collisions
            gameEngine.physicsEngine.updateState(for: trajectoryBubble)
            trajectoryPoints.append(trajectoryBubble.center)

            // Can just return if bubble stops moving
            // No further useful points can be obtained after it stops
            if trajectoryBubble.velocity == .zero {
                return trajectoryPoints
            }
        }
        
        return trajectoryPoints
    }
    
    // Get the hint for the next move.
    func getHint(from startPosition: CGPoint) -> CGFloat? {
        // create a helper to get the hint
        let bubbleGameHintHelper = BubbleGameHintHelper(bubbleGame: self,
            bubbleGridModel: bubbleGridModel, bubbleGrid: bubbleGrid,
            bubbleCannon: bubbleCannon, bubbleGameAnimator: bubbleGameAnimator,
            gameArea: gameArea)
        
        return bubbleGameHintHelper.getHint(from: startPosition)
    }
    
    // Swap the current cannon bubble with the next cannon bubble.
    func swapCannonBubble() {
        bubbleCannon.swapCurrentWithNextBubble()
    }
    
    // Returns the standard size of a game bubble according to the size of the bubble cell
    // in the current bubble grid collection view.
    func getStandardBubbleSize() -> CGSize {
        return bubbleGrid.visibleCells[0].frame.size
    }
    
    // Returns the hit box radius from the actual bubble size.
    // This is needed as we want to reduce the hitbox to be some percentage of the actual
    // bubble size.
    private func getBubbleHitBoxRadius(from actualBubbleSize: CGSize) -> CGFloat {
        let bubbleRadius = actualBubbleSize.width * Constants.widthToRadiusMultiplier
        return bubbleRadius * Constants.bubbleHitBoxSizePercentage
    }
}
