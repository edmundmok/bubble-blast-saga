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
    
    private var levelSelectDataSource: LevelSelectDataSource?
    private var levelSelectDelegate: LevelSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.levelSelectDataSource = LevelSelectDataSource(savedLevels: savedLevels, savedLevelsModel: savedLevelsModel, levelSelectViewController: self)
        self.levelSelectDelegate = LevelSelectDelegate(savedLevels: savedLevels, savedLevelsModel: savedLevelsModel)
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
    
    func deleteLevel(at indexPath: IndexPath) {
        let index = indexPath.section * 2 + indexPath.row
        
        let deleteAlertTitle = "Confirm delete?"
        let deleteAlertMessage = "The level will be lost forever."
        
        // confirm delete
        let deleteAlert = UIAlertController(title: deleteAlertTitle, message: deleteAlertMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] (_) -> Void in
            
            // delete the level
            self?.savedLevelsModel.deleteLevelAt(index: index)
            self?.savedLevels.reloadData()
        }
        
        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func playLoadLevel(at indexPath: IndexPath) {
        let index = indexPath.section * 2 + indexPath.row
        let levelName = savedLevelsModel.savedLevels[index]
        
        // check if we load to a level designer
        // OR just start playing this level
        
        // First get the navigation controller
        guard let navController = self.navigationController,
            navController.viewControllers.count >= 2 else {
            // Impossible not to have a navigation controller, or at least 2 view controllers
            // in the navigation controller
            return
        }
        
        // this is safe because we checked before
        let parentVC = navController.viewControllers[navController.viewControllers.count - 2]
        
        switch parentVC {
        case is LevelDesignerViewController:
            // if is level designer vc, that is where we came from, need to unwind back
            self.performSegue(withIdentifier: "loadToLevelDesigner", sender: levelName)
        case is MainMenuViewController:
            // if is main menu, segue to a new game view
            self.performSegue(withIdentifier: "loadToGame", sender: levelName)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadToLevelDesigner" {

            guard let levelName = sender as? String,
                let levelDesignerVC = segue.destination as? LevelDesignerViewController else {
                return
            }
            
            levelDesignerVC.loadBubbleGridModelFromFile(name: levelName)
            
        } else if segue.identifier == "loadToGame" {
            
            guard let levelName = sender as? String,
                let gameVC = segue.destination as? GameViewController else {
                return
            }
            
            let bubbleGridModel = BubbleGridModelManager(numSections: 12, numRows: 12)
            bubbleGridModel.load(from: levelName)
            
            gameVC.bubbleGridModel = bubbleGridModel
        } else {
            return
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
