//
//  GameEngine.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import Foundation
import PhysicsEngine

class GameEngine {
    
    // Game loop timer
    private var gameLoopTimer = Timer()
    
    // Essential components of the game engine
    let physicsEngine: PhysicsEngine
    let renderer: Renderer
    
    // Game objects
    private var gameObjects = [GameObject]()
    
    // Settings
    private let gameSettings: GameSettings
    
    init(physicsEngine: PhysicsEngine, renderer: Renderer, gameSettings: GameSettings) {
        self.physicsEngine = physicsEngine
        self.renderer = renderer
        self.gameSettings = gameSettings
    }
    
    // Starts the game loop running.
    func startGameLoop() {
        gameLoopTimer = Timer.scheduledTimer(timeInterval: gameSettings.timeStep,
            target: self, selector: #selector(mainLoopBody), userInfo: nil, repeats: true)
    }
    
    // Stops the game loop.
    func stopGameLoop() {
        gameLoopTimer.invalidate()
    }
    
    // Runs a single iteration of the game loop.
    @objc private func mainLoopBody() {
        // Use physics engine to update object physical properties
        physicsEngine.updateState(for: gameObjects as [PhysicsBody])
        
        // Call renderer to redraw objects
        renderer.draw(gameObjects)
    }
    
    // Registers the given GameObject into the game engine,
    // without an associated image.
    func register(gameObject: GameObject) {
        // Add to gameObjects array
        gameObjects.append(gameObject)
    }
    
    // Registers the given GameObject into the game engine, 
    // with the associated image.
    func register(gameObject: GameObject, with image: UIImageView) {
        // Add to gameObjects array
        gameObjects.append(gameObject)
        
        // Inform the renderer
        renderer.register(image: image, for: gameObject)
    }
    
    // Deregisters the given GameObject from the game engine, 
    // and also removes it from the renderer if possible.
    func deregister(gameObject: GameObject) {
        // remove the given gameObject from gameObjects
        removeFromGameObjects(gameObject: gameObject)
        
        // Inform the renderer
        renderer.deregisterImage(for: gameObject)
    }
    
    // Deregisters the given GameObject from the game engine for an animation on the
    // image associated with the given gameObject. 
    // As such, it does not remove the given gameObject's associated image from the renderer.
    func deregisterForAnimation(gameObject: GameObject) {
        // remove the given gameObject from gameObjects
        removeFromGameObjects(gameObject: gameObject)
    }
    
    // Removes the given game object from the gameObjects array.
    private func removeFromGameObjects(gameObject: GameObject) {
        gameObjects = gameObjects.filter { $0 !== gameObject }

    }
}
