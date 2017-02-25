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
    }
    
    fileprivate func getNumberOfSections() -> Int {
        let count = savedLevelsModel.savedLevels.count
        let remainder = count % 2
        
        guard remainder == 0 else {
            return count / 2 + 1
        }
        
        return count / 2
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
            return 2
        }
        
        return savedLevelsModel.savedLevels.count % 2 == 0 ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelSelectCell", for: indexPath) as? LevelSelectCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = cell.frame.width / 15
        cell.layer.masksToBounds = true
        cell.levelImage.frame.size.width = cell.frame.width
        cell.levelImage.frame.size.height = (cell.levelImage.frame.width * 4) / 3
        
        let levelName = savedLevelsModel.savedLevels[indexPath.section * 2 + indexPath.row]
        
        // Get the URL of the Documents Directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Get the URL for a file in the Documents Directory
        let fileURL = documentDirectory.appendingPathComponent(levelName).appendingPathExtension("png")
        
        guard let imageData = NSData(contentsOf: fileURL) as? Data,
            let image = UIImage(data: imageData) else {
                return UICollectionViewCell()
        }
        
        cell.levelImage.clipsToBounds = true
        cell.levelImage.image = image
        cell.levelImage.alpha = 0.4
        cell.levelName.text = levelName
        
        cell.deleteButton.indexPath = indexPath
        cell.playLoadButton.indexPath = indexPath

        cell.deleteButton.addTarget(self, action: #selector(handleDeleteLevel(_:)), for: .touchUpInside)
        cell.playLoadButton.addTarget(self, action: #selector(handlePlayLoadLevel(_:)), for: .touchUpInside)
        
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
