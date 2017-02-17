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
    
    // Returns the bubble image associated with the given game bubble.
    static func getBubbleImage(for gameBubble: GameBubble) -> UIImageView {
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
