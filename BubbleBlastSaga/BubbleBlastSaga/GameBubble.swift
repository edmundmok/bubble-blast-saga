//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 27/1/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 `GameBubble` represents an abstract game bubble in the game.
 This class is meant to be abstract (however, not possible in Swift)
 and not meant to be instantiated.
 
 Since we still need to encode the GameBubbles, it must conform to
 NSCoding and thus implements some empty functions to conform to the protocol.
 */
class GameBubble: GameObject, PhysicsCircle {
    
    var radius: CGFloat
    var center: CGPoint {
        get {
            return position
        }
        set {
            position = newValue
        }
    }
    
    // MARK: NSObject
    convenience init() {
        self.init(radius: 0, center: CGPoint())
    }
    
    convenience init(radius: CGFloat, center: CGPoint) {
        self.init(radius: radius, center: center, velocity: CGVector())
    }
    
    init(radius: CGFloat, center: CGPoint, velocity: CGVector) {
        self.radius = radius
        super.init(position: center, velocity: velocity)
        self.center = center
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        guard let radius = aDecoder.decodeObject(forKey: Constants.radiusKey) as? CGFloat else {
            return nil
        }
        self.radius = radius
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(radius, forKey: Constants.radiusKey)
    }

}
