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
    @IBOutlet weak var trajectoryPathView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var comboLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    private var trajectoryPathLayer = TrajectoryPathLayer()
    
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
        self.view.subviews.forEach { $0.layoutIfNeeded() }
        
        // Setup the game and start the game
        
        // Create a copy of the model, so that any changes due to gameplay
        // do not affect the level designer's model
        // Plus, can reset the game state to original state easily.
        guard let modelCopy = bubbleGridModel.copy() as? BubbleGridModel else {
            return
        }
        
        bubbleGame = BubbleGame(gameSettings: GameSettings(), bubbleGridModel: modelCopy,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
        
        // Setup notification observer
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GameStatsUpdated"), object: nil, queue: nil, using: handleGameStatsUpdated)
        
        // Change cannon anchor point to the hole area
        cannon.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
        
        // Hide combo and streak labels
        comboLabel.alpha = 0
        streakLabel.alpha = 0
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
        
        // Trajectory path (aiming guide)
        self.trajectoryPathView.layer.addSublayer(trajectoryPathLayer)
        trajectoryPathLayer.setPathStyle(gameArea: gameArea)
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
            updateTrajectoryPath(sender)
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
        updateTrajectoryPath(sender)
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
        let angle = getCurrentCannonAngle()
        bubbleGame.fireBubble(from: cannon.center, at: angle)
        cannon.fireAnimation()
        
        // update image
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
    }
    
    private func updateTrajectoryPath(_ sender: UIGestureRecognizer) {
        
        let angle = getCurrentCannonAngle()
        let trajectoryPoints = bubbleGame.getTrajectoryPoints(from: cannon.center, at: angle)
        trajectoryPathLayer.drawPath(from: trajectoryPoints, start: cannon.center)
    }
    
    private func getCurrentCannonAngle() -> CGFloat {
        return atan2(cannon.transform.b, cannon.transform.a) - CGFloat(M_PI_2)
    }
    
    @IBAction func getHint(_ sender: UIButton) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let hintAngle = self.bubbleGame.getHint(from: self.cannon.center) else {
                return
            }
            
            DispatchQueue.main.sync {
                let angleChange = hintAngle + CGFloat(M_PI_2)
                self.cannon.transform = CGAffineTransform(rotationAngle: angleChange)
                
                let trajectoryPoints = self.bubbleGame.getTrajectoryPoints(from: self.cannon.center, at: hintAngle)
                self.trajectoryPathLayer.drawPath(from: trajectoryPoints, start: self.cannon.center)
                
                // update image
                self.updateCurrentCannonBubbleImage()
                self.updateNextCannonBubbleImage()
            }
        }
    }
    
    @IBAction func tempFire(_ sender: UIButton) {
        fireCannon()
    }
    
    func handleGameStatsUpdated(notification: Notification) {
        // update stats to show on screen
        scoreLabel.text = String(Int(bubbleGame.bubbleGameStats.currentScore))
        comboLabel.text = "x" + String(bubbleGame.bubbleGameStats.currentCombo) + "!"
        
        guard bubbleGame.bubbleGameStats.currentCombo > 0 else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.comboLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.8, animations: {
                self.comboLabel.alpha = 0.0
            })
        })
    }
}

// MARK: UIGestureRecognizerDelegate
extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == longPressGestureRecognizer && otherGestureRecognizer == panGestureRecognizer)
    }
}
