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
    
    enum GameOutcome {
        case Win
        case Lose
        case InProgress
    }
    
    // About the game
    private(set) var currentScore = 0
    private(set) var gameOutcome = GameOutcome.InProgress
    
    // Streak - number of times in a row player shoots a bubble that removes something
    private(set) var currentStreak = 0
    private(set) var maxStreak = 0
    
    // Combo - total number of bubbles removed in 1 shot 
    // (includes special bubble removals, connected bubble removals, and bubbles dropped)
    private(set) var currentCombo = 0
    private(set) var bestCombo = 0
    
    // Lucky color is the color of the bubble that led to the best combo
    private(set) var luckyColor: BubbleColor?
    
    // Shots and accuracy
    private(set) var bubblesShot = 0
    private(set) var bubblesShotThatLeadToRemovals = 0
    var currentAccuracy: Double {
        guard bubblesShot != 0 else {
            return 0.0
        }
        
        return Double(bubblesShotThatLeadToRemovals) / Double(bubblesShot)
    }
}
