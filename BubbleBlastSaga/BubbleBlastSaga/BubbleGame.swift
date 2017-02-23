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
    private let bubbleGameAnimator: BubbleGameAnimator
    
    // game engine
    private let gameEngine: GameEngine
    
    // Game settings: What is it for?
    // In the future I want to allow the user to customize bubble speed, etc.
    // Those will go in here. For now, it only has the time step.
    private let gameSettings: GameSettings
    
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
        
        let bubbleGameLogic = BubbleGameLogic(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, gameEngine: gameEngine,
            bubbleGameAnimator: bubbleGameAnimator)
        
        let collisionHandler = BubbleGameCollisionHandler(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel, bubbleGameLogic: bubbleGameLogic,
            gameEngine: gameEngine)
        
        physicsEngine.collisionHandler = collisionHandler
        
        self.gameEngine = gameEngine
        self.bubbleGameAnimator = bubbleGameAnimator
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
    
    // Get the trajectory points starting from the given startPosition and 
    // at the given angle.
    func getTrajectoryPoints(from startPosition: CGPoint, at angle: CGFloat) -> [CGPoint] {
        // Compute attributes of a normal bubble to give the trajectory bubble
        let bubbleSize = getStandardBubbleSize()
        let center = startPosition
        let radius = getBubbleHitBoxRadius(from: bubbleSize)
        
        // Compute the velocity for the trajectory bubble
        let totalVelocity = Constants.bubbleSpeed
        let velocityX = totalVelocity * cos(angle)
        let velocityY = totalVelocity * sin(angle)
        let velocityVector = CGVector(dx: velocityX, dy: velocityY)
        
        // Create the trajectory bubble
        let trajectoryBubble = TrajectoryBubble(radius: radius, center: center, velocity: velocityVector)
        
        // Array to store trajectory points, starting with the start position
        var trajectoryPoints = [CGPoint]()
        trajectoryPoints.append(startPosition)

        // Run simulation to obtain trajectory points
        for _ in 0..<Constants.trajectoryPointsCount {
            
            // run simulation using the physics engine
            // without actually registering to the game engine
            // to prevent complications with collisions
            gameEngine.physicsEngine.updateState(for: trajectoryBubble)
            trajectoryPoints.append(trajectoryBubble.center)

            
            // Can just return if bubble stops moving
            // No further useful points can be obtained after it stops
            guard trajectoryBubble.velocity != CGVector.zero else {
                return trajectoryPoints
            }
        }
        
        return trajectoryPoints
    }
    
    // ------------------------ HINT RELATED ------------------------
    
    // Get the hint for the next move.
    func getHint(from startPosition: CGPoint) -> CGFloat? {
        
        // TODO: Refactor this line
        guard let currentColoredBubble = bubbleCannon.currentBubble as? ColoredBubble else {
            return nil
        }
        
        // get all the candidate positions
        let candidates = getCandidates(for: currentColoredBubble)
        
        var candidateCountDictionary = [IndexPath: Int]()
        for candidate in candidates {
            guard let modelCopy = bubbleGridModel.copy() as? BubbleGridModel else {
                continue
            }
            
            modelCopy.set(gameBubble: bubbleCannon.currentBubble, at: candidate)
            let bubbleGameLogicSim = BubbleGameLogicSimulator(bubbleGrid: bubbleGrid, bubbleGridModel: modelCopy)
            
            let count = bubbleGameLogicSim.handleInteractions(with: bubbleCannon.currentBubble)
            
            candidateCountDictionary[candidate] = count
        }
        
        let myArr = Array(candidateCountDictionary.keys)
        let sortedCandidates = myArr.sorted {
            let obj1 = candidateCountDictionary[$0] ?? 0 // get ob associated w/ key 1
            let obj2 = candidateCountDictionary[$1] ?? 0 // get ob associated w/ key 2
            return obj1 > obj2
        }
    
        for candidate in sortedCandidates {
            guard let targetCell = bubbleGrid.cellForItem(at: candidate) else {
                continue
            }
            
            let targetCenter = targetCell.center
            
            // try direct angle
            let directAngle = atan2(targetCenter.y - startPosition.y,
                              targetCenter.x - startPosition.x)
            
            if let finalPosition = getTrajectoryPoints(from: startPosition, at: directAngle).last {
                // check if direct angle lands at location close enough
                guard finalPosition.distance(to: targetCenter) > targetCell.frame.size.width else {
                    bubbleGameAnimator.flashHintLocations(candidate)
                    return directAngle
                }
            }
 
            
            // try left angle
            let leftReboundCoord = getCoordinateForLeftRebound(from: startPosition, to: targetCenter)
            let leftReboundAngle = atan2(leftReboundCoord.y - startPosition.y,
                                         leftReboundCoord.x - startPosition.x)
            
            if let finalPosition = getTrajectoryPoints(from: startPosition, at: leftReboundAngle).last {
                // check if direct angle lands at location close enough
                guard finalPosition.distance(to: targetCenter) > targetCell.frame.size.width else {
                    bubbleGameAnimator.flashHintLocations(candidate)
                    return leftReboundAngle
                }
            }
            
            // try right angle
            let rightReboundCoord = getCoordinateForRightRebound(from: startPosition, to: targetCenter)
            let rightReboundAngle = atan2(rightReboundCoord.y - startPosition.y,
                                         rightReboundCoord.x - startPosition.x)
            
            if let finalPosition = getTrajectoryPoints(from: startPosition, at: rightReboundAngle).last {
                // check if direct angle lands at location close enough
                guard finalPosition.distance(to: targetCenter) > targetCell.frame.size.width else {
                    bubbleGameAnimator.flashHintLocations(candidate)
                    return rightReboundAngle
                }
            }
            
        }
        
        // if still no positions to shoot:
        // - Recommend a swap to the next bubble
        // - If even after swap, still no valid location, just recommend to fire at a decent location
        // - Decent location (subjective) means:
        //   1. As high as possible so that it does not accidentally lose the game
        return nil
    }
    
    private func getCoordinateForLeftRebound(from startPosition: CGPoint, to coordinate: CGPoint) -> CGPoint {
        let actualRadiusOfBubble = getStandardBubbleSize().width * 0.5 * CGFloat(Constants.bubbleHitBoxSizePercentage)
        
        // w3
        let horizontalDistanceFromStartPositionToWall = startPosition.distance(to: CGPoint(x: gameArea.frame.minX + actualRadiusOfBubble, y: startPosition.y))
        
        // w2
        let horizontalDistanceFromReflectedPointToWall = horizontalDistanceFromStartPositionToWall - (startPosition.x - coordinate.x)
        
        // w1
        let horizontalDistanceFromStartPositionToReflectedPoint = horizontalDistanceFromStartPositionToWall - horizontalDistanceFromReflectedPointToWall
        
        // ratio = w1 / w2
        let triangleRatio = horizontalDistanceFromStartPositionToReflectedPoint / horizontalDistanceFromReflectedPointToWall
        
        // h = (Yd - Ys) / (2 + ratio)
        let heightToSymmetryLine = (coordinate.y - startPosition.y) / (2 + triangleRatio)
        
        // left rebound coord
        let reboundCoord = CGPoint(x: gameArea.frame.minX + actualRadiusOfBubble, y: coordinate.y - heightToSymmetryLine)
        return reboundCoord
    }
    
    private func getCoordinateForRightRebound(from startPosition: CGPoint, to coordinate: CGPoint) -> CGPoint {
        let actualRadiusOfBubble = getStandardBubbleSize().width * 0.5 * CGFloat(Constants.bubbleHitBoxSizePercentage)
        
        // w3
        let horizontalDistanceFromStartPositionToWall = startPosition.distance(to: CGPoint(x: gameArea.frame.maxX - actualRadiusOfBubble, y: startPosition.y))
        
        // w2
        let horizontalDistanceFromReflectedPointToWall = horizontalDistanceFromStartPositionToWall - (coordinate.x - startPosition.x)
        
        // w1
        let horizontalDistanceFromStartPositionToReflectedPoint = horizontalDistanceFromStartPositionToWall - horizontalDistanceFromReflectedPointToWall
        
        // ratio = w1 / w2
        let triangleRatio = horizontalDistanceFromStartPositionToReflectedPoint / horizontalDistanceFromReflectedPointToWall
        
        // h = (Yd - Ys) / (2 + ratio)
        let heightToSymmetryLine = (coordinate.y - startPosition.y) / (2 + triangleRatio)
        
        // left rebound coord
        let reboundCoord = CGPoint(x: gameArea.frame.maxX - actualRadiusOfBubble, y: coordinate.y - heightToSymmetryLine)
        return reboundCoord
    }
    
    private func getCandidates(for coloredBubble: ColoredBubble) -> [IndexPath] {
        // assuming that the last section is empty (game should be over otherwise anyway)
        let bottomIndexPaths = BubbleGameUtility.getIndexPathsForBottomSection(of: bubbleGridModel)
        
        // bfs from bottom section, look for empty cells that have filled neighbours, add them
        // to the set
        var queue = Queue<IndexPath>()
        var visited = Set<IndexPath>()
        
        var candidates = [IndexPath]()
        
        bottomIndexPaths
            .filter { bubbleGridModel.getGameBubble(at: $0) == nil }
            .forEach {
                queue.enqueue($0)
                visited.insert($0)
            }
        
        while !queue.isEmpty {
            guard let next = try? queue.dequeue() else {
                break
            }
            
            
            let nextNeighbours = bubbleGridModel.getNeighboursIndexPath(of: next)
            
            guard bubbleGridModel.getGameBubble(at: next) == nil else {
                continue
            }
            
            
            // TODO: REFACTOR this
            let isCandidate =  nextNeighbours
                .filter {
                    
                    if let powerBubble = bubbleGridModel.getGameBubble(at: $0) as? PowerBubble {
                        guard powerBubble.power != .Indestructible else {
                            return false
                        }
                        return true
                    }
                    
                    return (bubbleGridModel.getGameBubble(at: $0) as? ColoredBubble)?.color == coloredBubble.color
                
                }
                .count > 0
            
            if isCandidate {
                candidates.append(next)
            }
            
            nextNeighbours
                .filter { !visited.contains($0) }
                .forEach {
                    queue.enqueue($0)
                    visited.insert($0)
                }
        }
        
        return candidates
    }
    
    // ------------------------ HINT RELATED ------------------------
    
    // Swap the current cannon bubble with the next cannon bubble.
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
