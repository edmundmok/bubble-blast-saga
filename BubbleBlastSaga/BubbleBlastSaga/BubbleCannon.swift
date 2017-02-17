//
//  BubbleCannon.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 17/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

class BubbleCannon {
    
    // current bubble
    private(set) var currentBubble: GameBubble
    
    // next bubble
    private(set) var nextBubble: GameBubble
    
    init() {
        currentBubble = BubbleCannon.getNextCannonBubble()
        nextBubble = BubbleCannon.getNextCannonBubble()
    }
    
    // swap current and next
    func swapCurrentWithNextBubble() {
        // swap the bubbles
        let temp = currentBubble
        currentBubble = nextBubble
        nextBubble = temp
    }
    
    // TODO: Temporary way of generating bubbles, hope to find a 
    // better way of doing this.
    func reloadCannon() {
        // replace current with next
        currentBubble = nextBubble
        
        // generate a new into next
        nextBubble = BubbleCannon.getNextCannonBubble()
    }
    
    // Randomly generates the next cannon bubble and returns it.
    private static func getNextCannonBubble() -> GameBubble {
        let randomGameBubbleNumber = arc4random() % Constants.numberOfBubbles
        switch randomGameBubbleNumber {
        case 0: return ColoredBubble(color: .Red)
        case 1: return ColoredBubble(color: .Blue)
        case 2: return ColoredBubble(color: .Orange)
        case 3: return ColoredBubble(color: .Green)
        default: return ColoredBubble(color: .Red)
        }
    }
}
