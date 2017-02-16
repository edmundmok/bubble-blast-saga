//
//  BubbleGrid.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 The BubbleGrid class represents a bubble grid, which is a
 grid collection of GameBubble objects.
 */
class BubbleGrid: NSObject, NSCoding {
    
    private(set) var numSections: Int
    private(set) var numRowsPerEvenSection: Int
    private(set) var numRowsPerOddSection: Int
    
    var numOddSections: Int {
        return numSections / 2
    }
    
    var numEvenSections: Int {
        return numSections - numOddSections
    }
    
    private var bubbles: [GameBubble?]
    
    init(numSections: Int, numRows: Int) {
        self.numSections = numSections
        self.numRowsPerEvenSection = numRows
        self.numRowsPerOddSection = numRows - 1
        
        let numOddSections = numSections / 2
        let numEvenSections = numSections - numOddSections
        let totalBubbles = (numRowsPerEvenSection * numEvenSections)
            + (numRowsPerOddSection * numOddSections)
        
        self.bubbles = [GameBubble?](repeating: nil, count: totalBubbles)
    }
    
    // Returns the game bubble at the specified index, if there is one.
    // Otherwise, returns nil.
    func getBubble(at index: Int) -> GameBubble? {
        guard isValidIndex(index) else {
            return nil
        }
        return bubbles[index]
    }
    
    // Returns the index of the given GameBubble in the bubble grid,
    // otherwise returns nil if the GameBubble does not exist in the grid.
    func getIndex(for gameBubble: GameBubble) -> Int? {
        
        return bubbles
            .enumerated()
            .filter { $0.element === gameBubble }
            .first?
            .offset
    }
    
    // Sets the given bubble at the specified index.
    func set(bubble: GameBubble?, at index: Int) {
        guard isValidIndex(index) else {
            return
        }
        bubbles[index] = bubble
    }
    
    // Resets the entire bubble grid, removing all existing bubbles.
    // The grid size remains the same but becomes empty.
    func reset() {
        bubbles = bubbles.map { _ in nil }
    }
    
    // Checks if the given index is a valid index for
    // the bubble grid.
    private func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < bubbles.count
    }
    
    // MARK: NSCoding
    // Decode from an encoded ColoredBubble
    required init?(coder aDecoder: NSCoder) {
        guard let bubbles = aDecoder.decodeObject(forKey: Constants.bubblesKey) as? [GameBubble?] else {
            return nil
        }
        
        let numSections = aDecoder.decodeInteger(forKey: Constants.numSectionsKey)
        let numRowsPerOddSection = aDecoder.decodeInteger(forKey: Constants.numRowsPerOddSectionKey)
        let numRowsPerEvenSection = aDecoder.decodeInteger(forKey: Constants.numRowsPerEvenSectionKey)
        
        self.bubbles = bubbles
        self.numSections = numSections
        self.numRowsPerOddSection = numRowsPerOddSection
        self.numRowsPerEvenSection = numRowsPerEvenSection
    }
    
    // encode a ColoredBubble object
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.bubbles, forKey: Constants.bubblesKey)
        aCoder.encode(self.numSections, forKey: Constants.numSectionsKey)
        aCoder.encode(self.numRowsPerOddSection, forKey: Constants.numRowsPerOddSectionKey)
        aCoder.encode(self.numRowsPerEvenSection, forKey: Constants.numRowsPerEvenSectionKey)
    }
}
