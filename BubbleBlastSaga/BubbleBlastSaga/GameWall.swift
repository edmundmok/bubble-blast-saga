//
//  GameWall.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import PhysicsEngine

/**
 This class represents a wall object in the bubble game.
 */
class GameWall: GameObject, PhysicsBox {
    
    enum WallType {
        case SideWall, TopWall, BottomWall
    }
    
    var wallType: WallType
    var size: CGSize
    
    init(wallType: WallType, position: CGPoint, size: CGSize) {
        self.wallType = wallType
        self.size = size
        super.init(position: position, velocity: .zero)
    }
    
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func encode(with aCoder: NSCoder) { }
}
