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
        
        // Handle collision only between a moving bubble and a stationary bubble
        guard isCollisionBetweenMovingCircleAndStationaryCircle(aCircle: aCircle,
            otherCircle: otherCircle) else {
                
            return
        }
        
        // Identify which is moving, which is stationary
        let movingCircle = (aCircle.velocity != CGVector.zero) ? aCircle : otherCircle
        let stationaryCircle = (movingCircle === aCircle) ? otherCircle : aCircle
        
        // Only deal with collison between GameBubble objects
        guard let movingBubble = movingCircle as? GameBubble,
            let stationaryBubble = stationaryCircle as? GameBubble else {
                return
        }
        
        // For now, we assume that all bubble-bubble collisions follow the same process:
        // 1. Snap to cell
        // 2. Remove similar bubbles
        // 3. Remove unattached bubbles
        // -- This method will be modified if there are more interactions between
        // -- bubbles (e.g. super bubbles)
        
        // Get the index path of the stationary bubble
        guard let stationaryBubbleIndexPath = bubbleGridModel.getIndexPath(for: stationaryBubble) else {
            return
        }
        
        // Check if this bubble is in the last section. If yes, the game should end!
        // But for now, we just print a debug message and remove the moving bubble.
        guard isBeforeLastSection(indexPath: stationaryBubbleIndexPath) else {
            // If they were removed, set bubble position at a far location
            // to prevent future collision checks against this object
            gameEngine.deregister(gameObject: movingBubble)
            movingBubble.center = Constants.pointAtFarLocation
            print("game should end. removing the invalid bubble for now!")
            return
        }
        
        // Get the index path of the neighbours of the stationary bubble
        let neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: stationaryBubbleIndexPath)
        
        // Retrieve an empty neighbouring index path of the stationary
        // bubble that is closest to the moving bubble
        guard let nearestEmptyNeighbourIndexPath = BubbleGameUtility.getNearestEmptyIndexPath(from: movingBubble,
            to: neighboursIndexPath, bubbleGrid: bubbleGrid, bubbleGridModel: bubbleGridModel) else {
            
            // If unable to find nearest index path, this is due to firing too many bubbles at once
            // This would not actually occur in the real game when restricted to 1 projectile
            // For now, just deregister the object and move it away to prevent future collision
            // checks that might give wrong results
            gameEngine.deregister(gameObject: movingBubble)
            movingBubble.center = Constants.pointAtFarLocation
            print("Unable to find nearest index path due to firing too many bubbles at once")
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
        movingBubble.velocity = CGVector.zero
        movingBubble.center = snapCenter
        bubbleGridModel.set(gameBubble: movingBubble, at: nearestEmptyNeighbourIndexPath)
        bubbleGameLogic.handleInteractions(with: movingBubble)
    }
    
    func handleCollisionBetween(_ aCircle: PhysicsCircle, and aBox: PhysicsBox) {
        
        // The game only cares if the box that the circle collided with is a game wall
        guard let wall = aBox as? GameWall else {
            return
        }
        
        // Only concern about the collision if the circle is a GameBubble object
        guard let gameBubble = aCircle as? GameBubble else {
            return
        }
        
        // Check the type of the collided wall
        guard wall.wallType == .TopWall else {
            // If not top wall, it must be a side wall. Just need to reflect the ball.
            // Reflect the horizontal direction of travel (dx) by multiplying by -1
            gameBubble.velocity.dx *= Constants.velocityReflectMultiplier
            return
        }
        
        // Retrieve the index paths of the topmost section (section 0)
        let topSectionIndexPaths = BubbleGameUtility.getIndexPathsForTopSection(of: bubbleGridModel)
        
        // Get the nearest top section index path
        guard let nearestEmptyTopSectionIndexPath = BubbleGameUtility.getNearestEmptyIndexPath(from: gameBubble,
            to: topSectionIndexPaths, bubbleGrid: bubbleGrid, bubbleGridModel: bubbleGridModel) else {
            
            return
        }
        
        // Get the center of the nearest empty top section cell from the index path obtained
        // That is our center to snap to
        guard let snapCenter = bubbleGrid.cellForItem(at: nearestEmptyTopSectionIndexPath)?.center else {
            return
        }
        
        // Snap the game bubble to the empty cell center
        // Also set the bubble into the indexpath in the bubble grid model
        // The collided wall is a top wall
        // Stop the moving circle first
        gameBubble.velocity = CGVector.zero
        gameBubble.center = snapCenter
        bubbleGridModel.set(gameBubble: gameBubble, at: nearestEmptyTopSectionIndexPath)
        bubbleGameLogic.handleInteractions(with: gameBubble)
    }
    
    func handleCollisionBetween(_ aBox: PhysicsBox, and otherBox: PhysicsBox) {
        // Do nothing as my bubble game does not care about collision between two boxes (yet)
        return
    }
    
    // ---------------------- Helper methods --------------------- //
    
    // Returns a boolean representing if the collision between the two given circles is one
    // that is between a moving and stationary circle.
    private func isCollisionBetweenMovingCircleAndStationaryCircle(aCircle: PhysicsCircle,
        otherCircle: PhysicsCircle) -> Bool {
        
        // aCircle is stationary, otherCircle is moving
        if aCircle.velocity == CGVector.zero && otherCircle.velocity != CGVector.zero {
            return true
        }
        
        // aCircle is moving, otherCircle is stationary
        if aCircle.velocity != CGVector.zero && otherCircle.velocity == CGVector.zero {
            return true
        }
        
        return false
    }
    
    // Returns if the given indexpath is in the last section of the bubble grid model.
    private func isBeforeLastSection(indexPath: IndexPath) -> Bool {
        return indexPath.section < bubbleGridModel.numSections - 1
    }
}
