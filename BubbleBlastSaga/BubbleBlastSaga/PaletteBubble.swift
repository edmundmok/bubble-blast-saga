//
//  PaletteBubble.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 28/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 PaletteBubble represents a bubble button on the palette of the
 level designer.
 */
class PaletteBubble: UIButton {
 
    override public var isSelected: Bool {
        didSet {
            guard isSelected else {
                setUnselectedStyle()
                return
            }
            setSelectedStyle()
        }
    }
    
    private func setSelectedStyle() {
        self.layer.borderWidth = Constants.paletteBubbleBorderWidth
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.imageView?.alpha = Constants.shownAlpha
    }
    
    private func setUnselectedStyle() {
        self.layer.borderWidth = Constants.paletteBubbleUnselectedBorderWidth
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.imageView?.alpha = Constants.unselectedAlpha
    }
}
