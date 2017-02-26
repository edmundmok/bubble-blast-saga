//
//  BubbleCannon.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 17/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

class BubbleCannon {
    
    // Current bubble to shoot
    private(set) lazy var currentBubble: GameBubble = {
        return self.getNextCannonBubble()
    }()
    
    // Next bubble to shoot, after the current bubble
    private(set) lazy var nextBubble: GameBubble = {
        return self.getNextCannonBubble()
    }()
    
    private let bubbleGridModel: BubbleGridModel
    
    init(bubbleGridModel: BubbleGridModel) {
        self.bubbleGridModel = bubbleGridModel
    }
    
    // Swap the current with the next bubble
    func swapCurrentWithNextBubble() {
        let temp = currentBubble
        currentBubble = nextBubble
        nextBubble = temp
    }
    
    // Reload the cannon
    func reloadCannon() {
        // replace current with next
        currentBubble = nextBubble
        
        // generate a new into next
        nextBubble = getNextCannonBubble()
    }
    
    // Simple algorithm to decide next cannon bubble
    // (Luck rating) % chance of getting most common color
    // (1 - luck rating) % chance of getting random color
    //
    // Easy: 60%
    // Medium: 50%
    // Hard: 40%
    private func getNextCannonBubble() -> GameBubble {
        // 0..<(luck rating), get the common color
        // luck rating..9, get the random color
        let chanceNumber = arc4random() % 10
        
        // assume easy rating for now
        guard chanceNumber < 6 else {
            // get the random color as number falls outside luck range
            return getRandomBubble()
        }
        
        // number falls within luck range
        // find the most common bubble color
        // return a new bubble of that color
        return getMostCommonColoredBubble()
    }
    
    // Randomly generates the next cannon bubble and returns it.
    private func getRandomBubble() -> GameBubble {
        let randomGameBubbleNumber = arc4random() % Constants.numberOfBubbles
        switch randomGameBubbleNumber {
        case 0: return ColoredBubble(color: .Red)
        case 1: return ColoredBubble(color: .Blue)
        case 2: return ColoredBubble(color: .Orange)
        case 3: return ColoredBubble(color: .Green)
        default: return ColoredBubble(color: .Red)
        }
    }
    
    // Returns a colored bubble of the most common color in the grid.
    private func getMostCommonColoredBubble() -> GameBubble {
        let indexPaths = bubbleGridModel.getIndexPathOfBubblesInGrid()
        
        var colorFrequencyDictionary = [BubbleColor : Int]()
        
        // Initialize frequeuncy count of all colors to 0
        for color in BubbleColor.allColors {
            colorFrequencyDictionary[color] = 0
        }
        
        // Count frequency
        for indexPath in indexPaths {
            guard let color = (bubbleGridModel.getGameBubble(at: indexPath) as? ColoredBubble)?.color else {
                continue
            }
            
            guard let colorFrequency = colorFrequencyDictionary[color] else {
                continue
            }

            colorFrequencyDictionary[color] = colorFrequency + 1
        }
        
        // Get the one with highest frequency
        var maxFrequency = -1, maxColor = BubbleColor.Red
        
        for color in BubbleColor.allColors {
            
            guard let frequency = colorFrequencyDictionary[color] else {
                continue
            }
            
            if frequency > maxFrequency {
                maxFrequency = frequency
                maxColor = color
            }
            
        }
        
        return ColoredBubble(color: maxColor)
    }
}
