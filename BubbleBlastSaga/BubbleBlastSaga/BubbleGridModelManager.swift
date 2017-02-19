//
//  BubbleGridModelManager.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 The `BubbleGridModelManager` manages the game's bubble grid by providing
 operations to query and manipulate the grid, as well as
 save and load the internal bubble grid.
 */
class BubbleGridModelManager: BubbleGridModel {
    
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
    func getBubbleType(at indexPath: IndexPath) -> BubbleType {
        let index = getIndex(from: indexPath)
        let gameBubble = bubbleGrid.getBubble(at: index)
        return getBubbleTypeFor(gameBubble: gameBubble)
    }
    
    // Returns the game bubble at the specified indexPath, if it is a valid
    // index path for the bubble grid.
    // Otherwise, returns nil
    func getGameBubble(at indexPath: IndexPath) -> GameBubble? {
        // Return nil if invalid index path
        guard isValidIndexPath(indexPath: indexPath) else {
            return nil
        }
        let index = getIndex(from: indexPath)
        return bubbleGrid.getBubble(at: index)
    }
    
    // Returns the index path for the given GameBubble object if the
    // object exists in the Bubble Grid, otherwise returns nil.
    func getIndexPath(for gameBubble: GameBubble) -> IndexPath? {
        // Return nil if does not exist
        guard let index = bubbleGrid.getIndex(for: gameBubble) else {
            return nil
        }
        // Return the index path
        return getIndexPath(from: index)
    }
    
    // Returns the index path of the neighbours of the GameBubble at the
    // given index path, otherwise returns an empty array.
    // If the index path is invalid, also returns an empty array.
    func getNeighboursIndexPath(of indexPath: IndexPath) -> [IndexPath] {
        // Invalid index path, return empty array
        guard isValidIndexPath(indexPath: indexPath) else {
            return []
        }
        
        // Check if it is an odd or even section
        guard indexPath.section % 2 == 0 else {
            // It is an odd section
            return getOddSectionNeighboursIndexPath(of: indexPath)
        }
        
        // It is an even section
        return getEvenSectionNeighboursIndexPath(of: indexPath)
    }
    
    // Get the neighbours of the given index path, assuming that the given index path
    // is in an even section.
    private func getEvenSectionNeighboursIndexPath(of indexPath: IndexPath) -> [IndexPath] {
        var neighboursIndexPath = [IndexPath]()
        
        // Calculate the index path of its neighbours
        let topLeft = IndexPath(row: indexPath.row-1, section: indexPath.section-1)
        let topRight = IndexPath(row: indexPath.row, section: indexPath.section-1)
        let left = IndexPath(row: indexPath.row-1, section: indexPath.section)
        let right = IndexPath(row: indexPath.row+1, section: indexPath.section)
        let bottomLeft = IndexPath(row: indexPath.row-1, section: indexPath.section+1)
        let bottomRight = IndexPath(row: indexPath.row, section: indexPath.section+1)
        
        // For each calculated neighbour, they may not exist.
        // We need to check if they are actually valid before adding into the array.
        // top left
        if isValidIndexPath(indexPath: topLeft) {
            neighboursIndexPath.append(topLeft)
        }
        
        // top right
        if isValidIndexPath(indexPath: topRight) {
            neighboursIndexPath.append(topRight)
        }
        
        // left
        if isValidIndexPath(indexPath: left) {
            neighboursIndexPath.append(left)
        }
        
        // right
        if isValidIndexPath(indexPath: right) {
            neighboursIndexPath.append(right)
            
        }
        
        // bottom left
        if isValidIndexPath(indexPath: bottomLeft) {
            neighboursIndexPath.append(bottomLeft)
            
        }
        
        // bottom right
        if isValidIndexPath(indexPath: bottomRight) {
            neighboursIndexPath.append(bottomRight)
            
        }
        
        return neighboursIndexPath
    }
    
