//
//  BubbleGameCollisionHandler.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameCollisionHandler {
    
    fileprivate let bubbleGrid: UICollectionView
    fileprivate let bubbleGridModel: BubbleGridModel
    fileprivate let bubbleGameLogic: BubbleGameLogic
    fileprivate let gameEngine: GameEngine
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel,
        bubbleGameLogic: BubbleGameLogic, gameEngine: GameEngine) {
        
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        self.bubbleGameLogic = bubbleGameLogic
        self.gameEngine = gameEngine
    }
}

// MARK: CollisionHandler
extension BubbleGameCollisionHandler: CollisionHandler {
    
    // --------------------- Collision Handlers ---------------------- //
    
    func handleCollisionBetween(_ aCircle: PhysicsCircle, and otherCircle: PhysicsCircle) {
        
        // Handle collision between 2 moving bubbles
        if aCircle.velocity != .zero && otherCircle.velocity != .zero {
            // Simply bounce them off each other
            handleCollisionBetweenTwoMovingCircles(aCircle: aCircle, otherCircle: otherCircle)
            return
        }
        
        // Handle collision only between a moving bubble and a stationary bubble
        guard isCollisionBetweenMovingCircleAndStationaryCircle(aCircle: aCircle,
            otherCircle: otherCircle) else {
                
            return
        }
        
        // Identify which is moving, which is stationary
        let movingCircle = (aCircle.velocity != .zero) ? aCircle : otherCircle
        let stationaryCircle = (movingCircle === aCircle) ? otherCircle : aCircle
        
        // Only deal with collision between GameBubble objects
        // First, get the index path of the stationary bubble
        guard let movingBubble = movingCircle as? GameBubble,
            let stationaryBubble = stationaryCircle as? GameBubble,
            let stationaryBubbleIndexPath = bubbleGridModel.getIndexPath(for: stationaryBubble) else {
                
            return
        }
        
        // Get the index path of the neighbours of the stationary bubble
        let neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: stationaryBubbleIndexPath)
        
        // Retrieve an empty neighbouring index path of the stationary
        // bubble that is closest to the moving bubble
        guard let nearestEmptyNeighbourIndexPath = BubbleGameUtility.getNearestEmptyIndexPath(
            from: movingBubble, to: neighboursIndexPath, bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel) else {
        
            // Due to firing too many bubbles, some bubbles cannot find a snap location
            // Deregister these bubbles
            gameEngine.deregister(gameObject: movingBubble)
            movingBubble.center = Constants.pointAtFarLocation
            return
        }
        
        // Get the center point of that nearest empty neighbour index path
        // It will be the center our moving bubble will snap to
        guard let snapCenter = bubbleGrid.cellForItem(at: nearestEmptyNeighbourIndexPath)?.center else {
            return
        }
        
        // Snap the moving circle to that nearest empty cell
        // Also set the bubble into the indexpath in the bubble grid model
        // Stop the moving circle first
        movingBubble.velocity = .zero
        movingBubble.center = snapCenter
        
        
        // At this point, the bubble may be a TrajectoryBubble used to compute trajectory
        // path, or a normal cannon bubble shot from the cannon.
        
        // Only handle futher interactions if not trajectory bubble
        if movingBubble is TrajectoryBubble {
            // If it is a trajectory bubble, so we only needed it to snap
            // No need to handle any interactions
            return
        }
        
