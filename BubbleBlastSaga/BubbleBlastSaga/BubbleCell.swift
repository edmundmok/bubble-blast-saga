//
//  BubbleCell.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 27/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 BubbleCell is a UICollectionViewCell that represents the 
 view of a GameBubble object.
 */
class BubbleCell: UICollectionViewCell {

    struct Constants {
        static let identifier = "BubbleCell"
    }
    
    var type: BubbleType = .Empty {
        didSet {
            updateCellStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = min(self.frame.width, self.frame.height)/2
        self.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }
    
    func resizeCell() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height)/2
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
        self.layer.borderWidth = 1
    }
    
    private func setStyleForFilledCell(with image: UIImage) {
        self.backgroundView = UIImageView(image: image)
        self.layer.borderWidth = 0
    }
    
    private func getImageFor(type: BubbleType) -> UIImage? {
        switch type {
        case .Empty: return nil
        case .BlueBubble: return UIImage(named: "bubble-blue.png")
        case .RedBubble: return UIImage(named: "bubble-red.png")
        case .GreenBubble: return UIImage(named: "bubble-green.png")
        case .OrangeBubble: return UIImage(named: "bubble-orange.png")
        }
    }
}
