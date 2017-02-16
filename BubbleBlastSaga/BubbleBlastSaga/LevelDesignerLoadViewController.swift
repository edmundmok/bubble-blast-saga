//
//  LevelDesignerLoadViewController.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 30/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
import Foundation

class LevelDesignerLoadViewController: UIViewController {
    
    @IBOutlet weak var savedLevels: UITableView!
    fileprivate var savedLevelsModel: SavedLevelsModel = SavedLevelsModelManager()
    
    private var levelDesignerLoadDataSource: LevelDesignerLoadDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.levelDesignerLoadDataSource = LevelDesignerLoadDataSource(savedLevels: savedLevels, savedLevelsModel: savedLevelsModel)
    }
    
    // MARK: Editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        savedLevels.isEditing = editing
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let levelName = (sender as? UITableViewCell)?.textLabel?.text ?? ""
        
        // Ensure that it is the unwind segue by checking the destination
        guard let destinationVC = segue.destination as? LevelDesignerViewController else {
            return
        }
        
        // Request the leveldesigner view controller to load
        // the model from the specified file
        destinationVC.loadBubbleGridModelFromFile(name: levelName)
    }
}
