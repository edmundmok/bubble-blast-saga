//
//  Renderer.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import PhysicsEngine

/**
 The renderer class that draws game objects onto the given canvas.
 */
class Renderer {
    
    var canvas: UIView
    private var imageMap = [UUID: UIImageView]()
    
    init(canvas: UIView) {
        self.canvas = canvas
    }
    
    // Registers the image associated with the given gameObject
    // into the renderer's imagemap.
    func register(image: UIImageView, for gameObject: GameObject) {
        imageMap[gameObject.uuid] = image
        canvas.addSubview(image)
    }
    
    // Deregisters the image associated with the given gameObject
    // from the renderer's imagemap.
    func deregisterImage(for gameObject: GameObject) {
        imageMap[gameObject.uuid]?.removeFromSuperview()
        imageMap[gameObject.uuid] = nil
    }
    
    // Deregisters all images from internal imagemap.
    func deregisterAllImages() {
        imageMap.forEach { (uuid, image) in
            image.removeFromSuperview()
            imageMap[uuid] = nil
        }
    }
    
    // Retrieve the associated image for the given game object.
    // Returns nil if there is no associated image.
    func getImage(for gameObject: GameObject) -> UIImageView? {
        return imageMap[gameObject.uuid]
    }
    
    // Draws the given game objects onto the current canvas.
    func draw(_ gameObjects: [GameObject]) {
        for gameObject in gameObjects {
        
            // Get the image
            let objectImageView = imageMap[gameObject.uuid]
            
            // Check if we are drawing a circle
            guard let circle = gameObject as? PhysicsCircle else {
                // Not a circle, use the position
                objectImageView?.frame.origin = gameObject.position
                continue
            }
            
            // Drawing a circle, use its center
            objectImageView?.center = circle.center
        }
    }
}
