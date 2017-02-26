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
        let explosionWidth = bubbleImage.frame.size.width * Constants.explosionSizeMultiplier
        let explosionHeight = bubbleImage.frame.size.height * Constants.explosionSizeMultiplier
        
        explosionImage.frame.size = CGSize(width: explosionWidth, height: explosionHeight)
        explosionImage.center = gameBubble.center
        explosionImage.animationImages = Constants.bombExplosionImages
        explosionImage.animationDuration = Constants.explosionDuration
        explosionImage.animationRepeatCount = Constants.explosionRepeatCount
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
        
        // render the lightning images
        let lightningWidth = gameArea.frame.width
            + Constants.lightningWidthMultiplier * cellAtIndexPath.frame.size.width
        let lightningHeight = cellAtIndexPath.frame.size.height * Constants.lightningHeightMultiplier
        
        lightningImage.frame.size = CGSize(width: lightningWidth, height: lightningHeight)
        lightningImage.center = CGPoint(x: lightningXPosition, y: lightningYPosition)
        lightningImage.animationImages = Constants.lightningImages
        lightningImage.animationDuration = Constants.lightningDuration
        lightningImage.animationRepeatCount = Constants.lightningRepeatCount
        renderer.canvas.addSubview(lightningImage)
        lightningImage.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: lightningImage.animationDuration, repeats: false) { _ in
            // remove the lightning image
            lightningImage.removeFromSuperview()
        }
    }
    
    func animateStarDestroyer(at indexPath: IndexPath) {
        
        guard let targetCell = bubbleGrid.cellForItem(at: indexPath) else {
            return
        }
    
        let starDestroyerImage = UIImageView()
        let starWidth = targetCell.frame.width * Constants.starSizeMultiplier
        let starHeight = targetCell.frame.height * Constants.starSizeMultiplier
        
        starDestroyerImage.image = Constants.starDestroyerImage
        starDestroyerImage.frame.size = CGSize(width: starWidth, height: starHeight)
        starDestroyerImage.center = targetCell.center
        starDestroyerImage.alpha = Constants.starInitialAlpha
        renderer.canvas.addSubview(starDestroyerImage)
        
        UIImageView.animate(withDuration: Constants.starFadeInDuration, animations: {
            starDestroyerImage.alpha = Constants.starPresentAlpha
        }) { _ in
            
            UIImageView.animate(withDuration: Constants.starFadeOutDuration, animations: {
                starDestroyerImage.alpha = Constants.starInitialAlpha
            }) { _ in
                starDestroyerImage.removeFromSuperview()
            }
        }
    }
    
    func flashHintLocations(_ indexPath: IndexPath) {
        
        // Make sure that given index path is non empty
        // and there is a valid cell for the index path in the grid
        guard indexPath != IndexPath(),
            let cell = bubbleGrid.cellForItem(at: indexPath) else {
            return
        }
        
        UIView.animate(withDuration: Constants.hintEnterDuration, animations: {
            cell.backgroundColor = UIColor.yellow
        }, completion: { _ in
            UIView.animate(withDuration: Constants.hintExitDuration, animations: {
                cell.backgroundColor = UIColor.clear
            })
        })

    }
    
}
