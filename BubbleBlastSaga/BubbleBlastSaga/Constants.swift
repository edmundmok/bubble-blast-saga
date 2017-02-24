//
//  Constants.swift
//  GameEngine
//
//  Created by Edmund Mok on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    // BubbleGrid
    static let bubblesKey = "bubbles"
    static let numSectionsKey = "numSections"
    static let numRowsPerEvenSectionKey = "numRowsPerEvenSection"
    static let numRowsPerOddSectionKey = "numRowsPerOddSection"
    
    // BubbleGridModelManager
    static let fileExtension = "bubblegrid"
    static let bubbleGridKey = "bubbleGrid"
    
    // GameObject
    static let uuidKey = "uuid"
    static let positionKey = "position"
    static let velocityKey = "velocity"
    
    // GameBubble
    static let radiusKey = "radius"
    
    // ColoredBubble
    static let colorKey = "color"
    
    // PowerBubble
    static let powerKey = "power"

    // BubbleCell
    static let bubbleCellIdentifier = "BubbleCell"
    static let emptyCellAlpha = CGFloat(0.3)
    static let emptyCellBorderWidth = CGFloat(1)
    static let filledCellBorderWidth = CGFloat(0)
    
    // BubbleGame
    static let wallLength = CGFloat(0)
    static let numberOfBubbles = UInt32(4)
    static let bottomWallMultiplier = CGFloat(1.2)
    static let trajectoryPointsCount = 100
    
    // BubbleGameLogic / BubbleGameCollisionHandler
    static let infiniteDistance = CGFloat(-1)
    static let minimumConnectedCountToPop = 3
    static let pointAtFarLocation = CGPoint(x: 999999, y: 999999)
    static let velocityReflectMultiplier = CGFloat(-1)
    static let bubbleStandardMass = CGFloat(1)
    
    // GameViewController
    static let bubbleGridNumSections = 12
    static let bubbleGridNumRows = 12
    static let minimumLongPressDuration = 0.0
    static let bubbleHitBoxSizePercentage = 0.85
    static let bubbleSpeed: CGFloat = 15
    
    // TrajectoryPathLayer
    static let lineWidthMultiplier = CGFloat(0.005)
    static let dashPatternStart = NSNumber(value: 0)
    static let dashMultiplier = CGFloat(4)
    static let dashPhase = CGFloat(0)
    
    // GameSettings
    static let defaultTimeStep = 1.0 / 60.0
    
    // GameViewControllerDelegate
    static let horizontalOffsetMultiplier = CGFloat(2.001)
    static let verticalOffsetMultiplier = CGFloat(-8)
    
    // Animations
    static let popDuration = 0.5
    static let popRemovalTime = 0.8 * popDuration
    static let popRepeatCount = 1
    static let dropDurationMultiplier = 0.002
    static let dropDistanceMultiplier = CGFloat(5)
    static let dropHorizontalOffset = CGFloat(0)
    
    // LevelDesignerViewController
    static let startLevelSegue = "StartLevelDesignerLevel"
    
    // Images
    static let blueBubbleImage = "bubble-blue"
    static let redBubbleImage = "bubble-red"
    static let orangeBubbleImage = "bubble-orange"
    static let greenBubbleImage = "bubble-green"
    static let indestructibleBubbleImage = "bubble-indestructible"
    static let lightningBubbleImage = "bubble-lightning"
    static let bombBubbleImage = "bubble-bomb"
    static let starBubbleImage = "bubble-star"
    
    // Images -- Cannon
    static let cannonImage = "cannon_01"
    static let cannonAnimationImages = [
        UIImage(named: "cannon_01")!,
        UIImage(named: "cannon_02")!,
        UIImage(named: "cannon_03")!,
        UIImage(named: "cannon_04")!,
        UIImage(named: "cannon_05")!,
        UIImage(named: "cannon_06")!,
        UIImage(named: "cannon_07")!,
        UIImage(named: "cannon_08")!,
        UIImage(named: "cannon_09")!,
        UIImage(named: "cannon_10")!,
        UIImage(named: "cannon_11")!,
        UIImage(named: "cannon_12")!,
    ]
    
    // Images -- Bubble burst
    static let bubbleBurstAnimationImages = [
        UIImage(named: "bubble-burst_01")!,
        UIImage(named: "bubble-burst_02")!,
        UIImage(named: "bubble-burst_03")!,
        UIImage(named: "bubble-burst_04")!
    ]
    
    // Images -- Bomb explosion
    static let bombExplosionImages = [
        UIImage(named: "explosion_01")!,
        UIImage(named: "explosion_02")!,
        UIImage(named: "explosion_03")!,
        UIImage(named: "explosion_04")!,
        UIImage(named: "explosion_05")!,
        UIImage(named: "explosion_06")!,
        UIImage(named: "explosion_07")!,
        UIImage(named: "explosion_08")!,
        UIImage(named: "explosion_09")!,
        UIImage(named: "explosion_10")!,
        UIImage(named: "explosion_11")!,
        UIImage(named: "explosion_12")!,
    ]
    
    // Images -- Lightning flash
    static let lightningImages = [
        UIImage(named: "lightning_01")!,
        UIImage(named: "lightning_02")!,
        UIImage(named: "lightning_03")!,
        UIImage(named: "lightning_04")!,
        UIImage(named: "lightning_05")!,
        UIImage(named: "lightning_06")!,
        UIImage(named: "lightning_07")!,
        UIImage(named: "lightning_08")!,
        UIImage(named: "lightning_09")!,
        UIImage(named: "lightning_10")!,
    ]
    
    static let cannonFireDuration = 0.3
    static let cannonRepeatCount = 1
}
