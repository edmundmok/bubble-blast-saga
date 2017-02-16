//
//  BubbleGameLogic.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameLogic {
    
    fileprivate let bubbleGrid: UICollectionView
    fileprivate let bubbleGridModel: BubbleGridModel
    fileprivate let gameEngine: GameEngine
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel, gameEngine: GameEngine) {
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        self.gameEngine = gameEngine
    }
    
    // Handle the resulting interactions of the snapped bubble, such as removing connected 
    // bubbles and also removing floating bubbles after.
    func handleInteractions(with snappedBubble: GameBubble) {
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
    private func removeConnectedBubblesOfSameColor(as gameBubble: GameBubble) -> Bool {
        // The given bubble must be a ColoredBubble object
        guard let coloredBubble = gameBubble as? ColoredBubble else {
            return false
        }
        
        guard let startIndexPath = bubbleGridModel.getIndexPath(for: gameBubble) else {
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
        
        // Initialize BFS queue and a set of bubble grid indexpaths to remove
        var queue = Queue<IndexPath>()
        // Initially we assume we all index paths are floating bubbles
        // Then as we do BFS we remove from this set
        // This set is also a way to track "visited"
        var floatingBubblesIndexPaths = bubbleGridModel.getIndexPathOfBubblesInGrid()
        
        // We will carry out BFS with the top section already "visited"
        BubbleGameUtility.getIndexPathsForTopSection(of: bubbleGridModel).forEach {
            // Check if there is indeed a game bubble at the current index path
            guard let _ = bubbleGridModel.getGameBubble(at: $0) else {
                return
            }
            
            // If there is, eliminate them from being floating bubble candidates
            // And enqueue into our queue for BFS
            floatingBubblesIndexPaths.remove($0)
            queue.enqueue($0)
        }

        // Run BFS
        while !queue.isEmpty {
            // Dequeue the next index path
            guard let nextIndexPath = try? queue.dequeue() else {
                break
            }
            
            // For each neighbour of the current index path
            let neighbours = bubbleGridModel.getNeighboursIndexPath(of: nextIndexPath)
            neighbours.forEach {
                // Check if floating bubbles still contains the neighbour
                // If does not contain already means it was already visited!
                guard floatingBubblesIndexPaths.contains($0) else {
                    return
                }
                
                // Enqueue for further BFS and remove as a candidate of floating bubble
                // since it was able to be visited from the top bubbles
                queue.enqueue($0)
                floatingBubblesIndexPaths.remove($0)
            }
        }
        
        // whats left at the end are the floating bubbles
        // remove them!
        dropBubbles(at: floatingBubblesIndexPaths)
    }
    
    // Pops the bubbles at the specified index paths.
    private func popBubblesAway(at indexPaths: [IndexPath]) {
        // Remove the connected bubbles from the game
        indexPaths.forEach {
            
            // Get the corresponding game bubble at the index path
            guard let gameBubble = bubbleGridModel.getGameBubble(at: $0) else {
                return
            }
            
            // Remove from the backing bubble grid model
            bubbleGridModel.remove(at: $0)
            
            // Deregister from the game engine
            gameEngine.deregisterForAnimation(gameObject: gameBubble)
            
            // Run animation using renderer, remove on complete
            gameEngine.renderer.animate(gameBubble, with: .BubblePop,
                for: Constants.popDuration, removeOnComplete: true)
        }
    }
    
    // Drops the bubbles in the given set of index paths.
    private func dropBubbles(at indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            
            // Get the corresponding game bubble at the index path
            guard let gameBubble = bubbleGridModel.getGameBubble(at: indexPath) else {
                return
            }
            bubbleGridModel.remove(at: indexPath)
            
            // Deregister from the game engine
            gameEngine.deregisterForAnimation(gameObject: gameBubble)
            
            // Compute drop duration
            let distanceToBottom = gameEngine.renderer.canvas.frame.maxY - gameBubble.center.y
            let dropDuration = Double(distanceToBottom) * Constants.dropDurationMultiplier
            
            // Run animation using renderer, remove on complete
            gameEngine.renderer.animate(gameBubble, with: .BubbleDrop,
                for: dropDuration, removeOnComplete: true)
            
        }
    }
}
