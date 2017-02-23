//
//  BubbleGameLogicSimulator.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameLogicSimulator {
    
    fileprivate let bubbleGrid: UICollectionView
    fileprivate let bubbleGridModel: BubbleGridModel
    
    // special data structure for chaining to avoid checking special bubble activation repeatedly
    fileprivate var bubblesActivated = Set<IndexPath>()
    fileprivate var bubblesToRemove = Set<IndexPath>()
    private var currentChainCount = 0
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
    }
    
    
    // Handle the resulting interactions of the snapped bubble, such as removing connected
    // bubbles and also removing floating bubbles after.
    func handleInteractions(with snappedBubble: GameBubble) -> Int {
        
        // The game only shoots colored bubbles
        guard let coloredBubble = snappedBubble as? ColoredBubble else {
            return 0
        }
        
        // Reset the special data structure at the start of each interaction handling
        bubblesActivated = Set<IndexPath>()
        bubblesToRemove = Set<IndexPath>()
        
        // reset the current chain count for each interaction handling
        currentChainCount = 0
        
        // activate special bubbles if present
        activateSpecialBubbles(near: coloredBubble)
        
        // check if the snapped bubble was removed as a result of special bubble effects
        // if yes, nothing else to continue with
        guard let indexPath = bubbleGridModel.getIndexPath(for: snappedBubble) else {
            return bubblesToRemove.count
        }
        
        guard !bubblesToRemove.contains(indexPath) else {
            return bubblesToRemove.count
        }
        
        let countForBubblesRemovedBySpecialInteractions = bubblesToRemove.count
        
        print(bubblesToRemove)
        
        // reset bubblesToRemove
        bubblesToRemove = Set<IndexPath>()
        
        // check if the snapped bubble was removed as a result of special bubble effects
        // if yes, nothing else to continue with
        
        // otherwise, attempt to carry out normal bubble removals
        handleColoredInteractions(with: coloredBubble)
        
        let totalBubblesRemoved = countForBubblesRemovedBySpecialInteractions + bubblesToRemove.count
        
        print("chain count: ", currentChainCount)
        print("total bubbles removed: ", totalBubblesRemoved)
        return totalBubblesRemoved
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
    
    private func activateSpecialBubble(at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // index path given should be a power bubble
        guard let powerBubble = bubbleGridModel.getGameBubble(at: indexPath) as? PowerBubble else {
            return
        }
        
        // check type of power and activate accordingly
        switch powerBubble.power {
        case .Lightning: activate(lightningBubble: powerBubble, at: indexPath, with: activatingBubble)
        case .Bomb: activate(bombBubble: powerBubble, at: indexPath, with: activatingBubble)
        case .Star: activate(starBubble: powerBubble, at: indexPath, with: activatingBubble)
        default: return
        }
    }
    
    private func activate(lightningBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // Removes all bubbles in the same row as it
        
        // add to the special datastructure to avoid repeatedly chaining each other
        bubblesActivated.insert(indexPath)
        
        // index path to remove is all on the same section
        let indexPathsToRemove = bubbleGridModel.getIndexPathsForSectionContaining(indexPath: indexPath)
        
        // attempt to chain, activating bubble is the lightning bubble
        indexPathsToRemove
            .filter { !bubblesActivated.contains($0) }
            .filter {
                // check that it is actually a special bubble and is not a indestructible
                guard let powerType = (bubbleGridModel.getGameBubble(at: $0) as? PowerBubble)?.power else {
                    return false
                }
                return powerType != .Indestructible
            }
            .forEach {
                currentChainCount += 1
                activateSpecialBubble(at: $0, with: activatingBubble)
        }
        
        // remove the lightning affected ones
        indexPathsToRemove.forEach {
            // check if there is actually a game bubble there
            guard bubbleGridModel.getGameBubble(at: $0) != nil else {
                return
            }
            
            bubblesToRemove.insert($0)
            // remove it from the grid and the game engine
            bubbleGridModel.remove(at: $0)
        }
    }
    
    private func activate(bombBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // Removes all bubbles adjacent to it
        
        // add to the special datastructure to avoid repeatedly chaining each other
        bubblesActivated.insert(indexPath)
        
        // get the neighbours index path of the bomb bubble
        var neighboursIndexPath = bubbleGridModel.getNeighboursIndexPath(of: indexPath)
        
        // add the bomb itself for removal
        neighboursIndexPath.append(indexPath)
        
        // attempt to chain, activating bubble is the bomb bubble
        let chainableBubbles = getSpecialBubblesIndexPath(from: neighboursIndexPath)
        chainableBubbles
            .filter { !bubblesActivated.contains($0) }
            .filter {
                // check that it is actually a special bubble and is not a indestructible
                guard let powerType = (bubbleGridModel.getGameBubble(at: $0) as? PowerBubble)?.power else {
                    return false
                }
                return powerType != .Indestructible
            }
            .forEach {
                currentChainCount += 1
                activateSpecialBubble(at: $0, with: activatingBubble)
        }
        
        // remove the bomb affected ones
        neighboursIndexPath.forEach {
            // check if there is actually a game bubble there
            guard bubbleGridModel.getGameBubble(at: $0) != nil else {
                return
            }
            // remove it from the grid and the game engine
            bubblesToRemove.insert($0)
            bubbleGridModel.remove(at: $0)
        }
        
    }
    
    private func activate(starBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: ColoredBubble) {
        // set itself as activated
        bubblesActivated.insert(indexPath)
        
        // simply remove all same colored bubbles in the grid
        let presentBubbleIndexPaths = bubbleGridModel.getIndexPathOfBubblesInGrid()
        presentBubbleIndexPaths
            .filter { (bubbleGridModel.getGameBubble(at: $0) as? ColoredBubble)?.color == activatingBubble.color }
            .forEach {
                guard bubbleGridModel.getGameBubble(at: $0) != nil else {
                    return
                }
                
                bubblesToRemove.insert($0)
                bubbleGridModel.remove(at: $0)
        }
        
        
        // remove the star itself
        bubbleGridModel.remove(at: indexPath)
        bubblesToRemove.insert(indexPath)
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
            guard bubbleGridModel.getGameBubble(at: $0) != nil else {
                return
            }
            
            bubblesToRemove.insert($0)
            
            // Remove from the backing bubble grid model
            bubbleGridModel.remove(at: $0)
        
        }
    }
    
    // Drops the bubbles in the given set of index paths.
    private func dropBubbles(at indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            
            // Get the corresponding game bubble at the index path
            guard bubbleGridModel.getGameBubble(at: indexPath) != nil else {
                return
            }
            
            bubblesToRemove.insert(indexPath)
            
            bubbleGridModel.remove(at: indexPath)
            
        }
    }
}
