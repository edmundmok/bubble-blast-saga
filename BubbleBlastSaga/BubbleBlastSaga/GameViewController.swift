//
//  ViewController.swift
//  GameEngine
//
//  Created by Edmund Mok on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    enum GameOutcome {
        case Win
        case Lose
    }
    
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
    
    private var trajectoryPathLayer = TrajectoryPathLayer()
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // saved locations for score, retry and fire
    private var originalScoreLocation: CGPoint?
    private var originalBackLocation: CGPoint?
    private var originalRetryLocation: CGPoint?
    
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
        
        bubbleGame = BubbleGame(gameSettings: GameSettings(gameMode: .LimitedTime), bubbleGridModel: modelCopy,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
        
        // Setup notification observer
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GameStatsUpdated"), object: nil, queue: nil, using: handleGameStatsUpdated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GameWon"), object: nil, queue: nil, using: handleGameWon)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GameLost"), object: nil, queue: nil, using: handleGameLost)

        // Change cannon anchor point to the hole area
        cannon.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
        
        // Hide combo and streak labels
        comboLabel.alpha = 0
        gameOutcome.alpha = 0
        endGameStats.forEach{ $0.alpha = 0 }
        
        // save score label, retry and back button position so that we can get it back later
        originalScoreLocation = scoreLabel.center
        originalBackLocation = backButton.center
        originalRetryLocation = retryButton.center
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
        
        // Trajectory path (aiming guide)
        self.trajectoryPathView.layer.addSublayer(trajectoryPathLayer)
        trajectoryPathLayer.setPathStyle(gameArea: gameArea)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        let canFire = bubbleGame.fireBubble(from: cannon.center, at: angle)
        
        guard canFire else {
            // cannot fire any more bubbles
            print("cannot fire anymore")
            return
        }
        
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
    
    func handleGameWon(notification: Notification) {
        // pause the game
        bubbleGame.pauseGame()
        
        // render end screen
        renderEndScreen(outcome: .Win)
    }
    
    func handleGameLost(notification: Notification) {
        // pause the game
        bubbleGame.pauseGame()

        // render end screen
        renderEndScreen(outcome: .Lose)
    }

    @IBAction func handleBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRetry(_ sender: UIButton) {
        // refactor into hide end screen
        
        UIView.animate(withDuration: 1.0, animations: {
            self.endGameStats.forEach { $0.alpha = 0 }
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                
                guard let retryLocation = self.originalRetryLocation,
                    let backLocation = self.originalBackLocation,
                    let scoreLocation = self.originalScoreLocation else {
                        
                    return
                }
                
                self.gameOutcome.alpha = 0
                self.retryButton.center = retryLocation
                self.backButton.center = backLocation
                self.scoreLabel.center = scoreLocation
                
            }) { _ in
                
                UIView.animate(withDuration: 1.5) {
                    self.scoreLabel.text = String(0)
                    self.gameView.alpha = 1
                    self.hintButton.alpha = 1
                    self.fireHintButton.alpha = 1
                }
                
            }
        }
        
        // end the current game
        bubbleGame.endGame()
        
        // start a new game
        guard let modelCopy = bubbleGridModel.copy() as? BubbleGridModel else {
            return
        }
        
        bubbleGame = BubbleGame(gameSettings: GameSettings(gameMode: .LimitedTime), bubbleGridModel: modelCopy,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()

    }
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var fireHintButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var gameOutcome: UILabel!
    @IBOutlet weak var endGameDetailsPlaceholder: UIView!
    @IBOutlet weak var endScorePlaceholder: UIView!
    @IBOutlet weak var endBackPlaceholder: UIView!
    @IBOutlet weak var endRetryPlaceholder: UIView!
    
    @IBOutlet weak var endLuckyColorPlaceholder: UILabel!
    @IBOutlet weak var endBestComboPlaceholder: UILabel!
    @IBOutlet weak var endBestChainPlaceholder: UILabel!
    @IBOutlet weak var endLongestStreakPlaceholder: UILabel!
    @IBOutlet weak var endAccuracyPlaceholder: UILabel!
    @IBOutlet var endGameStats: [UILabel]!
    
    
    private func renderEndScreen(outcome: GameOutcome) {
        // fill up end screen details first
        if outcome == .Win {
            gameOutcome.text = "You win"
        } else {
            gameOutcome.text = "You lose"
        }
        
        // game stats
        endLuckyColorPlaceholder.text = "Your lucky color is " + (bubbleGame.bubbleGameStats.luckyColor?.rawValue ?? " no color")
        endBestComboPlaceholder.text = "Best combo: " + String(bubbleGame.bubbleGameStats.maxCombo)
        endBestChainPlaceholder.text = "Best chain: " + String(bubbleGame.bubbleGameStats.maxChain)
        endLongestStreakPlaceholder.text = "Best streak: " + String(bubbleGame.bubbleGameStats.maxStreak)
        endAccuracyPlaceholder.text = "Accuracy: " + String(Int(bubbleGame.bubbleGameStats.currentAccuracy * 100)) + " %"

        
        // fade out existing views
        UIView.animate(withDuration: 1.5, animations: {
            self.gameView.alpha = 0
            self.hintButton.alpha = 0
            self.fireHintButton.alpha = 0
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                // game outcome
                self.gameOutcome.alpha = 1
                
                // move stuff that are already on screen
                self.retryButton.center = self.endGameDetailsPlaceholder.convert(self.endRetryPlaceholder.center, to: self.view)
                self.backButton.center = self.endGameDetailsPlaceholder.convert(self.endBackPlaceholder.center, to: self.view)
                self.scoreLabel.center = self.endGameDetailsPlaceholder.convert(self.endScorePlaceholder.center, to: self.view)
            }) { _ in
                
                
                UIView.animate(withDuration: 1.0) {
                    // fade in stats
                    self.endGameStats.forEach { $0.alpha = 1 }
                }
                
                
            }
            
        }
        

        
        
    }

}

// MARK: UIGestureRecognizerDelegate
extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == longPressGestureRecognizer && otherGestureRecognizer == panGestureRecognizer)
    }
}