    // Get the neighbours of the given index path, assumiming that the given index path
    // is in an odd section.
    private func getOddSectionNeighboursIndexPath(of indexPath: IndexPath) -> [IndexPath] {
        var neighboursIndexPath = [IndexPath]()
        
        // Calculate the index path of its neighbours
        let topLeft = IndexPath(row: indexPath.row, section: indexPath.section-1)
        let topRight = IndexPath(row: indexPath.row+1, section: indexPath.section-1)
        let left = IndexPath(row: indexPath.row-1, section: indexPath.section)
        let right = IndexPath(row: indexPath.row+1, section: indexPath.section)
        let bottomLeft = IndexPath(row: indexPath.row, section: indexPath.section+1)
        let bottomRight = IndexPath(row: indexPath.row+1, section: indexPath.section+1)
        
        // For each calculated neighbour, they may not exist.
        // We need to check if they are actually valid before adding into the array.
        // top left
        if isValidIndexPath(indexPath: topLeft) {
            neighboursIndexPath.append(topLeft)
        }
        
        // top right
        if isValidIndexPath(indexPath: topRight) {
            neighboursIndexPath.append(topRight)
        }
        
        // left
        if isValidIndexPath(indexPath: left) {
            neighboursIndexPath.append(left)
        }
        
        // right
        if isValidIndexPath(indexPath: right) {
            neighboursIndexPath.append(right)
        }
        
        // bottom left
        if isValidIndexPath(indexPath: bottomLeft) {
            neighboursIndexPath.append(bottomLeft)
        }
        
        // bottom right
        if isValidIndexPath(indexPath: bottomRight) {
            neighboursIndexPath.append(bottomRight)
        }
        
        return neighboursIndexPath
    }
    
    // Sets the given bubble at the specified indexpath.
    func set(bubbleType: BubbleType, at indexPath: IndexPath) {
        guard isValidIndexPath(indexPath: indexPath) else {
            return
        }
        
        let index = getIndex(from: indexPath)
        let gameBubble = getGameBubbleFor(bubbleType: bubbleType)
        bubbleGrid.set(bubble: gameBubble, at: index)
    }
    
    // Sets the given game bubble at the specified index path.
    func set(gameBubble: GameBubble, at indexPath: IndexPath) {
        guard isValidIndexPath(indexPath: indexPath) else {
            return
        }
        
        let index = getIndex(from: indexPath)
        bubbleGrid.set(bubble: gameBubble, at: index)
    }
    
    // Returns a GameBubble that corresponds to the given BubbleType.
    private func getGameBubbleFor(bubbleType: BubbleType) -> GameBubble? {
        switch bubbleType {
        case .Empty: return nil
        case .BlueBubble: return ColoredBubble(color: .Blue)
        case .RedBubble: return ColoredBubble(color: .Red)
        case .OrangeBubble: return ColoredBubble(color: .Orange)
        case .GreenBubble: return ColoredBubble(color: .Green)
        case .IndestructibleBubble: return PowerBubble(power: .Indestructible)
        case .LightningBubble: return PowerBubble(power: .Lightning)
        case .BombBubble: return PowerBubble(power: .Bomb)
        case .StarBubble: return PowerBubble(power: .Star)
        }
    }
    
    // Returns a BubbleType that corresponds to the given GameBubble.
    private func getBubbleTypeFor(gameBubble: GameBubble?) -> BubbleType {
        switch gameBubble {
        case let coloredBubble as ColoredBubble:
            return getBubbleType(for: coloredBubble)
        case let powerBubble as PowerBubble:
            return getBubbleType(for: powerBubble)
        default:
            return .Empty
        }
    }
    
    // Returns a BubbleType that corresponds to the given ColoredBubble.
    private func getBubbleType(for coloredBubble: ColoredBubble) -> BubbleType {
        switch coloredBubble.color {
        case .Blue: return .BlueBubble
        case .Red: return .RedBubble
        case .Orange: return .OrangeBubble
        case .Green: return .GreenBubble
        }
    }
    
