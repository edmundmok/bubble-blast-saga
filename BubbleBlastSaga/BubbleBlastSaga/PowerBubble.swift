//
//  PowerBubble.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 `PowerBubble` represents a special bubble object in the game, that has special powers.
 */
class PowerBubble: GameBubble {
    
    let power: BubblePower
    
    convenience init(power: BubblePower) {
        self.init(power: power, radius: Constants.defaultRadius, center: CGPoint(), velocity: CGVector())
    }
    
    init(power: BubblePower, radius: CGFloat, center: CGPoint, velocity: CGVector) {
        self.power = power
        super.init(radius: radius, center: center, velocity: velocity)
    }
    
    // MARK: NSCoding
    // Decode from an encoded ColoredBubble
    required init?(coder aDecoder: NSCoder) {
        guard let powerString = aDecoder.decodeObject(forKey: Constants.powerKey) as? String,
            let power = BubblePower(rawValue: powerString) else {
                return nil
        }
        self.power = power
        super.init(coder: aDecoder)
    }
    
    // encode a ColoredBubble object
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(power.rawValue, forKey: Constants.powerKey)
    }
}
