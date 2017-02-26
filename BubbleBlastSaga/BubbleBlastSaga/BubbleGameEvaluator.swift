//
//  BubbleGameEvaluator.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 24/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import Foundation

class BubbleGameEvaluator {
    
    // Mode dependent
    let gameMode: BubbleGameMode
    var timer = Timer()
    private(set) var timeLeft: Int?
    private(set) var timerStarted = false
    private(set) var shotsLeft: Int?
    private(set) var flyingBubblesCount = Constants.initialFlyingBubblesCount
    
    // Mode independent
    private let bubbleGrid: UICollectionView
    private let bubbleGridModel: BubbleGridModel
    
    init(gameMode: BubbleGameMode, bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.gameMode = gameMode
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        
        switch gameMode {
        case .LimitedShots:
            self.shotsLeft = Constants.limitedShotsAmmo
        case .LimitedTime:
            self.timeLeft = Constants.limitedTimeQuota
        case .SurvivorSolo: return
        case .SurvivorVersus: return
        case .Multiplayer: return
        }
    }
    
    // Use up 1 bubble cannon ammo, if possible.
    // Returns a boolean representing if it is possible or not.
    func useBubbleAmmo() -> Bool {
        
        switch gameMode {
        case .LimitedShots:
            return useBubbleAmmoForLimitedShotsMode()
        case .LimitedTime:
            fallthrough
        case .Multiplayer:
            return useBubbleAmmoForTimedMode()
        default:
            return true
        }
        
    }
    
    private func useBubbleAmmoForLimitedShotsMode() -> Bool {
        guard let remainingAmmo = shotsLeft else {
            return true
        }
        
        // Check if still have remaining shots to fire
        guard remainingAmmo > 0 else {
            // Used up all shots, cannot fire anymore
            return false
        }
        
        // Use up one ammo, and increase flying bubbles count
        // due to the bubble being shot
        shotsLeft = remainingAmmo - 1
        flyingBubblesCount += 1
        return true
    }
    
    private func useBubbleAmmoForTimedMode() -> Bool {
        // Start timer on the first shot
        if !timerStarted {
            timerStarted = true
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                selector: #selector(timerHandle), userInfo: nil, repeats: true)
        }
        
        guard let remainingTime = timeLeft else {
            return true
        }
        
        // Check if there is still remaining time
        guard remainingTime > 0 else {
            // Times up, not allowed to fire anymore
            return false
        }
        
        // Increase flying bubbles count due to bubble being shot
        flyingBubblesCount += 1
        return true
    }
    
    // Updates the evaluator that a bubble that was flying has landed.
    func updateFlyingBubbleLanded() {
        flyingBubblesCount -= 1
    }
    
    // Evaluates the current state of the game
    func evaluateGame() {
        // Evaluate game depending on game mode
        switch gameMode {
        case .LimitedShots:
            evaluateGameForLimitedShots()
        case .LimitedTime:
            evaluateGameForLimitedTime()
        case .SurvivorSolo:
            return
        case .SurvivorVersus:
            return
        case .Multiplayer:
            return
        }
    }
    
    // Evaluates the current state of the game based on limited shots game mode
    private func evaluateGameForLimitedShots() {
        // First check if bubble in last section, if yes, auto lose.
        guard !hasBubblesInLastSection() else {
            NotificationCenter.default.post(name: Constants.gameLostNotificationName, object: nil)
            return
        }
        
        // Don't evaluate if there are still bubbles flying
        guard flyingBubblesCount == 0 else {
            return
        }
        
        // Check number of bubbles remaining in the grid
        let remainingCount = bubbleGridModel.getIndexPathOfBubblesInGrid().count
        
        guard remainingCount > 0 else {
            // Remaining count == 0 (game won!)
            NotificationCenter.default.post(name: Constants.gameWonNotificationName, object: nil)
            return
        }
        
        // If grid still not empty:
        // Then check based on ammo.
        
        // game lost if ammo gone!
        guard let remainingAmmo = shotsLeft, remainingAmmo == 0 else {
            // still has ammo, cannot determine outcome of game yet.
            return
        }
        
        // no ammo left, player lost!
        NotificationCenter.default.post(name: Constants.gameLostNotificationName, object: nil)
    }
    
    // Evaluates the current state of the game based on limited time mode
    private func evaluateGameForLimitedTime() {
        
        // First check if bubble in last section, if yes, auto lose.
        guard !hasBubblesInLastSection() else {
            timer.invalidate()
            // Lose the game
            NotificationCenter.default.post(name: Constants.gameLostNotificationName, object: nil)
            return
        }
        
        // Don't evaluate if there are still bubbles flying
        guard flyingBubblesCount == 0 else {
            return
        }
        
        // Check number of bubbles remaining in the grid
        let remainingCount = bubbleGridModel.getIndexPathOfBubblesInGrid().count
        
        guard remainingCount > 0 else {
            // Remaining count == 0 (game won!)
            timer.invalidate()
            NotificationCenter.default.post(name: Constants.gameWonNotificationName, object: nil)
            return
        }
        
        // Remaining count > 0 (game lost if times up!)
        guard let remainingTime = timeLeft, remainingTime == 0 else {
            // time not up yet, cannot determine game outcome yet
            return
        }
        
        // no time left, player lost!
        timer.invalidate()
        NotificationCenter.default.post(name: Constants.gameLostNotificationName, object: nil)
    }
    
    private func hasBubblesInLastSection() -> Bool {
        let lastSectionIndexPaths = BubbleGameUtility.getIndexPathsForBottomSection(of: bubbleGridModel)
        
        let bubblesInLastSectionCount = lastSectionIndexPaths
            .filter { bubbleGridModel.getGameBubble(at: $0) != nil}
            .count
        
        return bubblesInLastSectionCount > 0
    }
    
    @objc private func timerHandle() {
        guard let remainingTime = timeLeft,
            remainingTime > 0 else {
            // times up, check stuff
            timer.invalidate()
            evaluateGameForLimitedTime()
            return
        }

        timeLeft = remainingTime - 1
    }
}
