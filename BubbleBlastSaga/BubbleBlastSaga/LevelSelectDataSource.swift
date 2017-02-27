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
        savedLevels.dataSource = self
        
        NotificationCenter.default.addObserver(forName: Constants.newHighscoreNotificationName,
            object: nil, queue: nil) { [weak self] _ in
            
            self?.handleNewHighscore()
        }
    }
    
    fileprivate func getNumberOfSections() -> Int {
        let count = savedLevelsModel.savedLevels.count
        let remainder = count % Constants.levelsPerSection
        
        guard remainder == 0 else {
            return count / Constants.levelsPerSection + Constants.additionalLevelForOddRow
        }
        
        return count / Constants.levelsPerSection
    }
    
    fileprivate func handleNewHighscore() {
        savedLevels.reloadData()
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
            return UICollectionViewCell()
        }
        
        levelSelectCell.layer.cornerRadius = cell.frame.width / Constants.levelSelectCellCornerMultiplier
        levelSelectCell.layer.masksToBounds = true
        
        let width = cell.frame.width
        let height = width * Constants.levelSelectCellAspectRatio
        
        levelSelectCell.levelImage.frame.size.width = width
        levelSelectCell.levelImage.frame.size.height = height
        
        let index = indexPath.section * Constants.levelsPerSection + indexPath.row
        
        let levelName = savedLevelsModel.savedLevels[index]
        
        // Get the URL of the Documents Directory
        let documentDirectory = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Get the URL for a file in the Documents Directory
        let fileURL = documentDirectory
            .appendingPathComponent(levelName)
            .appendingPathExtension(Constants.pngExtension)
        
        guard let imageData = NSData(contentsOf: fileURL) as? Data,
            let image = UIImage(data: imageData) else {
                return UICollectionViewCell()
        }
        
        // Get the URL for a file in the Documents Directory
        let highScoreFileURL =  documentDirectory.appendingPathComponent(levelName).appendingPathExtension("plist")
        
        let levelInfo = NSMutableDictionary(contentsOf: highScoreFileURL) ?? NSMutableDictionary()
        
        let highScore = levelInfo.object(forKey: NSString(string: "score")) as? Int ?? 0
        
        levelSelectCell.highScore.text = String(highScore)
        
        levelSelectCell.levelImage.clipsToBounds = true
        levelSelectCell.levelImage.image = image
        levelSelectCell.levelImage.alpha = Constants.levelSelectImageAlpha
        levelSelectCell.levelName.text = levelName
        
        levelSelectCell.deleteButton.indexPath = indexPath
        levelSelectCell.playLoadButton.indexPath = indexPath

        levelSelectCell.deleteButton.addTarget(self, action: #selector(handleDeleteLevel(_:)),
            for: .touchUpInside)
        levelSelectCell.playLoadButton.addTarget(self, action: #selector(handlePlayLoadLevel(_:)),
            for: .touchUpInside)
        
        return cell
    }
    
    @objc private func handleDeleteLevel(_ sender: UIButton) {
        
        guard let indexPathToDelete = (sender as? LevelSelectDeleteButton)?.indexPath else {
            return
        }
        
        levelSelectViewController?.deleteLevel(at: indexPathToDelete)
    }
    
    @objc private func handlePlayLoadLevel(_ sender: UIButton) {
        
        guard let indexPathToLoad = (sender as? LevelSelectPlayLoadButton)?.indexPath else {
            return
        }
        
        levelSelectViewController?.playLoadLevel(at: indexPathToLoad)
    }
}
