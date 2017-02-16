//
//  SavedLevelsModel.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 5/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 SavedLevelsModel manages the model for the saved bubblegrid levels.
 */
protocol SavedLevelsModel {
    
    var savedLevels: [String] { get }
    
    // Deletes the level at the given index from the model
    // and the directory.
    func deleteLevelAt(index: Int)
}
