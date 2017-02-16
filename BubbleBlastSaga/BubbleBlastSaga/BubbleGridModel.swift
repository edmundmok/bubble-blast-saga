//
//  BubbleGridModel.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 5/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
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
    
    // Returns the bubble type at the specified indexpath, if there is one.
    // Otherwise, returns nil.
    func getBubbleType(at indexPath: IndexPath) -> BubbleType
    
    // Sets the given bubble at the specified index.
    func set(bubbleType: BubbleType, at indexPath: IndexPath)
    
    // Resets the entire bubble grid, removing all existing bubbles.
    // The grid size remains the same but becomes empty.
    func reset()
    
    
    // Saves the current bubblegrid as a file with the given filename as the name
    // of the saved file.
    // Returns a boolean whether the file is saved successfully.
    func save(as filename: String) -> Bool
    
    // Loads a bubblegrid from a file with the given filename.
    func load(from filename: String)
    
}
