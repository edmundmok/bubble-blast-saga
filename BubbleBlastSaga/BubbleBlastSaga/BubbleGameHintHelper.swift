//
//  BubbleGameHintHelper.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 27/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit
import PhysicsEngine

class BubbleGameHintHelper {
    
    private weak var gameArea: UIView!
    private weak var bubbleGridModel: BubbleGridModel!
    private weak var bubbleGrid: UICollectionView!
    private weak var bubbleCannon: BubbleCannon!
    private weak var bubbleGameAnimator: BubbleGameAnimator!
    private weak var bubbleGame: BubbleGame!
    
    init(bubbleGame: BubbleGame, bubbleGridModel: BubbleGridModel, bubbleGrid: UICollectionView,
         bubbleCannon: BubbleCannon, bubbleGameAnimator: BubbleGameAnimator, gameArea: UIView) {
        self.bubbleGame = bubbleGame
        self.bubbleGridModel = bubbleGridModel
        self.bubbleGrid = bubbleGrid
        self.bubbleCannon = bubbleCannon
        self.bubbleGameAnimator = bubbleGameAnimator
        self.gameArea = gameArea
    }
    
    func getHint(from startPosition: CGPoint) -> CGFloat? {
        // Get the ordered list of candidates
        let sortedCandidates = getSortedCandidatesToShoot(from: startPosition)
        
        // Check for the best angle
        return getAngleForBestTarget(from: startPosition, candidates: sortedCandidates)
    }
    
    private func getCandidates() -> [IndexPath] {
        // Get the color of the current bubble
        guard let desiredColor = (bubbleCannon.currentBubble as? ColoredBubble)?.color else {
            return []
        }
        
        // Get bottom index paths to start from
        let bottomIndexPaths = BubbleGameUtility.getIndexPathsForBottomSection(of: bubbleGridModel)
        
        // Carry out BFS from the last section
        // Look for empty cells that have filled neighbours with same color
        // and add them to the set of candidates
        var queue = Queue<IndexPath>()
        var visited = Set<IndexPath>()
        
        var candidates = [IndexPath]()
        
        bottomIndexPaths
            .filter { bubbleGridModel.getBubbleType(at: $0) == .Empty }
            .forEach {
                queue.enqueue($0)
                visited.insert($0)
        }
        
        while !queue.isEmpty {
            guard let next = try? queue.dequeue() else {
                break
            }
            
            guard bubbleGridModel.getBubbleType(at: next) == .Empty else {
                continue
            }
            
            let nextNeighbours = bubbleGridModel.getNeighboursIndexPath(of: next)
            
            // it is a candidate if it has at least one neighbour of the same color as
            // the cannon bubble or it has a special bubble neighbour
            let isCandidate =  nextNeighbours
                .filter {
                    
                    // Do not follow indestructible bubble
                    guard bubbleGridModel.getBubbleType(at: $0) != .IndestructibleBubble else {
                        return false
                    }
                    
                    // If the neighbour is a special bubble, then it is a good candidate
                    if bubbleGridModel.getGameBubble(at: $0) is PowerBubble {
                        return true
                    }
                    
                    // Otherwise it is a good candidate if a neighbour has same color
                    return (bubbleGridModel.getGameBubble(at: $0) as? ColoredBubble)?.color == desiredColor
                    
                }
                .count > 0
            
            if isCandidate {
                candidates.append(next)
            }
            
            nextNeighbours
                .filter { !visited.contains($0) }
                .forEach {
                    queue.enqueue($0)
                    visited.insert($0)
                }
        }
        
        return candidates
    }
    
    private func getSortedCandidatesToShoot(from start: CGPoint) -> [IndexPath] {
        // get ALL the possible candidate positions
        let candidates = getCandidates()
        
        // Get removal counts of all candidates
        let candidatesRemovalCount = generateRemovalCount(for: candidates)
        
        // Sort the candidates by their removal counts in descending order
        let sortedCandidates = candidates.sorted {
            // get count associated w/ candidate $0
            let obj1 = candidatesRemovalCount[$0] ?? Constants.defaultRemovalCount
            // get count associated w/ candidate $1
            let obj2 = candidatesRemovalCount[$1] ?? Constants.defaultRemovalCount
            // sorted by their removal counts
            return obj1 > obj2
        }
        
        return sortedCandidates
    }
    
