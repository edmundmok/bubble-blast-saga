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
    
    // Notifications
    static let timerUpdatedUpdatedNotificationName = Notification.Name.init("TimerUpdated")
    static let gameWonNotificationName = Notification.Name.init("GameWon")
    static let gameLostNotificationName = Notification.Name.init("GameLost")
    static let newHighscoreNotificationName = Notification.Name.init("NewHighscore")
    
    // BubbleGameEvaluator
    static let timerFinalValue = timeLimit * timerPrecision
    static let timeLimit = 100
    static let timerPrecision = 10
    static let initialFlyingBubblesCount = 0
    
    // BubbleGameStats
    static let initialScore = 0.0
    static let initialStreak = 0
    static let initialCombo = 0
    static let initialChain = 0
    static let initialBubblesShot = 0
    static let initialAccuracy = 0.0
    static let resetValue = 0
    static let scorePerRemoval = 50
    static let scoreMultiplierPerChain = 0.5
    static let scoreMultiplierPerStreak = 0.5
    static let baseValue = 1.0
    
    // BubbleGameHintHelper
    static let defaultRemovalCount = -1
    static let reboundRatioConstant = CGFloat(2)
    
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
    static let defaultRadius = CGFloat(0)
    
    // ColoredBubble
    static let colorKey = "color"
    
    // PowerBubble
    static let powerKey = "power"
    
    // PaletteBubble
    static let paletteBubbleBorderWidth = CGFloat(3)
    static let paletteBubbleUnselectedBorderWidth = CGFloat(0)
    static let unselectedAlpha = CGFloat(0.5)

    // BubbleCell
    static let bubbleCellIdentifier = "BubbleCell"
    static let emptyCellAlpha = CGFloat(0.3)
    static let emptyCellBorderWidth = CGFloat(1)
    static let filledCellBorderWidth = CGFloat(0)
    
    // BubbleGame
    static let wallThickness = 10 * Constants.bubbleSpeed
    static let sideWallHeightMultiplier = CGFloat(1.3)
    static let horizontalWallWidthMultiplier = CGFloat(2)
    static let numberOfBubbles = UInt32(4)
    static let bottomWallMultiplier = CGFloat(1.2)
    static let trajectoryPointsCount = 100
    static let widthToRadiusMultiplier = CGFloat(0.5)
    static let bubbleHitBoxSizePercentage = CGFloat(0.85)
    
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
    static let bubbleSpeed: CGFloat = 15
    static let cannonAnchorX = CGFloat(0.5)
    static let cannonAnchorY = CGFloat(0.65)
    static let hiddenAlpha = CGFloat(0)
    static let shownAlpha = CGFloat(1)
    static let currentBubbleViewSizeMultiplier = CGFloat(0.8)
    static let currentBubbleViewYMultiplier = CGFloat(0.1)
    static let updateNextBubbleFadeDuration = 0.5
    static let currentBubbleMoveUpDuration = 0.5
    static let currentBubbleXOffset = CGFloat(0)
    static let currentBubbleYOffsetMultiplier = CGFloat(-1)
    static let reloadDuration = 0.5
    static let hideGameStatsDuration = 1.0
    static let moveUIBackDuration = 1.0
    static let redisplayUIDuration = 1.5
    static let winString = "You win"
    static let loseString = "You lose"
    static let luckyColorPrefix = "Your lucky color is "
    static let noLuckyColor = "no color"
    static let bestComboPrefix = "Best combo: "
    static let bestChainPrefix = "Best chain: "
    static let bestStreakPrefix = "Best streak: "
    static let accuracyPrefix = "Accuracy: "
    static let accuracyPostfix = "%"
    static let accuracyToPercentage = Double(100)
    static let hideUIDuration = 1.5
    static let moveUIDuration = 1.0
    static let showGameStatsDuration = 1.0
    static let swapDuration = 0.5
    static let gameMenuButtonsBorderWidth = CGFloat(3)
    
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
    static let explosionSizeMultiplier = CGFloat(3)
    static let explosionRepeatCount = 1
    static let explosionDuration = 1.0
    static let lightningWidthMultiplier = CGFloat(2)
    static let lightningHeightMultiplier = CGFloat(4)
    static let lightningDuration = 1.0
    static let lightningRepeatCount = 1
    static let starSizeMultiplier = CGFloat(2)
    static let starInitialAlpha = CGFloat(0.0)
    static let starPresentAlpha = CGFloat(1.0)
    static let starFadeInDuration = 0.5
    static let starFadeOutDuration = 0.5
    static let hintEnterDuration = 1.0
    static let hintExitDuration = 1.0
    
    // LevelDesignerViewController
    static let startLevelSegue = "StartLevelDesignerLevel"
    static let defaultNumSections = 12
    static let defaultNumRows = 12
    static let validationFailEnterDuration = 0.5
    static let validationFailExitDuration = 5.0
    
    // LevelDesignerSaveAlertController
    static let saveAlertTitle = "Level Name"
    static let saveAlertMessage = "Please enter the name of the level to save as. (Only alphanumeric characters allowed)"
    static let saveAlertTextPlaceholder = "Level Name to save as"
    static let cancelTitle = "Cancel"
    static let saveTitle = "Save"
    static let saveAsAnotherTitle = "Save as another name"
    static let blankLevelName = ""
    static let blankMessage = ""
    static let pngExtension = "png"
    static let plistExtension = "plist"
    static let yesTitle = "Yes"
    static let noTitle = "No"
    static let okTitle = "OK"
    static let tryAgainMessage = "Please try again!"
    
    // LevelSelectViewController
    static let deleteAlertTitle = "Confirm delete?"
    static let deleteAlertMessage = "The level will be lost forever."
    static let deleteTitle = "Delete"
    static let levelsPerSection = 2
    static let minViewControllerCount = 2
    static let loadToLevelDesignerSegue = "loadToLevelDesigner"
    static let loadToGameSegue = "loadToGame"
    
    // LevelSelectDataSource
    static let additionalLevelForOddRow = 1
    static let levelSelectReuseIdentifier = "LevelSelectCell"
    static let levelSelectCellCornerMultiplier = CGFloat(15.0)
    static let levelSelectCellAspectRatio = CGFloat(4/3)
    static let levelSelectImageAlpha = CGFloat(0.4)
    
    // LevelSelectDelegate
    static let levelSelectMinLineSpacing = CGFloat(0)
    static let levelSelectMinInteritemSpacing = CGFloat(0)
    
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
    
    // Image -- starDestroyer
    static let starDestroyerImage = UIImage(named: "star")
    
    static let cannonFireDuration = 0.3
    static let cannonRepeatCount = 1
}
