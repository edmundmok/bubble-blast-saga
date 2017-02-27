//
//  BubbleGameHintMockHelper.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 27/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import PhysicsEngine

class BubbleGameHintMockHelper {
    
    private weak var bubbleGrid: UICollectionView!
    private weak var bubbleGridModel: BubbleGridModel!
    
    private let mockGameEngine: GameEngine
    private let mockBubbleGameAnimator: BubbleGameAnimator
    private let mockBubbleGameStats: BubbleGameStats
    private let mockBubbleGameEvaluator: BubbleGameEvaluator
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.bubbleGrid = bubbleGrid
        self.bubbleGridModel = bubbleGridModel
        
        let mockCanvas = UIView()
        let mockGameSettings = GameSettings()
        let mockRenderer = Renderer(canvas: mockCanvas)
        
        self.mockGameEngine = GameEngine(physicsEngine: PhysicsEngine(), renderer: mockRenderer,
            gameSettings: mockGameSettings)
        self.mockBubbleGameAnimator = BubbleGameAnimator(gameArea: mockCanvas, renderer: mockRenderer,
            bubbleGrid: bubbleGrid)
        self.mockBubbleGameStats = BubbleGameStats()
        self.mockBubbleGameEvaluator = BubbleGameEvaluator(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
    }
    
    func getLogicSimulator(for modelCopy: BubbleGridModel) -> BubbleGameLogic {
        return BubbleGameLogic(bubbleGrid: bubbleGrid, bubbleGridModel: modelCopy,
            gameEngine: mockGameEngine, bubbleGameAnimator: mockBubbleGameAnimator,
            bubbleGameStats: mockBubbleGameStats, bubbleGameEvaluator: mockBubbleGameEvaluator)
    }
    
}
