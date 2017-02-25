//
//  LevelDesignerViewController.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 24/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class LevelDesignerViewController: UIViewController {
    
    // main views
    @IBOutlet weak var bubbleGrid: UICollectionView!
    
    // model
    private var bubbleGridModel: BubbleGridModel = BubbleGridModelManager(numSections: 12, numRows: 12)
    private var selectedMode = PaletteMode.BluePaletteBubble
    
    // delegates
    private var levelDesignerDataSource: LevelDesignerDataSource?
    private var levelDesignerDelegate: LevelDesignerDelegate?
    private var saveAlertController: LevelDesignerSaveAlertController!
    
    // ----------- ViewController related stuff -------------
    
    override func viewDidLoad() {
        bubbleGrid.register(BubbleCell.self, forCellWithReuseIdentifier: Constants.bubbleCellIdentifier)
        
        // set style of blue palette bubble to be selected
        setPaletteBubblesStyleToSelected(for: bluePaletteBubble)
        
        // set invalid message to hide
        invalidMessage.alpha = 0
        
        // add the save alert controller as a child
        self.saveAlertController = LevelDesignerSaveAlertController(bubbleGridModel: bubbleGridModel, bubbleGrid: bubbleGrid)
        self.addChildViewController(saveAlertController)
        
        // setup delegates
        levelDesignerDataSource = LevelDesignerDataSource(bubbleGrid: bubbleGrid, bubbleGridModel: bubbleGridModel)
        levelDesignerDelegate = LevelDesignerDelegate(bubbleGrid: bubbleGrid, bubbleGridModel: bubbleGridModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func goBackToLevelDesigner(segue: UIStoryboardSegue) {
        // do nothing; need this for unwind segue
    }
    
    // ------------- Menu Buttons -------------
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        switch sender {
        case backButton:
            handleBackButtonPressed()
        case resetButton:
            handleResetButtonPressed()
        case saveButton:
            handleSaveButtonPressed()
        default:
            return
        }
    }
    
    // Handles the back button by going back to the previous screen.
    private func handleBackButtonPressed() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Handles the reset button by resetting the bubble grid.
    private func handleResetButtonPressed() {
        bubbleGridModel.reset()
        bubbleGrid.reloadData()
    }
    
    // Handles the save button pressed by first validating the grid,
    // and if successful, present the save alert.
    private func handleSaveButtonPressed() {
        guard validateLevel() else {
            presentValidationFailAlert()
            return
        }
        
        presentSaveAlert()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Check that it is the start level segue
        guard identifier == Constants.startLevelSegue else {
            return true
        }
        
        // For this start level segue, validate the level first.
        // If validation fail, don't start the level
        guard validateLevel() else {
            presentValidationFailAlert()
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == Constants.startLevelSegue else {
            return
        }
        
        prepareToStartPlayingLevel(segue: segue)
    }
    
    private func prepareToStartPlayingLevel(segue: UIStoryboardSegue) {
        // Ensure that it is the unwind segue by checking the destination
        guard let gameViewController = segue.destination as? GameViewController else {
            return
        }
        
        // Create a copy so that the model here remains untouched
        gameViewController.bubbleGridModel = bubbleGridModel
    }
    
    // ------------- Save Alert -------------
    
    // Handles the save button by presenting an alert.
    private func presentSaveAlert() {
        saveAlertController.presentSaveAlert()
    }
    
    // Loads the bubble grid model from the given file name,
    // and refreshes the grid on the screen to match the new grid.
    func loadBubbleGridModelFromFile(name: String) {
        bubbleGridModel.load(from: name)
        bubbleGrid.reloadData()
    }
    
    // ------------- Palette Bubble Buttons -------------
    
    @IBOutlet weak var bluePaletteBubble: PaletteBubble!
    @IBOutlet weak var redPaletteBubble: PaletteBubble!
    @IBOutlet weak var orangePaletteBubble: PaletteBubble!
    @IBOutlet weak var greenPaletteBubble: PaletteBubble!
    @IBOutlet weak var indestructiblePaletteBubble: PaletteBubble!
    @IBOutlet weak var lightningPaletteBubble: PaletteBubble!
    @IBOutlet weak var bombPaletteBubble: PaletteBubble!
    @IBOutlet weak var starPaletteBubble: PaletteBubble!
    @IBOutlet weak var erasePaletteBubble: PaletteBubble!
    @IBOutlet var paletteBubbles: [PaletteBubble]!
    
    @IBAction func paletteBubblePressed(_ sender: PaletteBubble) {
        // set the selected style for the palette buttons
        setPaletteBubblesStyleToSelected(for: sender)

        // set current selection mode
        switch sender {
        case bluePaletteBubble: selectedMode = .BluePaletteBubble
        case redPaletteBubble: selectedMode = .RedPaletteBubble
        case orangePaletteBubble: selectedMode = .OrangePaletteBubble
        case greenPaletteBubble: selectedMode = .GreenPaletteBubble
        case indestructiblePaletteBubble: selectedMode = .IndestructiblePaletteBubble
        case lightningPaletteBubble: selectedMode = .LightningPaletteBubble
        case bombPaletteBubble: selectedMode = .BombPaletteBubble
        case starPaletteBubble: selectedMode = .StarPaletteBubble
        case erasePaletteBubble: selectedMode = .ErasePaletteButton
        default: return
        }
    }
    
    // Sets the styles of all palette bubbles to be unselected except for the given palette bubble.
    private func setPaletteBubblesStyleToSelected(for paletteBubble: PaletteBubble) {
        paletteBubbles.forEach { $0.isSelected = false }
        paletteBubble.isSelected = true
    }
    
    // ------------- Gesture handlers -------------
    
    /// Handles a tap gesture on the bubble grid.
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // Get a valid index path for the current long press location, else do nothing if invalid
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }
        
        // Ensure that the cell at the indexpath must be a BubbleCell
        guard let cell = bubbleGrid.cellForItem(at: indexPath) as? BubbleCell else {
            return
        }
        
        // Tapping an empty cell - set according to chosen palette mode
        guard cell.type != .Empty else {
            setAccordingToCurrentPaletteMode(cell: cell, at: indexPath)
            return
        }
        
        // Tapping a filled cell while on erase mode - empties current cell
        guard selectedMode != .ErasePaletteButton else {
            eraseBubble(for: cell, at: indexPath)
            return
        }
        
        // Tapping a filled cell while on any other palette mode
        // toggles the filled cell color
        toggleBubble(for: cell, at: indexPath)
    }
    
    /// Handles a pan gesture on the bubble grid.
    /// Replaces the bubble cells that are in the path
    /// of the gesture with ones that correspond to the current palette mode.
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        // Get a valid index path for the current long press location, else do nothing if invalid
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }
        
        // Ensure that the cell at the indexpath must be a BubbleCell
        guard let cell = bubbleGrid.cellForItem(at: indexPath) as? BubbleCell else {
            return
        }
        
        // Update the current bubble according to the current palette mode
        setAccordingToCurrentPaletteMode(cell: cell, at: indexPath)
    }

    /// Handles a long press on the bubble grid.
    /// Removes the bubble in a filled cell.
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        // Get a valid index path for the current long press location, else do nothing if invalid
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }
        
        // Ensure that the cell at the indexpath must be a BubbleCell
        guard let cell = bubbleGrid.cellForItem(at: indexPath) as? BubbleCell else {
            return
        }
        
        eraseBubble(for: cell, at: indexPath)
    }
    
    // Erases the bubble at the given cell and index path from the view and model respectively.
    private func eraseBubble(for cell: BubbleCell, at indexPath: IndexPath) {
        cell.type = .Empty
        bubbleGridModel.set(bubbleType: .Empty, at: indexPath)
    }
    
    // Returns the bubble type that corresponds to the current selected palette mode, if possible.
    // Otherwise, returns nil.
    private func getBubbleTypeCorrespondingToCurrentPaletteMode() -> BubbleType {
        switch selectedMode {
        case .BluePaletteBubble: return .BlueBubble
        case .RedPaletteBubble: return .RedBubble
        case .OrangePaletteBubble: return .OrangeBubble
        case .GreenPaletteBubble: return .GreenBubble
        case .IndestructiblePaletteBubble: return .IndestructibleBubble
        case .LightningPaletteBubble: return .LightningBubble
        case .BombPaletteBubble: return .BombBubble
        case .StarPaletteBubble: return .StarBubble
        case .ErasePaletteButton: return .Empty
        }
    }
    
    // Sets the given view bubblecell and game bubble at the indexpath of the model
    // to a game bubble that corresponds to the current palette mode.
    private func setAccordingToCurrentPaletteMode(cell: BubbleCell, at indexPath: IndexPath) {
        // if no corresponding bubble to the palette means erase
        let bubbleType = getBubbleTypeCorrespondingToCurrentPaletteMode()
        
        bubbleGridModel.set(bubbleType: bubbleType, at: indexPath)
        cell.type = bubbleType
    }
    
    // Toggles the given bubble cell and indexpath at the view and model respectively.
    private func toggleBubble(for cell: BubbleCell, at indexPath: IndexPath) {
        let bubbleType = cell.type
        let nextTypeToCycleTo = bubbleType.next
        
        cell.type = nextTypeToCycleTo
        bubbleGridModel.set(bubbleType: nextTypeToCycleTo, at: indexPath)
    }
    
    // Validates the level.
    // A valid level must have at least one bubble in the grid, and should not have any
    // free hanging bubbles floating in the air.
    // Also, it should not have any bubbles in the last section of the grid.
    private func validateLevel() -> Bool {
        // check last section
        let indexPathsOfLastSection = BubbleGameUtility.getIndexPathsForBottomSection(of: bubbleGridModel)
        for indexPathOfLastSection in indexPathsOfLastSection {
            guard bubbleGridModel.getBubbleType(at: indexPathOfLastSection) == .Empty else {
                // validation fail
                return false
            }
            continue
        }
        
        // Check has at least one bubble
        guard bubbleGridModel.getIndexPathOfBubblesInGrid().count > 0 else {
            return false
        }
        
        // Check for floating bubbles
        guard BubbleGameUtility.getFloatingBubblesIndexPath(of: bubbleGridModel).count == 0 else {
            return false
        }
        
        return true
    }
    
    @IBOutlet weak var invalidMessage: UILabel!
    private func presentValidationFailAlert() {
        UIView.animate(withDuration: 0.5, animations: {
            self.invalidMessage.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 5) {
                self.invalidMessage.alpha = 0
            }
        }
    }
}