        // If not a trajectory bubble, then it is a regular bubble fired from the cannon
        // so we need to handle normal interactions
        updateModel(with: movingBubble, at: nearestEmptyNeighbourIndexPath)
    }
    
    // Snaps the moving bubble at the given bubble grid index path, and
    // calls the logic to handle the resulting interactions.
    private func updateModel(with gameBubble: GameBubble, at indexPath: IndexPath) {
        bubbleGridModel.set(gameBubble: gameBubble, at: indexPath)
        bubbleGameLogic.handleInteractions(with: gameBubble)
    }
    
    func handleCollisionBetween(_ aCircle: PhysicsCircle, and aBox: PhysicsBox) {
        
        // The game only cares if the box that the circle collided with is a game wall
        // Only concern about the collision if the circle is a GameBubble object
        guard let wall = aBox as? GameWall,
            let gameBubble = aCircle as? GameBubble else {
                
            return
        }
        
        switch wall.wallType {
        case .BottomWall:
            handleCollisionBetweenBottomWall(and: gameBubble)
        case .SideWall:
            handleCollisionBetweenSideWall(and: gameBubble)
        case .TopWall:
            handleCollisionBetweenTopWall(and: gameBubble)
        }
    }
    
    private func handleCollisionBetweenBottomWall(and gameBubble: GameBubble) {
        // ignore if trajectory bubble
        if gameBubble is TrajectoryBubble {
            return
        }
        
        // If the bubble flies too far down the bottom, remove it from the game
        gameEngine.deregister(gameObject: gameBubble)
        
        // Inform logic that the it was out of bounds
        bubbleGameLogic.handleBubbleOutOfBounds()
    }
    
    private func handleCollisionBetweenSideWall(and gameBubble: GameBubble) {
        // If not top wall, it must be a side wall. Just need to reflect the ball.
        // Reflect the horizontal direction of travel (dx) by multiplying by -1
        gameBubble.velocity.dx *= Constants.velocityReflectMultiplier
    }
    
    private func handleCollisionBetweenTopWall(and gameBubble: GameBubble) {
        // Retrieve the index paths of the topmost section (section 0)
        let indexPaths = BubbleGameUtility.getIndexPathsForTopSection(of: bubbleGridModel)
        
        // Get the nearest top section index path
        // Get the center of the nearest empty top section cell from the index path obtained
        // That is our center to snap to
        guard let nearestEmptyIndexPath = BubbleGameUtility.getNearestEmptyIndexPath(from: gameBubble,
            to: indexPaths, bubbleGrid: bubbleGrid, bubbleGridModel: bubbleGridModel),
            let snapCenter = bubbleGrid.cellForItem(at: nearestEmptyIndexPath)?.center else {
            
            return
        }
        
        // Snap the game bubble to the empty cell center
        // Also set the bubble into the indexpath in the bubble grid model
        // The collided wall is a top wall
        // Stop the moving circle first
        gameBubble.velocity = .zero
        gameBubble.center = snapCenter
        
        // At this point, the bubble may be a TrajectoryBubble used to compute trajectory
        // path, or a normal cannon bubble shot from the cannon.
        
        // Only handle futher interactions if not trajectory bubble
        if gameBubble is TrajectoryBubble {
            // Otherwise it is a trajectory bubble, so we only needed it to snap
            // No need to handle any interactions
            return
        }
        
        // If not a trajectory bubble, then it is a regular bubble fired from the cannon
        // so we need to handle normal interactions
        updateModel(with: gameBubble, at: nearestEmptyIndexPath)
    }

    
    func handleCollisionBetween(_ aBox: PhysicsBox, and otherBox: PhysicsBox) {
        return
    }
    
    // ---------------------- Helper methods --------------------- //
    
    private func handleCollisionBetweenTwoMovingCircles(aCircle: PhysicsCircle, otherCircle: PhysicsCircle) {
        
        // Ignore any trajectory bubble collision with actual flying bubbles that were fired before
        if aCircle is TrajectoryBubble || otherCircle is TrajectoryBubble {
            return
        }
        
        // We need them to bounce off each other upon collision
        // Referencing physics from: 
        // http://ericleong.me/research/circle-circle/#dynamic-circle---static-circle-collision
        
        // Assume a arbitrary constant mass
        let mass = Constants.bubbleStandardMass
        
        // Get distance between two points of collision
        let distance = aCircle.center.distance(to: otherCircle.center)
        
        // Find norm of vector from point of collision of first circle and 
        // point of collision of second circle
        let normX = (otherCircle.center.x - aCircle.center.x) / distance
        let normY = (otherCircle.center.y - aCircle.center.y) / distance
        
        // Calculate the p-value that takes into account the velocities of both circles
        let pValFirstCircleHalf = aCircle.velocity.dx * normX + aCircle.velocity.dy * normY
        let pValSecondCircleHalf = otherCircle.velocity.dx * normX + otherCircle.velocity.dy * normY
        let pVal = 2 * (pValFirstCircleHalf - pValSecondCircleHalf) / (mass + mass)
        
        // Compute the final velocities
        let aCircleNewDx = aCircle.velocity.dx - pVal * mass * normX
        let aCircleNewDy = aCircle.velocity.dy - pVal * mass * normY
        
        let otherCircleNewDx = otherCircle.velocity.dx + pVal * mass * normX
        let otherCircleNewDy = otherCircle.velocity.dy + pVal * mass * normY
        
        // Set their new velocities
        aCircle.velocity.dx = aCircleNewDx
        aCircle.velocity.dy = aCircleNewDy
        
        otherCircle.velocity.dx = otherCircleNewDx
        otherCircle.velocity.dy = otherCircleNewDy
        
        // Move the circles away from each other so they no longer overlap.
        separateCollidedCircles(aCircle: aCircle, otherCircle: otherCircle)
    }
    
    // Move the circles away from each other so they no longer overlap to prevent repeated collisions
    private func separateCollidedCircles(aCircle: PhysicsCircle, otherCircle: PhysicsCircle) {
        // First get their midpoint of the 2 centers
        let midpointX = (aCircle.center.x + otherCircle.center.x) / 2
        let midpointY = (aCircle.center.y + otherCircle.center.y) / 2
        
        let distance = aCircle.center.distance(to: otherCircle.center)
        
        // Set the new centers of the circles to be the radius (R) away from p along the
        // line that connects the centers of the two radii.
        aCircle.center.x = midpointX
            + aCircle.radius * (aCircle.center.x - otherCircle.center.x) / distance
        aCircle.center.y = midpointY
            + aCircle.radius * (aCircle.center.y - otherCircle.center.y) / distance
        
        otherCircle.center.x = midpointX
            + otherCircle.radius * (otherCircle.center.x - aCircle.center.x) / distance
        otherCircle.center.y = midpointY
            + otherCircle.radius * (otherCircle.center.y - aCircle.center.y) / distance
    }
    
    // Returns a boolean representing if the collision between the two given circles is one
    // that is between a moving and stationary circle.
    private func isCollisionBetweenMovingCircleAndStationaryCircle(aCircle: PhysicsCircle,
        otherCircle: PhysicsCircle) -> Bool {
        
        // aCircle is stationary, otherCircle is moving
        if aCircle.velocity == .zero && otherCircle.velocity != .zero {
            return true
        }
        
        // aCircle is moving, otherCircle is stationary
        if aCircle.velocity != .zero && otherCircle.velocity == .zero {
            return true
        }
        
        return false
    }
    
    // Returns if the given indexpath is in the last section of the bubble grid model.
    private func isBeforeLastSection(indexPath: IndexPath) -> Bool {
        return indexPath.section < bubbleGridModel.numSections - 1
    }
}
