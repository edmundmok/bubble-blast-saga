//
//  GameObject.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class GameObject: NSObject, NSCoding, PhysicsBody {

    let uuid: UUID
    var position: CGPoint
    var velocity: CGVector
    
    
    // MARK: NSObject
    override convenience init() {
        self.init(position: CGPoint(), velocity: CGVector())
    }
    
    init(position: CGPoint, velocity: CGVector) {
        self.uuid = UUID()
        self.position = position
        self.velocity = velocity
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        guard let uuid = aDecoder.decodeObject(forKey: Constants.uuidKey) as? UUID else {
            return nil
        }
        
        let position = aDecoder.decodeCGPoint(forKey: Constants.positionKey)
        let velocity = aDecoder.decodeCGVector(forKey: Constants.velocityKey)
        
        self.uuid = uuid
        self.position = position
        self.velocity = velocity
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: Constants.uuidKey)
        aCoder.encode(position, forKey: Constants.positionKey)
        aCoder.encode(velocity, forKey: Constants.velocityKey)
    }
}
