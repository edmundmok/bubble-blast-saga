//
//  BubbleGridModelManager.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 The `BubbleGridModelManager` manages the game's bubble grid by providing
 operations to query and manipulate the grid, as well as 
 save and load the internal bubble grid.
 */
class BubbleGridModelManager: BubbleGridModel {
    
    struct Constants {
        static let fileExtension = "bubblegrid"
        static let bubbleGridKey = "bubbleGrid"
    }
    
    private(set) var loadedFileName: String?
    private var bubbleGrid: BubbleGrid
    
    var numSections: Int {
        return bubbleGrid.numSections
    }
    
    var numRowsPerOddSection: Int {
        return bubbleGrid.numRowsPerOddSection
    }
    
    var numRowsPerEvenSection: Int {
        return bubbleGrid.numRowsPerEvenSection
    }
    
    var numOddSections: Int {
        return bubbleGrid.numOddSections
    }
    
    var numEvenSections: Int {
        return bubbleGrid.numEvenSections
    }
    
    init(numSections: Int, numRows: Int) {
        self.bubbleGrid = BubbleGrid(numSections: numSections, numRows: numRows)
    }
    
    // Returns the bubble type at the specified indexpath, if there is one.
    // Otherwise, returns nil.
    func getBubbleType(at indexPath: IndexPath) -> BubbleType {
        let index = getIndex(from: indexPath)
        let gameBubble = bubbleGrid.getBubble(at: index)
        return getBubbleTypeFor(gameBubble: gameBubble)
    }
    
    // Sets the given bubble at the specified indexpath.
    func set(bubbleType: BubbleType, at indexPath: IndexPath) {
        let index = getIndex(from: indexPath)
        let gameBubble = getGameBubbleFor(bubbleType: bubbleType)
        bubbleGrid.set(bubble: gameBubble, at: index)
    }
    
    // Returns a GameBubble that corresponds to the given BubbleType.
    private func getGameBubbleFor(bubbleType: BubbleType) -> GameBubble? {
        switch bubbleType {
        case .Empty: return nil
        case .BlueBubble: return ColoredBubble(.Blue)
        case .RedBubble: return ColoredBubble(.Red)
        case .OrangeBubble: return ColoredBubble(.Orange)
        case .GreenBubble: return ColoredBubble(.Green)
        }
    }
    
    // Returns a BubbleType that corresponds to the given GameBubble.
    private func getBubbleTypeFor(gameBubble: GameBubble?) -> BubbleType {
        switch gameBubble {
        case let coloredBubble as ColoredBubble:
            return getBubbleTypeFor(coloredBubble: coloredBubble)
        default:
            return .Empty
        }
    }
    
    // Returns a BubbleType that corresponds to the given ColoredBubble.
    private func getBubbleTypeFor(coloredBubble: ColoredBubble) -> BubbleType {
        switch coloredBubble.color {
        case .Blue: return .BlueBubble
        case .Red: return .RedBubble
        case .Orange: return .OrangeBubble
        case .Green: return .GreenBubble
        }
    }
    
    // Resets the entire bubble grid, removing all existing bubbles.
    // The grid size remains the same but becomes empty.
    func reset() {
        bubbleGrid.reset()
    }
    
    // Get the index of the bubble in the bubble grid given the specified indexPath.
    private func getIndex(from indexPath: IndexPath) -> Int {
        // case 1: section 0
        guard indexPath.section > 0 else {
            // simply return the position in the section
            return indexPath.row
        }
        
        // case 2: section 1
        guard indexPath.section > 1 else {
            // add number of items in first section (section 0, which is even) and
            // the current position in the second section (section 1)
            return numRowsPerEvenSection + indexPath.row
        }
        
        // case 3: section 2 onwards
        let bubblesPerPairOfOddAndEvenRow = numRowsPerEvenSection + numRowsPerOddSection
        
        // We need to compute number of bubbles for the current bubble index's section:
        // Compute number of bubbles in each paired sections (odd and even section pairing, e.g. section 0 and 1 paired)
        // Compute for all paired sections before current section to find total number from these paired sections
        let numBubblesFromPairedSectionsBeforeCurrent = (indexPath.section / 2) * (bubblesPerPairOfOddAndEvenRow)
        
        // There may be an unpaired section left before the current section
        // Compute the number of bubbles in that unpaired section (may be an odd or even section)
        let numBubblesFromUnpairedSectionsBeforeCurrent = (indexPath.section % 2) * getNumRowsFor(section: indexPath.section % 2)
        
        // Total number of bubbles before current section is just the sum of the previous two results
        let numBubblesBeforeCurrentSection = numBubblesFromPairedSectionsBeforeCurrent + numBubblesFromUnpairedSectionsBeforeCurrent
        
        // Current index is number bubbles before current section + current index row
        return numBubblesBeforeCurrentSection + indexPath.row
    }
    
    // Returns the number of rows for the given section number.
    private func getNumRowsFor(section: Int) -> Int {
        return section % 2 == 0 ? numRowsPerEvenSection: numRowsPerEvenSection
    }
    
    // Helper function to get the URL for the specified bubble grid filename.
    private func getURLForBubbleGridFile(named filename: String) -> URL {
        // Get the URL of the Documents Directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Get the URL for a file in the Documents Directory
        let fileURL = documentDirectory.appendingPathComponent(filename).appendingPathExtension(Constants.fileExtension)
        return fileURL
    }
    
    // Saves the current bubblegrid as a file with the given filename as the name
    // of the saved file.
    // Returns a boolean whether the file is saved successfully.
    func save(as filename: String) -> Bool {
        let fileURL = getURLForBubbleGridFile(named: filename)
        
        // execute save
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        // encode the bubblegrid with its key
        archiver.encode(self.bubbleGrid, forKey: Constants.bubbleGridKey)
        archiver.finishEncoding()
        
        // write to the file
        let success = data.write(to: fileURL, atomically: true)
        
        if success {
            // set the loaded file name of the current grid as
            // the one it was saved as
            loadedFileName = filename
        }
        
        return success
    }
    
    // Loads a bubblegrid from a file with the given filename.
    func load(from filename: String) {
        let fileURL = getURLForBubbleGridFile(named: filename)
        
        // ensure that file to load from exists
        guard FileManager.default.fileExists(atPath: fileURL.relativePath) else {
            return
        }

        // ensure file content can be read as Data
        guard let data = try? Data(contentsOf: fileURL) else {
            return
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        defer {
            unarchiver.finishDecoding()
        }
        
        // ensure that the data can be decoded as an array of gamebubbles (the bubblegrid)
        guard let bubbleGrid = unarchiver.decodeObject(forKey: Constants.bubbleGridKey) as? BubbleGrid else {
            return
        }
        
        // set the bubblegrid to the loaded bubblegrid
        self.bubbleGrid = bubbleGrid
        
        // set the loaded file name
        self.loadedFileName = filename
    }
}
