//
//  BubbleType.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

/**
 An enumeration of all the possible bubble types.
 */
enum BubbleType: Int {

    // making raw values explicit
    case Empty = 0
    case BlueBubble = 1
    case RedBubble = 2
    case OrangeBubble = 3
    case GreenBubble = 4
    
    // Cycles to and retrieves the next bubble type
    var next: BubbleType {
        // If empty, no next bubble type in the cycle
        // Just return empty
        guard self != .Empty else {
            return .Empty
        }
        
        // If last valid bubble type, need to cycle back over to the
        // first valid (non empty) bubble type at position 1
        guard let next = BubbleType(rawValue: self.rawValue + 1) else {
            return BubbleType(rawValue: 1)!
        }
        
        // Otherwise just return the bubble type at the next position
        return next
    }

}
