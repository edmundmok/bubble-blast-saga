//
//  GameViewControllerDelegate.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 This class is a helper delegate class that implements the
 appropriate UICollectionViewDelegateFlowLayout functions for
 the bubble grid CollectionView in the LevelDesigner.
 */
class GameViewControllerDelegate: NSObject {
    
    fileprivate let bubbleGridModel: BubbleGridModel
    
    init(bubbleGrid: UICollectionView, bubbleGridModel: BubbleGridModel) {
        self.bubbleGridModel = bubbleGridModel
        super.init()
        bubbleGrid.delegate = self
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GameViewControllerDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // compute some sizes based on screen size
        let diameterOfBubble = collectionView.frame.width / CGFloat(bubbleGridModel.numRowsPerEvenSection)
        
        // offset by half a bubble on the left and right of an odd row
        // use 2.001 instead of 2 here even though we want half for precision reasons
        // 2 will not work for some cases
        // 2.001 will work for most reasonable cases
        let horizontalOffset = CGFloat(diameterOfBubble / Constants.horizontalOffsetMultiplier)
        
        // vertical offset to pack sections tightly
        let verticalOffset = CGFloat(diameterOfBubble / Constants.verticalOffsetMultiplier)
        
        let oddSectionInset = UIEdgeInsetsMake(verticalOffset, horizontalOffset, verticalOffset,
            horizontalOffset)
        let evenSectionInset =  UIEdgeInsetsMake(0, 0, 0, 0)
        
        return section % 2 == 0 ? evenSectionInset : oddSectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalViewWidth = Double(collectionView.frame.width)
        let maxNumRowsPerSection = Double(bubbleGridModel.numRowsPerEvenSection)
        
        let bubbleDiameter = totalViewWidth / maxNumRowsPerSection
        return CGSize(width: bubbleDiameter, height: bubbleDiameter)
    }
}
