//
//  BubbleGameStats.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 23/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import Foundation

/**
 BubbleGameStats contains useful game statistics to track the progress of the game.
 Also to be presented in the end game screen.
 */
class BubbleGameStats {
    
    // About the game
    private(set) var currentScore = Constants.initialScore
    
    // Streak - number of times in a row player shoots a bubble that removes something
    private(set) var currentStreak = Constants.initialStreak
    private(set) var maxStreak = Constants.initialStreak
    
    // Combo - total number of bubbles removed in 1 shot 
    // (includes special bubble removals, connected bubble removals, and bubbles dropped)
    private(set) var currentCombo = Constants.initialCombo
    private(set) var maxCombo = Constants.initialCombo
    
    // best chaining count
    private(set) var maxChain = Constants.initialChain
    
    // Lucky color is the color of the bubble that led to the best combo
    private(set) var luckyColor: BubbleColor?
    
    // Shots and accuracy
    private(set) var bubblesShot = Constants.initialBubblesShot
    private(set) var bubblesShotThatLeadToRemovals = Constants.initialBubblesShot
    var currentAccuracy: Double {
        guard bubblesShot != Constants.initialBubblesShot else {
            return Constants.initialAccuracy
        }
        
        return Double(bubblesShotThatLeadToRemovals) / Double(bubblesShot)
    }
    
    // Update the stats by increasing the numble of bubbles shot.
    func incrementBubblesShot() {
        bubblesShot += 1
    }
    
    // Updates the stats with the knowledge that the latest shot was a failed shot
    // and did not remove any bubbles.
    func updateStatsWithFailedShot() {
        currentStreak = Constants.resetValue
        currentCombo = Constants.resetValue
    }
    
    // Updates the stats with the knowledge that the latest shot was a successful
    // shot and remove at non-zero number of bubble.
    func updateStatsWithSuccessfulShot(removalCount: Int, chainCount: Int,
        with coloredBubble: ColoredBubble) {
        
        // update current information
        currentCombo = removalCount
        bubblesShotThatLeadToRemovals += 1
        currentStreak += 1
        
        // update max info if necessary
        if currentStreak > maxStreak {
            maxStreak = currentStreak
        }
        
        if currentCombo > maxCombo {
            maxCombo = currentCombo
            luckyColor = coloredBubble.color
        }
        
        if chainCount > maxChain {
            maxChain = chainCount
        }
        
        // update the total score
        let removalScore = removalCount * Constants.scorePerRemoval
        let chainCountBonus = Double(chainCount) * Constants.scoreMultiplierPerChain
        let streakBonus = Double(currentStreak) * Constants.scoreMultiplierPerStreak
        
        currentScore += Double(removalScore) * (Constants.baseValue + chainCountBonus + streakBonus)
        
        // update streak only after updating score
        currentStreak += 1
    }
}
