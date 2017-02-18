//
//  ViewController.swift
//  GameEngine
//
//  Created by Edmund Mok on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // Main views
    @IBOutlet weak var bubbleGrid: UICollectionView!
    @IBOutlet weak var cannon: CannonView!
    @IBOutlet weak var cannonBase: UIImageView!
    @IBOutlet weak var gameArea: UIView!
    @IBOutlet weak var currentBubbleView: UIImageView!
    @IBOutlet weak var nextBubbleView: UIImageView!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // BubbleGame
    private var bubbleGame: BubbleGame!
    
    // model
    var bubbleGridModel: BubbleGridModel = BubbleGridModelManager(
        numSections: Constants.bubbleGridNumSections,
        numRows: Constants.bubbleGridNumRows
    )
    
    // delegates
    private var gameViewControllerDataSource: GameViewControllerDataSource?
    private var gameViewControllerDelegate: GameViewControllerDelegate?

    override func viewDidLoad() {
        // Register collectionview cell
        bubbleGrid.register(GameBubbleCell.self, forCellWithReuseIdentifier: Constants.bubbleCellIdentifier)

        // Setup delegates
        gameViewControllerDataSource = GameViewControllerDataSource(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
        gameViewControllerDelegate = GameViewControllerDelegate(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
                        
        // Configure gestures
        panGestureRecognizer.delegate = self
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = Constants.minimumLongPressDuration
        
        // Request to layout and adjust constraints for game setup
        // gameArea.layoutIfNeeded()
        // bubbleGrid.layoutIfNeeded()
        self.view.subviews.forEach { $0.layoutIfNeeded() }
        
        // Setup the game and start the game
        bubbleGame = BubbleGame(gameSettings: GameSettings(), bubbleGridModel: bubbleGridModel,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
        
        // Change cannon anchor point to the hole area
        cannon.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
    }
    
    private func updateCurrentCannonBubbleImage() {
        // currentBubbleView.frame.size = bubbleGrid.visibleCells[0].frame.size
        currentBubbleView.frame.size = CGSize(width: bubbleGrid.visibleCells[0].frame.size.width*0.8,
            height: bubbleGrid.visibleCells[0].frame.size.height*0.8)
        
        // TODO: This thing may not work for all screen sizes
        // Bubble size should scale with the base, not the cell size.
        currentBubbleView.center = CGPoint(x: cannon.center.x, y: cannon.center.y + cannon.frame.height * 0.1)
        let currentBubble = bubbleGame.bubbleCannon.currentBubble
        let currentBubbleImage = BubbleGameUtility.getBubbleImage(for: currentBubble)
        currentBubbleView.image = currentBubbleImage.image
    }
    
    private func updateNextCannonBubbleImage() {
        nextBubbleView.frame.size = bubbleGrid.visibleCells[0].frame.size
        let nextBubble = bubbleGame.bubbleCannon.nextBubble
        let nextBubbleImage = BubbleGameUtility.getBubbleImage(for: nextBubble)
        nextBubbleView.image = nextBubbleImage.image
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        // Point at finger location on a single tap
        if sender.state == .began {
            updateCannonAngle(sender)
            return
        }
        
        // Check if the long press has ended
        guard sender.state == .ended else {
            return
        }
        
        // If long press ended, fire the bubble!
        fireCannon()
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        updateCannonAngle(sender)
    }
    
    // Update the angle of the cannon image to face the user's finger location
    private func updateCannonAngle(_ sender: UIGestureRecognizer) {
        // Calculating the new angle
        let angle = atan2(sender.location(in: view).y - cannon.center.y,
                          sender.location(in: view).x - cannon.center.x)
        
        // Find the difference between old and new angle
        let angleChange = angle + CGFloat(M_PI_2)
        // Set the cannon to move by the difference in angle so
        // it now points at the new angle
        cannon.transform = CGAffineTransform(rotationAngle: angleChange)
    }
    
    // Fires the cannon in the bubble game
    private func fireCannon() {
        let angle = atan2(cannon.transform.b, cannon.transform.a) - CGFloat(M_PI_2)
        bubbleGame.fireBubble(from: cannon.center, at: angle)
        cannon.fireAnimation()
        
        // update image
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
    }
}

// MARK: UIGestureRecognizerDelegate
extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == longPressGestureRecognizer && otherGestureRecognizer == panGestureRecognizer)
    }
}
