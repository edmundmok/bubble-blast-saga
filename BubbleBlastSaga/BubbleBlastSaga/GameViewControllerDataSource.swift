//
//  GameViewControllerDataSource.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 This class is a helper data source class that implements the
 appropriate UICollectionViewDataSource functions for
 the bubble grid CollectionView in the LevelDesigner.
 */
class GameViewControllerDataSource: NSObject {
    
    fileprivate let bubbleGridModel: BubbleGridModel
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.bubbleGridModel = bubbleGridModel
        super.init()
        bubbleGrid.dataSource = self
    }
}

// MARK: UICollectionViewDataSource
extension GameViewControllerDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return bubbleGridModel.numSections
    }
    
    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        
        return section % 2 == 1
            ? bubbleGridModel.numRowsPerOddSection
            : bubbleGridModel.numRowsPerEvenSection
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.bubbleCellIdentifier,
            for: indexPath)
        
        guard let bubbleCell = cell as? BubbleCell else {
            return cell
        }
        
        // in cases where we load a different sized grid
        // we have to resize the cells to fit the new grid
        // since the cells are reused, so resize for all cases
        // anyway for convenience
        bubbleCell.resizeCell()
        
        bubbleCell.type = bubbleGridModel.getBubbleType(at: indexPath)
        return bubbleCell
    }
}
