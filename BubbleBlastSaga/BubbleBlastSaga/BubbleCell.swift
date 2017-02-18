//
//  BubbleCell.swift
//  GameEngine
//
//  Created by Edmund Mok on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

/**
 BubbleCell is a UICollectionViewCell that represents the
 view of a GameBubble object.
 */
class BubbleCell: UICollectionViewCell {
    
    var type: BubbleType = .Empty {
        didSet {
            updateCellStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer.backgroundColor = UIColor.lightGray
            .withAlphaComponent(Constants.emptyCellAlpha).cgColor
    }
    
    func resizeCell() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateCellStyle() {
        guard let bubbleImage = getImageFor(type: type) else {
            // no image available, must be an empty cell
            setStyleForEmptyCell()
            return
        }
        
        // set style according to image
        setStyleForFilledCell(with: bubbleImage)
    }
    
    private func setStyleForEmptyCell() {
        self.backgroundView = nil
        self.layer.borderWidth = Constants.emptyCellBorderWidth
    }
    
    private func setStyleForFilledCell(with image: UIImage) {
        self.backgroundView = UIImageView(image: image)
        self.layer.borderWidth = Constants.filledCellBorderWidth
    }
    
    private func getImageFor(type: BubbleType) -> UIImage? {
        switch type {
        case .Empty: return nil
        case .BlueBubble: return UIImage(named: Constants.blueBubbleImage)
        case .RedBubble: return UIImage(named: Constants.redBubbleImage)
        case .OrangeBubble: return UIImage(named: Constants.orangeBubbleImage)
        case .GreenBubble: return UIImage(named: Constants.greenBubbleImage)
        case .IndestructibleBubble: return UIImage(named: Constants.indestructibleBubbleImage)
        case .LightningBubble: return UIImage(named: Constants.lightningBubbleImage)
        case .BombBubble: return UIImage(named: Constants.bombBubbleImage)
        case .StarBubble: return UIImage(named: Constants.starBubbleImage)
        }
    }
}
