//
//  GameSettings.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 Game related settings.
 */
struct GameSettings {
    
    var timeStep: Double = Constants.defaultTimeStep
    var gameMode: BubbleGameMode
    
    init(gameMode: BubbleGameMode) {
        self.gameMode = gameMode
    }
    
    init(timeStep: Double, gameMode: BubbleGameMode) {
        self.timeStep = timeStep
        self.gameMode = gameMode
    }
}