    private func generateRemovalCount(for candidates: [IndexPath]) -> [IndexPath : Int] {
        // Create mock components for simulation of moves in getting the hint
        
        let mockHelper = BubbleGameHintMockHelper(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
        
        var candidateCountDictionary = [IndexPath: Int]()
        for candidate in candidates {
            guard let modelCopy = bubbleGridModel.copy() as? BubbleGridModel else {
                continue
            }
            
            modelCopy.set(gameBubble: bubbleCannon.currentBubble, at: candidate)
            
            let logicSimulator = mockHelper.getLogicSimulator(for: modelCopy)
            let count = logicSimulator.handleInteractions(with: bubbleCannon.currentBubble)
            
            candidateCountDictionary[candidate] = count
        }
        return candidateCountDictionary
    }
    
    // Returns the angle to shoot at the best target, from the given start, out of all the
    // given candidate index paths.
    // If there is such a best target, returns the angle and flashes a hint at the location.
    // Otherwise, returns nil
    private func getAngleForBestTarget(from start: CGPoint, candidates: [IndexPath]) -> CGFloat? {
        for candidate in candidates {
            guard let targetCell = bubbleGrid.cellForItem(at: candidate) else {
                continue
            }
            
            let targetCenter = targetCell.center
            let targetWidth = targetCell.frame.width
            
            guard let angleToShootAtTarget = getAngleToShoot(at: targetCenter, of: targetWidth, from: start) else {
                continue
            }
            
            DispatchQueue.main.sync {
                bubbleGameAnimator.flashHint(at: candidate)
            }
            
            return angleToShootAtTarget
            
        }
        return nil
    }
    
    // Returns the angle required to shoot at the target of given width, from the start position
    // if possible. Otherwise, returns nil.
    private func getAngleToShoot(at target: CGPoint, of width: CGFloat, from start: CGPoint) -> CGFloat? {
        
        // try direct angle
        let directAngle = atan2(target.y - start.y, target.x - start.x)
        guard !canShoot(target: target, of: width, from: start, with: directAngle) else {
            return directAngle
        }
        
        // try left angle
        let leftReboundCoord = getCoordinateForLeftRebound(from: start, to: target)
        let leftReboundAngle = atan2(leftReboundCoord.y - start.y, leftReboundCoord.x - start.x)
        guard !canShoot(target: target, of: width, from: start, with: leftReboundAngle) else {
            return leftReboundAngle
        }
        
        // try right angle
        let rightReboundCoord = getCoordinateForRightRebound(from: start, to: target)
        let rightReboundAngle = atan2(rightReboundCoord.y - start.y, rightReboundCoord.x - start.x)
        guard !canShoot(target: target, of: width, from: start, with: rightReboundAngle) else {
            return rightReboundAngle
        }
        
        // no good angle to fire from
        return nil
    }
    
    // Returns whether we are able to shoot at the target with the given width, from the
    // given start at the given angle.
    private func canShoot(target: CGPoint, of width: CGFloat, from start: CGPoint, with angle: CGFloat) -> Bool {
        guard let finalPosition = bubbleGame.getTrajectoryPoints(from: start, at: angle).last else {
            return false
        }
        
        return finalPosition.distance(to: target) <= width
    }
    
    
    private func getCoordinateForLeftRebound(from startPosition: CGPoint, to coordinate: CGPoint) -> CGPoint {
        let actualRadiusOfBubble = bubbleGame.getStandardBubbleSize().width
            * Constants.widthToRadiusMultiplier * Constants.bubbleHitBoxSizePercentage
        
        // Using ratios to solve for the rebound coordinate
        // Using symbols in addition to the comments to facilitate understanding
        //
        // Wall X position must account for bubble radius
        let leftWallX = gameArea.frame.minX + actualRadiusOfBubble
        
        // Compute the following distances (horizontal, straight-line distances)
        // Horizontal distance from start position to the wall (x-axis only)
        // w3
        let distanceStartToWall = startPosition.distance(to: CGPoint(x: leftWallX, y: startPosition.y))
        
        // Horizontal distance from final location to wall (x-axis only)
        // w2
        let distanceTargetToWall = distanceStartToWall - (startPosition.x - coordinate.x)
        
        // Horizontal distance from start to target location (x-axis only)
        // w1 = w3 - w2
        let horizontalDistanceStartToTarget = distanceStartToWall - distanceTargetToWall
        
        // Compute the distance ratio
        // ratio = w1 / w2
        let distanceRatio = horizontalDistanceStartToTarget / distanceTargetToWall
        
        // Compute the vertical height from target location to required rebound y-position
        // h = (targetY - startY) / (2 + ratio)
        let verticalDistanceToReboundCoordinate = (coordinate.y - startPosition.y)
            / (Constants.reboundRatioConstant + distanceRatio)
        
        // Get the left rebound coordinate
        return CGPoint(x: leftWallX, y: coordinate.y - verticalDistanceToReboundCoordinate)
    }
    
    private func getCoordinateForRightRebound(from startPosition: CGPoint, to coordinate: CGPoint) -> CGPoint {
        let actualRadiusOfBubble = bubbleGame.getStandardBubbleSize().width
            * Constants.widthToRadiusMultiplier * Constants.bubbleHitBoxSizePercentage
        
        let rightWallX = gameArea.frame.maxX - actualRadiusOfBubble
        
        // Compute the following distances (horizontal, straight-line distances)
        // Horizontal distance from start position to the wall (x-axis only)
        // w3
        let distanceStartToWall = startPosition.distance(to: CGPoint(x: rightWallX, y: startPosition.y))
        
        // Horizontal distance from final location to wall (x-axis only)
        // w2
        let distanceTargetToWall = distanceStartToWall - (coordinate.x - startPosition.x)
        
        // Horizontal distance from start to target location (x-axis only)
        // w1 = w3 - w2
        let horizontalDistanceStartToTarget = distanceStartToWall - distanceTargetToWall
        
        // ratio = w1 / w2
        let distanceRatio = horizontalDistanceStartToTarget / distanceTargetToWall
        
        // Compute the vertical height from target location to required rebound y-position
        // h = (targetY - startY) / (2 + ratio)
        let verticalDistanceToReboundCoordinate = (coordinate.y - startPosition.y)
            / (Constants.reboundRatioConstant + distanceRatio)
        
        // Get the right rebound coordinate
        return CGPoint(x: rightWallX, y: coordinate.y - verticalDistanceToReboundCoordinate)
    }
    
}
