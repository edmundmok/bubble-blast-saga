//
//  PhysicsCircle.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 A protocol for representing a physics body that has a circle shape.
 */
protocol PhysicsCircle: PhysicsBody {
    
    var radius: CGFloat { get set }
    var center: CGPoint { get set }
    
}
