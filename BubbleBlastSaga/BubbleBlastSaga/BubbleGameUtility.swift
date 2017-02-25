//
//  BubbleGameUtility.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameUtility {
    
    // Returns an array of the index paths for the topmost (first) section of the bubble grid.
    static func getIndexPathsForTopSection(of bubbleGridModel: BubbleGridModel) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        // Add from index 0 to the last index in the first section of the grid (section 0 is even)
        for index in 0..<bubbleGridModel.numRowsPerEvenSection {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        
        return indexPaths
    }
    
    static func getIndexPathsForBottomSection(of bubbleGridModel: BubbleGridModel) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        let bottomSectionNum = bubbleGridModel.numSections - 1
        let numRowsInBottomSection = bottomSectionNum % 2 == 0 ? bubbleGridModel.numRowsPerEvenSection : bubbleGridModel.numRowsPerOddSection
        
        // Add from index 0 to the last index in the first section of the grid (section 0 is even)
        for index in 0..<numRowsInBottomSection {
            indexPaths.append(IndexPath(row: index, section: bottomSectionNum))
        }
        
        return indexPaths
    }
    
    // Returns the nearest empty index path to the given game bubble, among the given indexPaths.
    static func getNearestEmptyIndexPath(from gameBubble: GameBubble, to indexPaths: [IndexPath],
        bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) -> IndexPath? {
        
        // Initialize variables to store the nearest empty
        // index path and distance to that index path
        var nearestEmptyIndexPath: IndexPath? = nil
        
        // Initialize shortest distance as -1
        // Any distance found will be considered shorter than this
        var shortestDistance = Constants.infiniteDistance
        
        // Go through all the indexPaths to find the nearest one
        for indexPath in indexPaths {
            
            // If the indexPath of the bubble grid is not empty, just continue.
            // We are looking for empty ones.
            guard bubbleGridModel.getGameBubble(at: indexPath) == nil else {
                continue
            }
            
            // Get the center point of the empty cell at the current index path
            guard let emptyCellCenter = bubbleGrid.cellForItem(at: indexPath)?.center else {
                continue
            }
            
            // Get the distance of the game bubble center to the empty cell center
            let distToEmptyCell = gameBubble.center.distance(to: emptyCellCenter)
            
            // Check if it is the shortest distance we have found so far
            guard (shortestDistance == Constants.infiniteDistance
                || distToEmptyCell < shortestDistance) else {
                    continue
            }
            
            // Update our shortest distance and nearest index path found so far
            shortestDistance = distToEmptyCell
            nearestEmptyIndexPath = indexPath
        }
        
        // Return the nearest indexPath
        return nearestEmptyIndexPath
    }
    
    static func getFloatingBubblesIndexPath(of bubbleGridModel: BubbleGridModel) -> Set<IndexPath> {
        
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
        
        return floatingBubblesIndexPaths
    }
    
    // Returns the bubble image associated with the given game bubble.
    static func getBubbleImage(for gameBubble: GameBubble) -> UIImageView {
        switch gameBubble {
        case let coloredBubble as ColoredBubble: return getBubbleImage(for: coloredBubble)
        case let powerBubble as PowerBubble: return getBubbleImage(for: powerBubble)
        default: return UIImageView()
        }
    }
    
    private static func getBubbleImage(for coloredBubble: ColoredBubble) -> UIImageView {
        switch coloredBubble.color {
        case .Red: return UIImageView(image: UIImage(named: Constants.redBubbleImage))
        case .Blue: return UIImageView(image: UIImage(named: Constants.blueBubbleImage))
        case .Orange: return UIImageView(image: UIImage(named: Constants.orangeBubbleImage))
        case .Green: return UIImageView(image: UIImage(named: Constants.greenBubbleImage))
        }
    }
    
    private static func getBubbleImage(for powerBubble: PowerBubble) -> UIImageView {
        switch powerBubble.power {
        case .Indestructible: return UIImageView(image: UIImage(named: Constants.indestructibleBubbleImage))
        case .Lightning: return UIImageView(image: UIImage(named: Constants.lightningBubbleImage))
        case .Bomb: return UIImageView(image: UIImage(named: Constants.bombBubbleImage))
        case .Star: return UIImageView(image: UIImage(named: Constants.starBubbleImage))
        }
    }
    
}
