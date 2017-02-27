//
//  LevelSelectCell.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class LevelSelectCell: UICollectionViewCell {
    
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var levelName: UILabel!
    @IBOutlet weak var highScore: UILabel!
    @IBOutlet weak var deleteButton: LevelSelectCellButton!
    @IBOutlet weak var playLoadButton: LevelSelectCellButton!
}
