//
//  GameBubbleCell.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class GameBubbleCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
    }
    
    func resizeCell() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
