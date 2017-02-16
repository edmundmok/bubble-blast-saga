//
//  CollisionHandler.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

protocol CollisionHandler {
    
    func handleCollisionBetween(_ aCircle: PhysicsCircle, and otherCircle: PhysicsCircle)
    
    func handleCollisionBetween(_ aCircle: PhysicsCircle, and aBox: PhysicsBox)
    
    func handleCollisionBetween(_ aBox: PhysicsBox, and otherBox: PhysicsBox)
    
}
