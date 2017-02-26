//
//  LevelSelectDelegate.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class LevelSelectDelegate: NSObject {
    
    fileprivate let savedLevelsModel: SavedLevelsModel
    
    init(savedLevels: UICollectionView, savedLevelsModel: SavedLevelsModel) {
        self.savedLevelsModel = savedLevelsModel
        super.init()
        savedLevels.delegate = self
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension LevelSelectDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.levelSelectMinLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.levelSelectMinInteritemSpacing
    }
}
