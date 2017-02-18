//
//  BubbleGridModel.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 The `BubbleGridModel` manages the game's bubble grid by providing
 operations to query and manipulate the grid, as well as
 save and load the internal bubble grid.
 */
protocol BubbleGridModel {
    
    var loadedFileName: String? { get }
    var numSections: Int { get }
    var numRowsPerOddSection: Int { get }
    var numRowsPerEvenSection: Int { get }
    var numOddSections: Int { get }
    var numEvenSections: Int { get }
    
    // Returns the bubble type at the specified indexpath.
    func getBubbleType(at indexPath: IndexPath) -> BubbleType
    
    // Returns the game bubble at the specified indexPath, if it is a valid
    // index path for the bubble grid.
    // Otherwise, returns nil
    func getGameBubble(at indexPath: IndexPath) -> GameBubble?
    
    // Returns the index path for the given GameBubble object if the
    // object exists in the Bubble Grid, otherwise returns nil.
    func getIndexPath(for gameBubble: GameBubble) -> IndexPath?
    
    // Returns the index path of the neighbours of the GameBubble at the
    // given index path, otherwise returns an empty array.
    // If the index path is invalid, also returns an empty array.
    func getNeighboursIndexPath(of indexPath: IndexPath) -> [IndexPath]
    
    // Sets the given bubble at the specified indexpath.
    func set(bubbleType: BubbleType, at indexPath: IndexPath)
    
    // Sets the given game bubble at the specified index path.
    func set(gameBubble: GameBubble, at indexPath: IndexPath)
    
    // Removes the game bubble at the specified index path.
    func remove(at indexPath: IndexPath)
    
    // Resets the entire bubble grid, removing all existing bubbles.
    // The grid size remains the same but becomes empty.
    func reset()
    
    // Saves the current bubblegrid as a file with the given filename as the name
    // of the saved file.
    // Returns a boolean whether the file is saved successfully.
    func save(as filename: String) -> Bool
    
    // Loads a bubblegrid from a file with the given filename.
    func load(from filename: String)
    
    // Returns a set containing the index path of all present bubbles in the 
    // bubble grid.
    func getIndexPathOfBubblesInGrid() -> Set<IndexPath>
    
    func getIndexPathsForSectionContaining(indexPath: IndexPath) -> [IndexPath]
    
}
