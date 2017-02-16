//
//  Renderer.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

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
    
    // Animates the given game object's corresponding image (if available), using the 
    // given animation over the specified duration.
    // Removes the image from the imageMap and the canvas on animation complete if requested.
    func animate(_ gameObject: GameObject, with animation: AnimationHelper.Animation,
        for duration: TimeInterval, removeOnComplete: Bool) {
        
        // If there is no image for the given game object, nothing to animate
        guard let imageToAnimate = imageMap[gameObject.uuid] else {
            return
        }
        
        // Get the appropriate animation
        let animationForView = AnimationHelper.create(animation, for: imageToAnimate)
        
        // Run the animation
        UIView.animate(withDuration: duration, animations: animationForView, completion: { _ in
            // Check if removing on complete
            guard removeOnComplete else {
                return
            }
            
            // If yes, remove it on complete
            self.imageMap[gameObject.uuid] = nil
            imageToAnimate.removeFromSuperview()
        })
    }
}
