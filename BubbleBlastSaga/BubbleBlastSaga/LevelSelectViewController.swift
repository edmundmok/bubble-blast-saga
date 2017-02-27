//
//  LevelSelectViewController.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class LevelSelectViewController: UIViewController {

    fileprivate var savedLevelsModel: SavedLevelsModel = SavedLevelsModelManager()
    @IBOutlet weak var savedLevels: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    private var levelSelectDataSource: LevelSelectDataSource?
    private var levelSelectDelegate: LevelSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.levelSelectDataSource = LevelSelectDataSource(savedLevels: savedLevels,
            savedLevelsModel: savedLevelsModel, levelSelectViewController: self)
        self.levelSelectDelegate = LevelSelectDelegate(savedLevels: savedLevels,
            savedLevelsModel: savedLevelsModel)
        
        backButton.layer.borderColor = backButton.titleLabel?.textColor.cgColor
        backButton.layer.borderWidth = Constants.gameMenuButtonsBorderWidth
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func getIndex(from indexPath: IndexPath) -> Int {
        return indexPath.section * Constants.levelsPerSection + indexPath.row
    }
    
    func deleteLevel(at indexPath: IndexPath) {
        let index = getIndex(from: indexPath)
        
        let deleteAlertTitle = Constants.deleteAlertTitle
        let deleteAlertMessage = Constants.deleteAlertMessage
        
        // confirm delete
        let deleteAlert = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .cancel)
        let deleteAction = UIAlertAction(title: Constants.deleteTitle, style: .default) {
            [weak self] (_) -> Void in
            
            // delete the level
            self?.savedLevelsModel.deleteLevelAt(index: index)
            self?.savedLevels.reloadData()
        }
        
        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func playLoadLevel(at indexPath: IndexPath) {
        let index = getIndex(from: indexPath)
        let levelName = savedLevelsModel.savedLevels[index]
        
        // check if we load to a level designer
        // OR just start playing this level
        
        // First get the navigation controller
        guard let navController = self.navigationController,
            navController.viewControllers.count >= Constants.minViewControllerCount else {
            // Impossible not to have a navigation controller, or at least 2 view controllers
            // in the navigation controller
            return
        }
        
        // this is safe because we checked before
        let parentIndex = navController.viewControllers.count - Constants.minViewControllerCount
        let parentVC = navController.viewControllers[parentIndex]
        
        switch parentVC {
        case is LevelDesignerViewController:
            // if is level designer vc, that is where we came from, need to unwind back
            performSegue(withIdentifier: Constants.loadToLevelDesignerSegue, sender: levelName)
        case is MainMenuViewController:
            // if is main menu, segue to a new game view
            performSegue(withIdentifier: Constants.loadToGameSegue, sender: levelName)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.loadToLevelDesignerSegue {
            prepareForSegueToLevelDesigner(with: segue, sender: sender)
            
        } else if segue.identifier == Constants.loadToGameSegue {
            prepareForSegueToGame(with: segue, sender: sender)

        } else {
            return
        }
    }
    
    private func prepareForSegueToLevelDesigner(with segue: UIStoryboardSegue, sender: Any?) {
        guard let levelName = sender as? String,
            let levelDesignerVC = segue.destination as? LevelDesignerViewController else {
                return
        }
        
        // Inform level designer to load the file
        levelDesignerVC.loadBubbleGridModelFromFile(name: levelName)
    }
    
    private func prepareForSegueToGame(with segue: UIStoryboardSegue, sender: Any?) {
        guard let levelName = sender as? String,
            let gameVC = segue.destination as? GameViewController else {
                return
        }
        
        // Prepare to load the requested level model
        let bubbleGridModel = BubbleGridModelManager(numSections: Constants.defaultNumSections,
            numRows: Constants.defaultNumRows)
        bubbleGridModel.load(from: levelName)
        
        // Hand it to the game for loading into actual game engine
        gameVC.bubbleGridModel = bubbleGridModel
    }

}
