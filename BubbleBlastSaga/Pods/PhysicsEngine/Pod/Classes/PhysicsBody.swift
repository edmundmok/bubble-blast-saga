//
//  PhysicsBody.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 The physics body protocol that the physics engine manipulates.
 */
public protocol PhysicsBody: class {
    
    var position: CGPoint { get set }
    var velocity: CGVector { get set }
    
}
