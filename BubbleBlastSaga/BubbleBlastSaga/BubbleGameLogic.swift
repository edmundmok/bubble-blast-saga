//
//  BubbleGameLogic.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameLogic {
    
    private let bubbleGrid: UICollectionView
    private let bubbleGridModel: BubbleGridModel
    private let gameEngine: GameEngine
    private let bubbleGameAnimator: BubbleGameAnimator
    private let bubbleGameStats: BubbleGameStats
    private let bubbleGameEvaluator: BubbleGameEvaluator
    
    // Special data structure for chaining to avoid checking special bubble activation repeatedly
    private var bubblesActivated = Set<IndexPath>()
    // Special data structure to check which bubbles have already been marked to be removed
    private var bubblesToRemove = Set<IndexPath>()
    // track the current chaining count
    private var currentChainCount = 0
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel, gameEngine: GameEngine,
        bubbleGameAnimator: BubbleGameAnimator, bubbleGameStats: BubbleGameStats,
        bubbleGameEvaluator: BubbleGameEvaluator) {
        
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        self.gameEngine = gameEngine
        self.bubbleGameAnimator = bubbleGameAnimator
        self.bubbleGameStats = bubbleGameStats
        self.bubbleGameEvaluator = bubbleGameEvaluator
    }
    
    // Handles the case when a bubble was detected to be out of bounds.
    func handleBubbleOutOfBounds() {
        // No bubbles were removed by this failed shot, reset necessary stats
        bubbleGameStats.updateStatsWithFailedShot()
        
        // Inform evaluator that flying bubble has landed
        bubbleGameEvaluator.updateFlyingBubbleLanded()
        bubbleGameEvaluator.evaluateGame()
    }
    
    // Handle the resulting interactions of the snapped bubble, such as removing connected
    // bubbles and also removing floating bubbles after.
    func handleInteractions(with snappedBubble: GameBubble) {
        
        // Redraw first to show snapped position
        gameEngine.renderer.draw([snappedBubble])
        
        // The game only shoots colored bubbles
        guard let coloredBubble = snappedBubble as? ColoredBubble else {
            return
        }
        
        // Reset the special data structure at the start of each interaction handling
        bubblesActivated = Set<IndexPath>()
        bubblesToRemove = Set<IndexPath>()
        currentChainCount = 0
        
        // activate special bubbles if present
        activateSpecialBubbles(near: coloredBubble)
        
        let countForBubblesRemovedBySpecialInteractions = bubblesToRemove.count
        
        // reset bubblesToRemove
        bubblesToRemove = Set<IndexPath>()
        
        // otherwise, attempt to carry out normal bubble removals
        handleColoredInteractions(with: coloredBubble)
        
        let totalBubblesRemoved = countForBubblesRemovedBySpecialInteractions + bubblesToRemove.count
        
        defer {            
            // Flying bubble landed
            bubbleGameEvaluator.updateFlyingBubbleLanded()
            bubbleGameEvaluator.evaluateGame()
        }

        // update the stats
        guard totalBubblesRemoved > 0 else {
            // no bubbles were removed by this shot, reset necessary stats
            bubbleGameStats.updateStatsWithFailedShot()
            return
        }
        
        bubbleGameStats.updateStatsWithSuccessfulShot(removalCount: totalBubblesRemoved,
            chainCount: currentChainCount, with: coloredBubble)
    }
    
    private func activateSpecialBubbles(near snappedBubble: ColoredBubble) {
        // get the indexpath of the snapped bubble
        guard let indexPath = bubbleGridModel.getIndexPath(for: snappedBubble) else {
            return
        }
        // get the neighbours index path of the snapped bubble
        let neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: indexPath)

        // check the specialness of each neighbour
        let specialNeighbours = getSpecialBubblesIndexPath(from: neighboursIndexPath)
        
        // activate all special neighbours
        specialNeighbours.forEach { activateSpecialBubble(at: $0, with: snappedBubble) }
    }
    
    // Returns the index paths that contain special bubbles, out of the array of given
    // index paths.
    private func getSpecialBubblesIndexPath(from indexPaths: [IndexPath]) -> [IndexPath] {
        var specialIndexPaths = [IndexPath]()
        
        for indexPath in indexPaths {
            guard let _ = bubbleGridModel.getGameBubble(at: indexPath) as? PowerBubble else {
                continue
            }
            specialIndexPaths.append(indexPath)
        }
        return specialIndexPaths
    }
    
    // Activates the special bubble at the given index path, with given bubble as the activating bubble.
    private func activateSpecialBubble(at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // Index path given should be a power bubble
        guard let powerBubble = bubbleGridModel.getGameBubble(at: indexPath) as? PowerBubble else {
            // If no power bubble found, return
            return
        }
        
        // Check type of power and activate accordingly
        switch powerBubble.power {
        case .Lightning: activate(lightningBubble: powerBubble, at: indexPath, with: activatingBubble)
        case .Bomb: activate(bombBubble: powerBubble, at: indexPath, with: activatingBubble)
        case .Star: activate(starBubble: powerBubble, at: indexPath, with: activatingBubble)
        default: return
        }
    }
    
    // Activates a lightning bubble at that index path, 
    // and removes all bubbles in the same section as it
    private func activate(lightningBubble: PowerBubble, at indexPath: IndexPath,
        with activatingBubble: ColoredBubble) {
        
        // Add to the special datastructure to avoid repeatedly chaining each other
        bubblesActivated.insert(indexPath)
        
        // Index paths to remove are all those on the same section
        let indexPathsToRemove = bubbleGridModel.getIndexPathsForSectionContaining(indexPath: indexPath)
        
        // Animate a lightning on that section
        bubbleGameAnimator.animateLightning(for: indexPath)
        
        // Attempt to chain, activating bubble is the lightning bubble
        indexPathsToRemove
            .filter {
                // Ensure that the bubble to chain to has not been activated before
                guard !bubblesActivated.contains($0) else {
                    return false
                }
                
                // Check that the index path we want to activate contains a power bubble
                guard let powerType = (bubbleGridModel.getGameBubble(at: $0) as? PowerBubble)?.power else {
                    return false
                }
                
                // Check that it is actually a special bubble and is not a indestructible
                return powerType != .Indestructible
            }
            .forEach {
                // For each successful chain, increase chain count and start the chain
                if !bubblesActivated.contains($0) {
                    currentChainCount += 1
                }
                activateSpecialBubble(at: $0, with: activatingBubble)
            }
        
        // Remove the bubbles affected by this lightning bubble's effect
        indexPathsToRemove
            .forEach {
                // Check if there is actually a game bubble there
                guard let gameBubble = bubbleGridModel.getGameBubble(at: $0) else {
                    return
                }
                
                // cannot remove an indestructible bubble
                guard let powerType = (gameBubble as? PowerBubble)?.power,
                    powerType != .Indestructible else {
                        return
                }
                
                removeFromGame(gameBubble: gameBubble, at: $0)
            }
    }
    
    // Activates a bomb bubble at that index path,
    // and removes adjacent bubbles to it.
    private func activate(bombBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        
        // Add to the special datastructure to avoid repeatedly chaining each other
        bubblesActivated.insert(indexPath)
        
        // get the neighbours index path of the bomb bubble
        var neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: indexPath)
        
        // add the bomb itself for removal
        neighboursIndexPath.append(indexPath)
        
        // explode the bomb
        bubbleGameAnimator.explodeBomb(bombBubble)
        
        // attempt to chain, activating bubble is the bomb bubble
        let chainableBubbles = getSpecialBubblesIndexPath(from: neighboursIndexPath)
        chainableBubbles
            .filter {
                // Ensure that the bubble to chain to has not been activated before
                guard !bubblesActivated.contains($0) else {
                    return false
                }
                
                // check that it is actually a special bubble and is not a indestructible
                guard let powerType = (bubbleGridModel.getGameBubble(at: $0) as? PowerBubble)?.power else {
                    return false
                }
                return powerType != .Indestructible
            }
            .forEach {
                // For each successful chain, increase chain count and start the chain
                if !bubblesActivated.contains($0) {
                    currentChainCount += 1
                }
                activateSpecialBubble(at: $0, with: activatingBubble)
            }
        
        // remove the bomb affected ones
        neighboursIndexPath
            .forEach {
                // check if there is actually a game bubble there
                guard let gameBubble = bubbleGridModel.getGameBubble(at: $0) else {
                    return
                }
                
                // cannot remove an indestructible bubble
                guard let powerType = (gameBubble as? PowerBubble)?.power,
                    powerType != .Indestructible else {
                    return
                }
                
                removeFromGame(gameBubble: gameBubble, at: $0)
            }
        
    }
    
    // Activates a star bubble at that index path,
    // and removes all colored bubbles with the same color as the activating bubble.
    private func activate(starBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // Set itself as activated
        bubblesActivated.insert(indexPath)
                
        // Simply remove all same colored bubbles in the grid
        let presentBubbleIndexPaths = bubbleGridModel.getIndexPathOfBubblesInGrid()
        presentBubbleIndexPaths
            .filter { (bubbleGridModel.getGameBubble(at: $0) as? ColoredBubble)?.color == activatingBubble.color }
            .forEach {
                guard let gameBubble = bubbleGridModel.getGameBubble(at: $0) else {
                    return
                }
                
                // Display a star animation before removal
                bubbleGameAnimator.animateStarDestroyer(at: $0)

                removeFromGame(gameBubble: gameBubble, at: $0)
            }
        
        
        // Remove the star bubble itself
        removeFromGame(gameBubble: starBubble, at: indexPath)
    }
    
    private func removeFromGame(gameBubble: GameBubble, at indexPath: IndexPath) {
        // Mark as removed and remove from model
        // Deregister from game engine
        bubblesToRemove.insert(indexPath)
        bubbleGridModel.remove(at: indexPath)
        gameEngine.deregister(gameObject: gameBubble)
    }

    private func handleColoredInteractions(with snappedBubble: ColoredBubble) {
        // remove connected bubbles
        let didRemoveConnected = removeConnectedBubblesOfSameColor(as: snappedBubble)
        
        // remove floating bubbles
        removeFloatingBubbles()
        
        // Check if connected bubbles were removed
        guard didRemoveConnected else {
            return
        }
        
        // If they were removed, set snapped bubble position at a far location
        // to prevent future collision checks against this object
        snappedBubble.position = Constants.pointAtFarLocation
    }
    
    
    // ---------------------- Helper methods --------------------- //
    
    // Removes all game bubbles that are same color as the given start game bubble and
    // index path that are connected to it.
    private func removeConnectedBubblesOfSameColor(as coloredBubble: ColoredBubble) -> Bool {
        
        guard let startIndexPath = bubbleGridModel.getIndexPath(for: coloredBubble) else {
            return false
        }
        
        // Initialize breadth-first search style variables
        // A BFS queue, a visited set, and an array of bubbles to remove (connected and same color)
        var visitedIndexPaths = Set<IndexPath>()
        var bubblesToRemove = [startIndexPath]
        var queue = Queue<IndexPath>()
        
        // Visit the start index (indexPath)
        visitedIndexPaths.insert(startIndexPath)
        queue.enqueue(startIndexPath)
        
        // While we can still visit neighbours
        while !queue.isEmpty {
            
            // Get the next index path to visit
            guard let nextIndexPath = try? queue.dequeue() else {
                break
            }
            
            let neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: nextIndexPath)
            
            for neighbourIndexPath in neighboursIndexPath {
                // Process neighbour only if unvisited
                guard !visitedIndexPaths.contains(neighbourIndexPath) else {
                    continue
                }
                
                // Get the associated game bubble at the current neighbour index path
                guard let neighbourBubble = bubbleGridModel.getGameBubble(at: neighbourIndexPath) else {
                    continue
                }
                
                // The neighbour must be a ColoredBubble object
                guard let coloredNeighbour = neighbourBubble as? ColoredBubble else {
                        continue
                }
                
                // Only add to the queue (and also to be removed) if 
                // they are same color
                guard coloredBubble.color == coloredNeighbour.color else {
                    continue
                }
                
                queue.enqueue(neighbourIndexPath)
                visitedIndexPaths.insert(neighbourIndexPath)
                bubblesToRemove.append(neighbourIndexPath)
            }
        }
        
        // Only remove the bubbles if the number of connected bubbles >= minimum count
        // including the moving bubble that snapped.
        guard bubblesToRemove.count >= Constants.minimumConnectedCountToPop else {
            return false
        }
        
        popBubblesAway(at: bubblesToRemove)
        return true
    }
    
    // This function will remove all the floating bubbles that are connected to the top of the 
    // bubble grid.
    private func removeFloatingBubbles() {
        
        let floatingBubblesIndexPaths = BubbleGameUtility.getFloatingBubblesIndexPath(of: bubbleGridModel)
        dropBubbles(at: floatingBubblesIndexPaths)
    }
    
    // Pops the bubbles at the specified index paths.
    private func popBubblesAway(at indexPaths: [IndexPath]) {
        // Remove the connected bubbles from the game
        for indexPath in indexPaths {
            // Get the corresponding game bubble at the index path
            guard let gameBubble = bubbleGridModel.getGameBubble(at: indexPath) else {
                return
            }
            
            prepareToAnimate(gameBubble: gameBubble, at: indexPath)
            bubbleGameAnimator.popBubble(gameBubble)
        }
    }
    
    // Drops the bubbles in the given set of index paths.
    private func dropBubbles(at indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            
            // Get the corresponding game bubble at the index path
            guard let gameBubble = bubbleGridModel.getGameBubble(at: indexPath) else {
                return
            }
            
            prepareToAnimate(gameBubble: gameBubble, at: indexPath)
            bubbleGameAnimator.dropBubble(gameBubble)
        }
    }
    
    private func prepareToAnimate(gameBubble: GameBubble, at indexPath: IndexPath) {
        bubblesToRemove.insert(indexPath)
        bubbleGridModel.remove(at: indexPath)
        gameEngine.deregisterForAnimation(gameObject: gameBubble)
    }
}
