//
//  CannonView.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 17/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class CannonView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.image = UIImage(named: Constants.cannonImage)
        self.animationImages = Constants.cannonAnimationImages
        self.animationDuration = Constants.cannonFireDuration
        self.animationRepeatCount = Constants.cannonRepeatCount
    }
    
    func fireAnimation() {
        self.startAnimating()
    }
    
}
