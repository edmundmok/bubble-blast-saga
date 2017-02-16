//
//  LevelDesignerLoadDataSource.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 This class is a helper data source class that implements the
 appropriate UITableViewDataSource functions for
 the table view in the level designer level loader.
 */
class LevelDesignerLoadDataSource: NSObject {
    
    struct Constants {
        static let loadLevelCellIdentifier = "loadLevelCell"
    }
    
    fileprivate let savedLevelsModel: SavedLevelsModel
    
    init(savedLevels: UITableView, savedLevelsModel: SavedLevelsModel) {
        self.savedLevelsModel = savedLevelsModel
        super.init()
        savedLevels.dataSource = self
    }
}

// MARK: UITableViewDataSource
extension LevelDesignerLoadDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == UITableViewCellEditingStyle.delete else {
            return
        }
        savedLevelsModel.deleteLevelAt(index: indexPath.section)
        tableView.deleteSections([indexPath.section], with: UITableViewRowAnimation.fade)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.loadLevelCellIdentifier, for: indexPath)
        cell.textLabel?.text = savedLevelsModel.savedLevels[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedLevelsModel.savedLevels.count
    }
}
