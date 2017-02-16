//
//  AnimationHelper.swift
//  GameEngine
//
//  Created by Edmund Mok on 13/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation
//
//  AnimationHelper.swift
//  GameEngine
//
//  Created by Edmund Mok on 13/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class AnimationHelper {
    
    enum Animation {
        case BubbleDrop
        case BubblePop
    }
    
    // Returns the animation block for the given animation type on the specified view.
    static func create(_ animation: Animation, for view: UIView) -> () -> Void {
        switch animation {
        case .BubbleDrop: return createBubbleDropAnimation(for: view)
        case .BubblePop: return createBubblePopAnimation(for: view)
        }
    }
    
    // Helper function to generate the bubble drop animation on the given bubble view.
    private static func createBubbleDropAnimation(for bubbleView: UIView) -> () -> Void {
        // Assumes that the bubble view to drop is in a superview.
        guard let bottomOfScreen = bubbleView.superview?.frame.maxY else {
            return {}
        }
        
        // Calculate the final position after the drop
        let finalDropPosition = bottomOfScreen +
            (bubbleView.frame.size.height * Constants.dropDistanceMultiplier)
        
        // Calculate the distance to drop by
        let distanceToDrop = finalDropPosition - bubbleView.center.y
        
        return { _ in
            let initialFrame = bubbleView.frame
            let finalFrame = initialFrame.offsetBy(dx: Constants.dropHorizontalOffset,
                dy: distanceToDrop)
            bubbleView.frame = finalFrame
        }
    }
    
    // Helper function to generate the bubble pop animation on the given bubble view.
    private static func createBubblePopAnimation(for bubbleView: UIView) -> () -> Void {
        return { _ in
            bubbleView.transform = CGAffineTransform(scaleX: Constants.popExpansionFactor,
                y: Constants.popExpansionFactor)
            bubbleView.alpha = Constants.popAlpha
        }
    }
}
