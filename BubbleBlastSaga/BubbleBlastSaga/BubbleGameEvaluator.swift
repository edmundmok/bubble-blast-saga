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
    private var timerStarted = false
    private(set) var shotsLeft: Int?
    private(set) var flyingBubbles = 0
    
    // Mode independent
    private let bubbleGrid: UICollectionView
    private let bubbleGridModel: BubbleGridModel
    
    init(gameMode: BubbleGameMode, bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.gameMode = gameMode
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        
        switch gameMode {
        case .LimitedShots:
            self.shotsLeft = 20
        case .LimitedTime:
            self.timeLeft = 5
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
            guard let remainingAmmo = shotsLeft else {
                return true
            }
            
            guard remainingAmmo > 0 else {
                return false
            }
            
            shotsLeft = remainingAmmo - 1
            flyingBubbles += 1
            return true
            
        case .LimitedTime:
            fallthrough
        case .Multiplayer:
            // start time on the first shot
            if !timerStarted {
                timerStarted = true
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandle), userInfo: nil, repeats: true)
            }
            
            guard let remainingTime = timeLeft else {
                return true
            }
            
            guard remainingTime > 0 else {
                return false
            }
            
            flyingBubbles += 1
            return true
        default:
            return true
        }
        
    }
    
    func updateFlyingBubbleLanded() {
        flyingBubbles -= 1
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
            // lose the game
            NotificationCenter.default.post(name: .init("GameLost"), object: nil)
            return
        }

        // Then check based on ammo.
        // If no ammo left, check if bubbles still exist
        // If yes, then game is lost. Otherwise, game is won.
        guard flyingBubbles == 0 else {
            // some ammo left, just return
            return
        }
        
        // no ammo left
        let remainingCount = bubbleGridModel.getIndexPathOfBubblesInGrid().count
        
        guard remainingCount > 0 else {
            // Remaining count == 0 (game won!)
            NotificationCenter.default.post(name: .init("GameWon"), object: nil)
            return
        }
        
        // Remaining count > 0 (game lost if ammo gone!)
        guard let remainingAmmo = shotsLeft, remainingAmmo == 0 else {
            return
        }
        
        NotificationCenter.default.post(name: .init("GameLost"), object: nil)
    }
    
    // Evaluates the current state of the game based on limited time mode
    private func evaluateGameForLimitedTime() {
        // First check if bubble in last section, if yes, auto lose.
        guard !hasBubblesInLastSection() else {
            // lose the game
            timer.invalidate()
            NotificationCenter.default.post(name: .init("GameLost"), object: nil)
            return
        }
        
        guard flyingBubbles == 0 else {
            return
        }
        
        // no ammo left
        let remainingCount = bubbleGridModel.getIndexPathOfBubblesInGrid().count
        
        guard remainingCount > 0 else {
            // Remaining count == 0 (game won!)
            timer.invalidate()
            NotificationCenter.default.post(name: .init("GameWon"), object: nil)
            return
        }
        
        // Remaining count > 0 (game lost if times up!)
        guard let remainingTime = timeLeft, remainingTime == 0 else {
            return
        }
        
        timer.invalidate()
        NotificationCenter.default.post(name: .init("GameLost"), object: nil)
    }
    
    private func hasBubblesInLastSection() -> Bool {
        let lastSectionIndexPaths = BubbleGameUtility.getIndexPathsForBottomSection(of: bubbleGridModel)
        
        for indexPath in lastSectionIndexPaths {
            // check if thre exists a bubble inside
            
            guard let _ = bubbleGridModel.getGameBubble(at: indexPath) else {
                continue
            }
            
            return true
        }
        
        return false
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
