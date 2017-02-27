//
//  LevelSelectDataSource.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 This class is a helper data source class that implements the
 appropriate UICollectionViewDataSource functions for
 the collection view in the level selection screen.
 */
class LevelSelectDataSource: NSObject {
    
    fileprivate let savedLevelsModel: SavedLevelsModel
    fileprivate let savedLevels: UICollectionView
    weak fileprivate var levelSelectViewController: LevelSelectViewController?
    
    init(savedLevels: UICollectionView, savedLevelsModel: SavedLevelsModel, levelSelectViewController: LevelSelectViewController) {
        self.savedLevelsModel = savedLevelsModel
        self.savedLevels = savedLevels
        self.levelSelectViewController = levelSelectViewController
        super.init()
        
        // Set delegates
        savedLevels.dataSource = self
        
        // Register observers
        registerObservers()
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(forName: Constants.newHighscoreNotification,
            object: nil, queue: nil) { [weak self] _ in
            
            self?.handleNewHighscore()
        }
    }
    
    fileprivate func handleNewHighscore() {
        savedLevels.reloadData()
    }
    
    fileprivate func getNumberOfSections() -> Int {
        let count = savedLevelsModel.savedLevels.count
        let remainder = count % Constants.levelsPerSection
        
        guard remainder == 0 else {
            return count / Constants.levelsPerSection + Constants.additionalLevelForOddRow
        }
        
        return count / Constants.levelsPerSection
    }
}

// MARK: UICollectionViewDataSource
extension LevelSelectDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // check if last section
        guard section == getNumberOfSections() - 1 else {
            // not last section
            return Constants.levelsPerSection
        }
        
        return savedLevelsModel.savedLevels.count % Constants.levelsPerSection == 0
            ? Constants.levelsPerSection
            : Constants.levelsPerSection - Constants.additionalLevelForOddRow
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Constants.levelSelectReuseIdentifier, for: indexPath)
        
        guard let levelSelectCell = cell as? LevelSelectCell else {
            return cell
        }
        
        // Set up cell info
        levelSelectCell.setStyle()
        levelSelectCell.set(indexPath: indexPath)
        
        let index = indexPath.section * Constants.levelsPerSection + indexPath.row
        
        let levelName = savedLevelsModel.savedLevels[index]
        
        // Get the URL for a file in the Documents Directory
        let imageURL = FileUtility.getFileURL(for: levelName, and: Constants.pngExtension)
        
        guard let imageData = NSData(contentsOf: imageURL) as? Data,
            let image = UIImage(data: imageData) else {
                return UICollectionViewCell()
        }
        
        // Get the URL for a file in the Documents Directory
        let levelInfoURL = FileUtility.getFileURL(for: levelName, and: Constants.plistExtension)
        
        let levelInfo = NSMutableDictionary(contentsOf: levelInfoURL) ?? NSMutableDictionary()
        
        let highScore = levelInfo.object(forKey: Constants.highscoreProperty) as? Int
            ?? Constants.defaultScore
        
        // Set display values
        levelSelectCell.highScore.text = String(highScore)
        levelSelectCell.levelImage.image = image
        levelSelectCell.levelName.text = levelName
        
        // Setup cell buttons
        levelSelectCell.deleteButton.addTarget(self, action: #selector(handleDeleteLevel(_:)),
            for: .touchUpInside)
        levelSelectCell.playLoadButton.addTarget(self, action: #selector(handlePlayLoadLevel(_:)),
            for: .touchUpInside)
        
        return cell
    }
    
    @objc private func handleDeleteLevel(_ sender: UIButton) {
        
        // Get the index path of the level to delete
        guard let indexPathToDelete = (sender as? LevelSelectCellButton)?.indexPath else {
            return
        }
        
        // Delete level selection
        levelSelectViewController?.deleteLevel(at: indexPathToDelete)
    }
    
    @objc private func handlePlayLoadLevel(_ sender: UIButton) {
        
        // Get the index path of the level to play or load
        guard let indexPathToLoad = (sender as? LevelSelectCellButton)?.indexPath else {
            return
        }
        
        // Play / load the level
        levelSelectViewController?.playLoadLevel(at: indexPathToLoad)
    }
}
