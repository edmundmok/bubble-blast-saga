//
//  TrajectoryPathLayer.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class TrajectoryPathLayer: CAShapeLayer {
    
    func setPathStyle(gameArea: UIView) {
        // Style for trajectory - dotted lines
        self.strokeColor = UIColor.white.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = gameArea.frame.size.width * Constants.lineWidthMultiplier
        self.lineCap = kCALineCapRound
        
        let dashes = [
            Constants.dashPatternStart,
            NSNumber(value: Double(self.lineWidth * Constants.dashMultiplier))
        ]
        
        self.lineDashPhase = Constants.dashPhase
        self.lineDashPattern = dashes
    }
    
    func drawPath(from points: [CGPoint], start: CGPoint) {
        let trajectoryPath = UIBezierPath()
        trajectoryPath.move(to: start)
        
        points.forEach { trajectoryPath.addLine(to: $0) }
        self.path = trajectoryPath.cgPath
    }
    
}
