//
//  CGPoint+Distance.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

extension CGPoint {
    
    // Returns the distance from the current point to the given point.
    func distance(to point: CGPoint) -> CGFloat {
        let distX = x - point.x
        let distY = y - point.y
        return sqrt(pow(distX, 2) + pow(distY, 2))
    }
    
}
