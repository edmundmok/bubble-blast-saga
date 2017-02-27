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
    
    var timer = Timer()
    private(set) var timeLeft = Constants.timeLimit * Constants.timerPrecision
    private(set) var timerStarted = false
    private(set) var flyingBubblesCount = Constants.initialFlyingBubblesCount
    
    // Mode independent
    private let bubbleGrid: UICollectionView
    private let bubbleGridModel: BubbleGridModel
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
    }
    
    // Use up 1 bubble cannon ammo, if possible.
    // Returns a boolean representing if it is possible or not.
    func useBubbleAmmo() -> Bool {
        
        // Start timer on the first shot
        if !timerStarted {
            timerStarted = true
            self.timer = Timer.scheduledTimer(timeInterval: 1.0 / Double(Constants.timerPrecision), target: self,
                selector: #selector(timerHandle), userInfo: nil, repeats: true)
        }
        
        // Check if there is still remaining time
        guard timeLeft > 0 else {
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
        // First check if bubble in last section, if yes, auto lose.
        guard !hasBubblesInLastSection() else {
            timer.invalidate()
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
        guard isTimeUp() else {
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
        timeLeft -= 1
        
        guard isTimeUp() else {
            NotificationCenter.default.post(name: Constants.timerUpdatedUpdatedNotificationName, object: nil)
            return
        }
        
        // times up, check stuff
        timer.invalidate()
        evaluateGame()
    }
    
    private func isTimeUp() -> Bool {
        return timeLeft <= 0
    }
}
