//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 27/1/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 `GameBubble` represents an abstract game bubble in the game.
 This class is meant to be abstract (however, not possible in Swift)
 and not meant to be instantiated.
 
 Since we still need to encode the GameBubbles, it must conform to
 NSCoding and thus implements some empty functions to conform to the protocol.
 */
class GameBubble: NSObject, NSCoding {
    
    // MARK: NSObject
    override init() { }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) { }
    
    func encode(with aCoder: NSCoder) { }

}
