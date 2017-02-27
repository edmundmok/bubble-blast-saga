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
                        
        configureGestureRecognizers()
        
        // Request to layout and adjust constraints for game setup
        view.subviews.forEach { $0.layoutIfNeeded() }
        
        startGame()
        setupNotificationObservers()
        configureGameUI()
    }
    
    private func configureGestureRecognizers() {
        panGestureRecognizer.delegate = self
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = Constants.minimumLongPressDuration
    }
    
    private func startGame() {
        // Create a copy of the model, so that any changes due to gameplay
        // do not affect the level designer's model
        // Plus, can reset the game state to original state easily.
        guard let modelCopy = bubbleGridModel.copy() as? BubbleGridModel else {
            return
        }
        
        bubbleGame = BubbleGame(gameSettings: GameSettings(), bubbleGridModel: modelCopy,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(forName: Constants.timerUpdatedUpdatedNotificationName,
            object: nil, queue: nil) { [weak self] _ in
            
            self?.handleTimerUpdated()
        }
        
        NotificationCenter.default.addObserver(forName: Constants.gameWonNotificationName,
            object: nil, queue: nil) { [weak self] _ in
            
            self?.handleGameWon()
        }
        
        NotificationCenter.default.addObserver(forName: Constants.gameLostNotificationName,
            object: nil, queue: nil) { [weak self] _ in
           
            self?.handleGameLost()
        }
        
    }
    
    private func configureGameUI() {
        // Change cannon anchor point to the hole area
        cannon.layer.anchorPoint = CGPoint(x: Constants.cannonAnchorX, y: Constants.cannonAnchorY)
        
        // border around buttons
        gameMenuButtons.forEach {
            $0.layer.borderWidth = Constants.gameMenuButtonsBorderWidth
            $0.layer.borderColor = $0.titleLabel?.textColor.cgColor
        }
        
        // Update timer
        scoreLabel.text = String(Constants.timerFinalValue)
        
        // Hide end screen info
        gameOutcome.alpha = Constants.hiddenAlpha
        endGameStats.forEach { $0.alpha = Constants.hiddenAlpha }
        
        // save score label, retry and back button position so that we can get it back later
        originalScoreLocation = scoreLabel.center
        originalBackLocation = backButton.center
        originalRetryLocation = retryButton.center
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
        
        // adjust the swap button onto the next bubble view
        swapButton.center = nextBubbleView.center
        
        // Trajectory path (aiming guide)
        trajectoryPathView.layer.addSublayer(trajectoryPathLayer)
        trajectoryPathLayer.setPathStyle(gameArea: gameArea)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func getStandardBubbleSize() -> CGSize {
        return bubbleGrid.visibleCells[0].frame.size
    }
    
    private func updateCurrentCannonBubbleImage() {
        let currentBubbleWidth = getStandardBubbleSize().width
            * Constants.currentBubbleViewSizeMultiplier
        let currentBubbleHeight = getStandardBubbleSize().height
            * Constants.currentBubbleViewSizeMultiplier
        
        currentBubbleView.frame.size = CGSize(width: currentBubbleWidth,
            height: currentBubbleHeight)
        
        currentBubbleView.center = CGPoint(x: cannon.center.x,
            y: cannon.center.y + cannon.frame.height * Constants.currentBubbleViewYMultiplier)
        
        let currentBubble = bubbleGame.bubbleCannon.currentBubble
        let currentBubbleImage = BubbleGameUtility.getBubbleImage(for: currentBubble)
        currentBubbleView.image = currentBubbleImage.image
    }
    
    private func updateNextCannonBubbleImage() {
        nextBubbleView.frame.size = getStandardBubbleSize()
        let nextBubble = bubbleGame.bubbleCannon.nextBubble
        let nextBubbleImage = BubbleGameUtility.getBubbleImage(for: nextBubble)
        
        UIView.animate(withDuration: Constants.updateNextBubbleFadeDuration) {
            self.nextBubbleView.image = nextBubbleImage.image
        }
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
            return
        }
        
        animateForCannonFire()
    }
    
    // Returns an animatable replica of the current bubble
    private func generateAnimatableCurrentBubble() -> UIImageView {
        let animatableCurrentBubble = UIImageView()
        animatableCurrentBubble.image = currentBubbleView.image
        animatableCurrentBubble.frame.size = currentBubbleView.frame.size
        animatableCurrentBubble.center = currentBubbleView.center
        return animatableCurrentBubble
    }
    
    // Returns an animatable replica of the next bubble
    private func generateAnimatableNextBubble() -> UIImageView {
        let animatableNextBubble = UIImageView()
        animatableNextBubble.image = nextBubbleView.image
        animatableNextBubble.frame.size = nextBubbleView.frame.size
        animatableNextBubble.center = nextBubbleView.center
        return animatableNextBubble
    }
    
    private func animateForCannonFire() {
        cannon.fireAnimation()
        
        // Animate transition from next cannon bubble to current cannon bubble
        // First, create a replica of the current and move it just out of the hole
        let animatableCurrentBubbleView = generateAnimatableCurrentBubble()
        let animatableNextBubbleView = generateAnimatableNextBubble()
        
        // Add the generated view before remove current bubble
        gameArea.addSubview(animatableCurrentBubbleView)
        currentBubbleView.image = nil
        
        // Move the fake current bubble up a little
        UIView.animate(withDuration: Constants.currentBubbleMoveUpDuration, animations: {
            animatableCurrentBubbleView.frame.offsetBy(dx: Constants.currentBubbleXOffset,
                dy: Constants.currentBubbleYOffsetMultiplier * animatableCurrentBubbleView.frame.size.height)
        }) { _ in
            // Remove the fake current bubble once out of sight
            animatableCurrentBubbleView.removeFromSuperview()
            
            // Move the next bubble to the cannon for "reloading"
            self.gameArea.addSubview(animatableNextBubbleView)
            self.nextBubbleView.image = nil
            
            UIView.animate(withDuration: Constants.reloadDuration, animations: {
                animatableNextBubbleView.center = self.currentBubbleView.center
            }) { _ in
                
                // Display the "current" and remove the fake current bubble
                self.updateCurrentCannonBubbleImage()
                animatableNextBubbleView.removeFromSuperview()
                
                // Fade in the new next bubble
                self.updateNextCannonBubbleImage()
            }
            
        }
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
                
                let trajectoryPoints = self.bubbleGame.getTrajectoryPoints(from: self.cannon.center,
                    at: hintAngle)
                self.trajectoryPathLayer.drawPath(from: trajectoryPoints, start: self.cannon.center)
                
                // update image
                self.updateCurrentCannonBubbleImage()
                self.updateNextCannonBubbleImage()
            }
        }
    }
    
    private func handleTimerUpdated() {
        scoreLabel.text = String(bubbleGame.bubbleGameEvaluator.timeLeft)
    }
    
    private func handleGameWon() {
        // pause the game
        bubbleGame.pauseGame()
        
        // render end screen
        renderEndScreen(outcome: .Win)
        
        // update highscore on win
        updateHighscore()
    }
    
    private func handleGameLost() {
        // pause the game
        bubbleGame.pauseGame()

        // render end screen
        renderEndScreen(outcome: .Lose)
    }
    
    private func updateHighscore() {
        // check if the current grid was a loaded one
        guard let levelName = bubbleGridModel.loadedFileName else {
            return
        }
        
        // Get the URL for a file in the Documents Directory
        let levelInfoURL = FileUtility.getFileURL(for: levelName, and: "plist")
            
        
        let levelInfo = NSMutableDictionary(contentsOf: levelInfoURL) ?? NSMutableDictionary()
        
        let score = bubbleGame.bubbleGameEvaluator.timeLeft
        guard let prevScore = levelInfo.object(forKey: NSString(string: "score")) as? Int else {
            // no prev high score
            NotificationCenter.default.post(name: Constants.newHighscoreNotificationName, object: nil)
            levelInfo.setObject(score, forKey: NSString(string: "score"))
            levelInfo.write(to: levelInfoURL, atomically: true)
            return
        }
        
        guard score > prevScore else {
            return
        }
        
        NotificationCenter.default.post(name: Constants.newHighscoreNotificationName, object: nil)
        levelInfo.setObject(score, forKey: NSString(string: "score"))
        levelInfo.write(to: levelInfoURL, atomically: true)

    }

    @IBAction func handleBack(_ sender: UIButton) {
        // Invalidate the timer in case game was still running
        bubbleGame.bubbleGameEvaluator.timer.invalidate()
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRetry(_ sender: UIButton) {
        // Invalidate the timer for the current game
        bubbleGame.bubbleGameEvaluator.timer.invalidate()
        
        // end the current game
        bubbleGame.endGame()
        
        hideEndScreen()
        
        // start a new game
        startGame()
        
        // Setup the image for the current cannon bubble
        updateCurrentCannonBubbleImage()
        updateNextCannonBubbleImage()
    }
    
    private func hideEndScreen() {
        // disable buttons while animating
        retryButton.isEnabled = false
        backButton.isEnabled = false
        
        UIView.animate(withDuration: Constants.hideGameStatsDuration, animations: {
            // hide the end game stats
            self.endGameStats.forEach { $0.alpha = Constants.hiddenAlpha }
        }) { _ in
            
            UIView.animate(withDuration: Constants.moveUIBackDuration, animations: {
                
                guard let retryLocation = self.originalRetryLocation,
                    let backLocation = self.originalBackLocation,
                    let scoreLocation = self.originalScoreLocation else {
                        
                        return
                }
                
                // move ui items back to their game positions
                self.gameOutcome.alpha = Constants.hiddenAlpha
                self.retryButton.center = retryLocation
                self.backButton.center = backLocation
                self.scoreLabel.center = scoreLocation
                
            }) { _ in
                
                UIView.animate(withDuration: Constants.redisplayUIDuration) {
                    // redisplay hidden game ui
                    self.scoreLabel.text = String(Constants.timeLimit)
                    self.gameView.alpha = Constants.shownAlpha
                    self.hintButton.alpha = Constants.shownAlpha
                    self.swapButton.alpha = Constants.shownAlpha
                    
                    self.retryButton.isEnabled = true
                    self.backButton.isEnabled = true
                }
                
            }
        }
    }
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet var gameMenuButtons: [UIButton]!
    
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
    
    private func updateEndGameStats() {
        endLuckyColorPlaceholder.text = Constants.luckyColorPrefix
            + (bubbleGame.bubbleGameStats.luckyColor?.rawValue ?? Constants.noLuckyColor)
        endBestComboPlaceholder.text = Constants.bestComboPrefix
            + String(bubbleGame.bubbleGameStats.maxCombo)
        endBestChainPlaceholder.text = Constants.bestChainPrefix
            + String(bubbleGame.bubbleGameStats.maxChain)
        endLongestStreakPlaceholder.text = Constants.bestStreakPrefix
            + String(bubbleGame.bubbleGameStats.maxStreak)
        endAccuracyPlaceholder.text = Constants.accuracyPrefix
            + String(Int(bubbleGame.bubbleGameStats.currentAccuracy * Constants.accuracyToPercentage))
            + Constants.accuracyPostfix
    }
    
    private func renderEndScreen(outcome: GameOutcome) {
        // fill up end screen details first
        if outcome == .Win {
            gameOutcome.text = Constants.winString
        } else {
            gameOutcome.text = Constants.loseString
        }
        
        updateEndGameStats()

        // disable buttons while animating
        self.retryButton.isEnabled = false
        self.backButton.isEnabled = false
        
        // compute placeholder positions
        let retryFinalCenter = endGameDetailsPlaceholder.convert(endRetryPlaceholder.center, to: view)
        let backFinalCenter = endGameDetailsPlaceholder.convert(endBackPlaceholder.center, to: view)
        let scoreFinalCenter = endGameDetailsPlaceholder.convert(endScorePlaceholder.center, to: view)
        
        // fade out existing views
        UIView.animate(withDuration: Constants.hideUIDuration, animations: {
            self.gameView.alpha = Constants.hiddenAlpha
            self.hintButton.alpha = Constants.hiddenAlpha
            self.swapButton.alpha = Constants.hiddenAlpha
        }) { _ in
            
            UIView.animate(withDuration: Constants.moveUIDuration, animations: {
                // game outcome
                self.gameOutcome.alpha = Constants.shownAlpha
                
                // move stuff that are already on screen
                self.retryButton.center = retryFinalCenter
                self.backButton.center = backFinalCenter
                self.scoreLabel.center = scoreFinalCenter
            }) { _ in
                
                UIView.animate(withDuration: Constants.showGameStatsDuration) {
                    // fade in stats
                    self.endGameStats.forEach { $0.alpha = Constants.shownAlpha }
                    self.retryButton.isEnabled = true
                    self.backButton.isEnabled = true
                }
                
                
            }
            
        }
        
    }

    private var canSwap = true
    @IBAction func handleSwap(_ sender: UIButton) {
        guard canSwap else {
            return
        }
        
        // execute swap animation
        // do not allow swap while in progress
        canSwap = false
        
        // animate transition from next cannon bubble to current cannon bubble
        
        // create a replica of the current and move it just out of the hole
        let animatableCurrentBubbleView = generateAnimatableCurrentBubble()
        
        let animatableNextBubbleView = generateAnimatableNextBubble()
        
        // adjust current bubble size to fit next bubble size
        // since it is a little smaller to fit in the cannon usually
        animatableCurrentBubbleView.frame.size = animatableNextBubbleView.frame.size
        
        // remove current bubble
        gameArea.addSubview(animatableCurrentBubbleView)
        currentBubbleView.image = nil
        
        // remove next
        gameArea.addSubview(animatableNextBubbleView)
        nextBubbleView.image = nil
        
        // swap the images
        UIView.animate(withDuration: Constants.swapDuration, animations: {
            animatableCurrentBubbleView.center = self.nextBubbleView.center
            animatableNextBubbleView.center = self.currentBubbleView.center
        }) { _ in
            self.updateCurrentCannonBubbleImage()
            self.updateNextCannonBubbleImage()
            
            animatableCurrentBubbleView.removeFromSuperview()
            animatableNextBubbleView.removeFromSuperview()
            
            self.canSwap = true
            
        }
        
        
        // swap the actual thing
        bubbleGame.bubbleCannon.swapCurrentWithNextBubble()
    }
}

// MARK: UIGestureRecognizerDelegate
extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return (gestureRecognizer == longPressGestureRecognizer
            && otherGestureRecognizer == panGestureRecognizer)
    }
}
