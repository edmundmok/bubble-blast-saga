//
//  BubbleGameAnimator.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameAnimator {
    
    private let gameArea: UIView
    private let renderer: Renderer
    private let bubbleGrid: UICollectionView
    
    init(gameArea: UIView, renderer: Renderer, bubbleGrid: UICollectionView) {
        self.gameArea = gameArea
        self.renderer = renderer
        self.bubbleGrid = bubbleGrid
    }
    
    func dropBubble(_ gameBubble: GameBubble) {
        // Check that there is an image for animation
        guard let bubbleImage = renderer.getImage(for: gameBubble) else {
            return
        }
        
        let bottomOfScreen = gameArea.frame.maxY
        
        // Calculate the final position after the drop
        let finalDropPosition = bottomOfScreen +
            (bubbleImage.frame.size.height * Constants.dropDistanceMultiplier)
        
        // Calculate the distance to drop by
        let distanceToDrop = finalDropPosition - bubbleImage.center.y
        
        // Compute drop duration
        let distanceToBottom = gameArea.frame.maxY - gameBubble.center.y
        let dropDuration = Double(distanceToBottom) * Constants.dropDurationMultiplier
        
        // Run the animation
        UIView.animate(withDuration: dropDuration, animations: {
            let initialFrame = bubbleImage.frame
            let finalFrame = initialFrame.offsetBy(dx: Constants.dropHorizontalOffset,
                dy: distanceToDrop)
            bubbleImage.frame = finalFrame
        }, completion: { _ in
            self.renderer.deregisterImage(for: gameBubble)
        })
    }
    
    func popBubble(_ gameBubble: GameBubble) {
        // Check that there is an image for animation
        guard let bubbleImage = renderer.getImage(for: gameBubble) else {
            return
        }
        
        bubbleImage.animationImages = Constants.bubbleBurstAnimationImages
        bubbleImage.animationDuration = Constants.popDuration
        bubbleImage.animationRepeatCount = Constants.popRepeatCount
        bubbleImage.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: Constants.popRemovalTime, repeats: false, block: { _ in
            self.renderer.deregisterImage(for: gameBubble)
        })
    }
    
    func explodeBomb(_ gameBubble: GameBubble) {
        // Get the image for reference
        guard let bubbleImage = renderer.getImage(for: gameBubble) else {
            return
        }
        
        let explosionImage = UIImageView()
        
        // render the explosion images
        explosionImage.frame.size = CGSize(width: bubbleImage.frame.size.width * 3, height: bubbleImage.frame.size.height * 3)
        explosionImage.center = gameBubble.center
        explosionImage.animationImages = Constants.bombExplosionImages
        explosionImage.animationDuration = 1
        explosionImage.animationRepeatCount = 1
        renderer.canvas.addSubview(explosionImage)
        explosionImage.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: explosionImage.animationDuration, repeats: false) { _ in
            // remove the explosion image
            explosionImage.removeFromSuperview()
        }
    }
    
    func animateLightning(for indexPath: IndexPath) {
        guard let cellAtIndexPath = bubbleGrid.cellForItem(at: indexPath) else {
            return
        }
        
        let lightningYPosition = cellAtIndexPath.center.y
        let lightningXPosition = bubbleGrid.center.x
        
        let lightningImage = UIImageView()
        
        // render the lightning iamges
        lightningImage.frame.size = CGSize(width: gameArea.frame.width + 2 * cellAtIndexPath.frame.size.width, height: cellAtIndexPath.frame.size.height * 4)
        lightningImage.center = CGPoint(x: lightningXPosition, y: lightningYPosition)
        lightningImage.animationImages = Constants.lightningImages
        lightningImage.animationDuration = 1
        lightningImage.animationRepeatCount = 1
        renderer.canvas.addSubview(lightningImage)
        lightningImage.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: lightningImage.animationDuration, repeats: false) { _ in
            // remove the lightning image
            lightningImage.removeFromSuperview()
        }
    }
    
    func flashHintLocations(_ indexPath: IndexPath) {
        
        guard indexPath != IndexPath() else {
            return
        }
        
        guard let cell = bubbleGrid.cellForItem(at: indexPath) else {
            return
        }
        
        UIView.animate(withDuration: 1.0, animations: {
            cell.backgroundColor = UIColor.yellow
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, animations: {
                cell.backgroundColor = UIColor.clear
            })
        })

    }
    
}
