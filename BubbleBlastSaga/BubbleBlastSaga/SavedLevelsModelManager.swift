//
//  SavedLevelsModelManager.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 SavedLevelsModelManager manages the model for the
 saved bubblegrid levels.
 */
class SavedLevelsModelManager: SavedLevelsModel {
    
    private(set) var savedLevels: [String]
    
    init() {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = (try? FileManager.default.contentsOfDirectory(at: documentsUrl,
            includingPropertiesForKeys: nil, options: [])) ?? []
        
        // get a sorted array of bubblegrid file names
        let bubblegridFiles = directoryContents
            .filter { $0.pathExtension == Constants.fileExtension }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted { (first, second) in first.caseInsensitiveCompare(second) == .orderedAscending }
        
        // initialize the savedLevels as the bubblegrid file names discovered
        self.savedLevels = bubblegridFiles
    }
    
    // Deletes the level at the given index from the model
    // and the directory.
    func deleteLevelAt(index: Int) {
        // ensure that the index accessed is valid
        guard isValidIndex(index) else {
            return
        }
        
        // get the file url
        let fileName = savedLevels[index]
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentsUrl.appendingPathComponent(fileName).appendingPathExtension(Constants.fileExtension)
        
        // remove from directory and the model
        try? FileManager.default.removeItem(at:fileUrl)
        savedLevels.remove(at: index)
        
        // also remove the png image associated
        let imageUrl = documentsUrl.appendingPathComponent(fileName).appendingPathExtension(Constants.pngExtension)
        try? FileManager.default.removeItem(at: imageUrl)
    }
    
    // Checks if the given index is valid.
    private func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < savedLevels.count
    }
}
