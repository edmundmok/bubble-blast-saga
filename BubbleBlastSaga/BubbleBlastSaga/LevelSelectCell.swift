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
    @IBOutlet weak var deleteButton: LevelSelectDeleteButton!
    @IBOutlet weak var playLoadButton: LevelSelectPlayLoadButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