    // Returns a BubbleType that corresponds to the given PowerBubble.
    private func getBubbleType(for powerBubble: PowerBubble) -> BubbleType {
        switch powerBubble.power {
        case .Indestructible: return .IndestructibleBubble
        case .Lightning: return .LightningBubble
        case .Bomb: return .BombBubble
        case .Star: return .StarBubble
        }
    }
    
    // Removes the game bubble at the specified index path.
    func remove(at indexPath: IndexPath) {
        guard isValidIndexPath(indexPath: indexPath) else {
            return
        }
        
        let index = getIndex(from: indexPath)
        bubbleGrid.set(bubble: nil, at: index)
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        let loadedFileNameCopy = loadedFileName?.copy()
        let bubbleGridCopy = bubbleGrid.copy()
        
        let copy = BubbleGridModelManager(numSections: numSections, numRows: numRowsPerEvenSection)
        
        guard let loadedFileName = loadedFileNameCopy as? String?,
            let bubbleGrid = bubbleGridCopy as? BubbleGrid else {
                return copy
        }
        
        copy.loadedFileName = loadedFileName
        copy.bubbleGrid = bubbleGrid
        return copy
    }
    
    // Returns the indexpath that corresponds to the given index
    // in the bubblegrid.
    private func getIndexPath(from index: Int) -> IndexPath {
        // First section is even
        var index = index
        var numRowsInSection = numRowsPerEvenSection
        var currentSection = 0
        
        // While we have not found the correct section
        while index >= numRowsInSection {
            // Check if it is an even or odd section
            if currentSection % 2 == 0 {
                // Advance index by number of rows in the current even section
                // Next section is an odd section
                index -= numRowsPerEvenSection
                numRowsInSection = numRowsPerOddSection
            } else {
                // Advance index by number of rows in the current odd section
                // Next section is an even section
                index -= numRowsPerOddSection
                numRowsInSection = numRowsPerEvenSection
            }
            // Add to section count
            currentSection += 1
        }
        
        return IndexPath(row: index, section: currentSection)
    }
    
    // Returns if the given index path is a valid index path for the current bubble grid.
    private func isValidIndexPath(indexPath: IndexPath) -> Bool {
        // If section number is wrong, it is invalid
        guard indexPath.section >= 0 && indexPath.section < numSections else {
            return false
        }
        
        // check if even section
        guard indexPath.section % 2 == 0 else {
            // Is odd section
            // If row number is wrong for odd section, it is invalid
            guard indexPath.row >= 0 && indexPath.row < numRowsPerOddSection else {
                return false
            }
            return true
        }
        
        // Is even section
        // If row number is wrong for even section,it is invalid
        guard indexPath.row >= 0 && indexPath.row < numRowsPerEvenSection else {
            return false
        }
        
        return true
    }
    
    // Returns the index path of all the bubbles that are present in the grid.
    func getIndexPathOfBubblesInGrid() -> Set<IndexPath> {
        var indexPaths = Set<IndexPath>()
        
        for section in 0..<numSections {
            
            // Check if is even or odd section
            let currentSectionRowSize = (section % 2 == 0)
                ? numRowsPerEvenSection
                : numRowsPerOddSection
            
            for row in 0..<currentSectionRowSize {
                let currentIndexPath = IndexPath(row: row, section: section)
                
                // Check if there is a bubble present in this index path
                guard let _ = getGameBubble(at: currentIndexPath) else {
                    continue
                }
                
                // Add the index path if there is a bubble present there
                indexPaths.insert(currentIndexPath)
            }
        }
        return indexPaths
    }
    
    func getIndexPathsForSectionContaining(indexPath: IndexPath) -> [IndexPath] {
        var indexPaths = [IndexPath]()

        for row in 0..<getNumRowsFor(section: indexPath.section) {
            indexPaths.append(IndexPath(row: row, section: indexPath.section))
        }
        
        return indexPaths
    }
}
