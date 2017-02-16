//
//  ColoredBubble.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 27/1/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 `ColoredBubble` represents a colored bubble object in the game.
 */
class ColoredBubble: GameBubble {
    
    let color: BubbleColor
    
    convenience init(color: BubbleColor) {
        self.init(color: color, radius: 0, center: CGPoint(), velocity: CGVector())
    }
    
    init(color: BubbleColor, radius: CGFloat, center: CGPoint, velocity: CGVector) {
        self.color = color
        super.init(radius: radius, center: center, velocity: velocity)
    }
    
    // MARK: NSCoding
    // Decode from an encoded ColoredBubble
    required init?(coder aDecoder: NSCoder) {
        guard let colorString = aDecoder.decodeObject(forKey: Constants.colorKey) as? String,
            let color = BubbleColor(rawValue: colorString) else {
            return nil
        }
        self.color = color
        super.init(coder: aDecoder)
    }
    
    // encode a ColoredBubble object
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(color.rawValue, forKey: Constants.colorKey)
    }
}
