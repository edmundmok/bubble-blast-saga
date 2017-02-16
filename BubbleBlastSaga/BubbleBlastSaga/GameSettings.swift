//
//  GameSettings.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

struct GameSettings {
    var timeStep: Double = Constants.defaultTimeStep
    
    init() { }
    
    init(timeStep: Double) {
        self.timeStep = timeStep
    }
}
