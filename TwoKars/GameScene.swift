//
//  GameScene.swift
//  TwoKars
//
//  Created by digvijay.s on 13/05/18.
//  Copyright © 2018 digvijay.s. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let car: UInt32 = 0b1
    static let circle: UInt32 = 0b10
    static let square: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var leftCarAtInitialPosition: Bool = true
    private var rightCarAtInitialPosition: Bool = true
    
    private let firstLeftXPosition: CGFloat = 1/8
    private let firstRightXPosition: CGFloat = 7/8
    
    private let secondLeftXPosition: CGFloat = 3/8
    private let secondRightXPosition: CGFloat = 5/8
    
    private let carYPosition: CGFloat = 1/8
    
    private let obstacleSideSize: CGFloat = 40
    
    private let leftCar = SKSpriteNode(imageNamed: "car")
    private let rightCar = SKSpriteNode(imageNamed: "car")
    
    private var score = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        leftCar.scale(to: CGSize(width: 60, height: 100))
        leftCar.position = CGPoint(x: size.width * firstLeftXPosition,
                                   y: size.height * carYPosition)
        leftCar.physicsBody = SKPhysicsBody(rectangleOf: leftCar.size)
        leftCar.physicsBody?.isDynamic = true
        leftCar.physicsBody?.categoryBitMask = PhysicsCategory.car
        leftCar.physicsBody?.contactTestBitMask = PhysicsCategory.circle | PhysicsCategory.square
        leftCar.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(leftCar)
        rightCar.scale(to: CGSize(width: 60, height: 100))
        rightCar.position = CGPoint(x: size.width * firstRightXPosition,
                                    y: size.height * carYPosition)
        rightCar.physicsBody = SKPhysicsBody(rectangleOf: rightCar.size)
        rightCar.physicsBody?.isDynamic = true
        rightCar.physicsBody?.categoryBitMask = PhysicsCategory.car
        rightCar.physicsBody?.contactTestBitMask = PhysicsCategory.circle | PhysicsCategory.square
        rightCar.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(rightCar)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addObstacle),
                SKAction.wait(forDuration: 0.8)
                ])
        ))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let actualDuration: CGFloat = 0.2
        let actionMove: SKAction
        
        if touchLocation.x < size.width / 2 {
            if leftCarAtInitialPosition {
                actionMove = SKAction.move(to: CGPoint(x: secondLeftXPosition * size.width,
                                                           y: carYPosition * size.height),
                                               duration: TimeInterval(actualDuration))
            } else {
                actionMove = SKAction.move(to: CGPoint(x: firstLeftXPosition * size.width,
                                                       y: carYPosition * size.height),
                                           duration: TimeInterval(actualDuration))
            }
            leftCarAtInitialPosition = !leftCarAtInitialPosition
            leftCar.run(actionMove)
        } else {
            if rightCarAtInitialPosition {
                actionMove = SKAction.move(to: CGPoint(x: secondRightXPosition * size.width,
                                                       y: carYPosition * size.height),
                                           duration: TimeInterval(actualDuration))
            } else {
                actionMove = SKAction.move(to: CGPoint(x: firstRightXPosition * size.width,
                                                       y: carYPosition * size.height),
                                           duration: TimeInterval(actualDuration))
            }
            rightCarAtInitialPosition = !rightCarAtInitialPosition
            rightCar.run(actionMove)
        }
    }
    
    private func addObstacle() {
        let numberOfObstacles = Int(arc4random_uniform(2))
        let leftObstaclePositions = [CGPoint(x: firstLeftXPosition * size.width, y: size.height + obstacleSideSize/2),
                                     CGPoint(x: secondLeftXPosition * size.width, y: size.height + obstacleSideSize/2)]
        
        let rightObstaclePositions = [CGPoint(x: firstRightXPosition * size.width, y: size.height + obstacleSideSize/2),
                                      CGPoint(x: secondRightXPosition * size.width, y: size.height + obstacleSideSize/2)]
        let randomObstaclePosition = Int(arc4random_uniform(2))
        
        for i in 0...numberOfObstacles {
            let obstacles = [SKSpriteNode(imageNamed: "red-circle"),
                             SKSpriteNode(imageNamed: "blue-square")]
            let obstacleType = Int(arc4random_uniform(2))
            let obstacle = obstacles[obstacleType]
            
            obstacle.scale(to: CGSize(width: obstacleSideSize, height: obstacleSideSize))
            
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.isDynamic = true
            if obstacleType == 0 {
                obstacle.physicsBody?.categoryBitMask = PhysicsCategory.circle
            } else {
                obstacle.physicsBody?.categoryBitMask = PhysicsCategory.square
            }
            obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.car
            obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
            
            let obstableSubPosition = Int(arc4random_uniform(2))
            if i == 0 {
                if randomObstaclePosition == 0 {
                    obstacle.position = leftObstaclePositions[obstableSubPosition]
                } else {
                    obstacle.position = rightObstaclePositions[obstableSubPosition]
                }
            } else {
                if randomObstaclePosition == 0 {
                    obstacle.position = rightObstaclePositions[obstableSubPosition]
                } else {
                    obstacle.position = leftObstaclePositions[obstableSubPosition]
                }
            }
            
            addChild(obstacle)
            
            let actualDuration = 2.0
            let actionMove = SKAction.move(to: CGPoint(x: obstacle.position.x, y: -obstacleSideSize/2),
                                           duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            let loseAction = SKAction.run() { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showGameOverScreen()
            }
            if obstacleType == 0 {
                obstacle.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
            } else {
                obstacle.run(SKAction.sequence([actionMove, actionMoveDone]))
            }
        }
    }
    
    private func carCollisionWithSquare(car: SKSpriteNode, square: SKSpriteNode) {
        square.removeFromParent()
        showGameOverScreen()
    }
    
    private func carCollisionWithCircle(car: SKSpriteNode, circle: SKSpriteNode) {
        circle.removeFromParent()
        score += 1
    }
    
    private func showGameOverScreen() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, score: score)
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    // SKPhysicsContactDelegate methods
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.car != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.square != 0)) {
            if let car = firstBody.node as? SKSpriteNode,
                let square = secondBody.node as? SKSpriteNode {
                carCollisionWithSquare(car: car, square: square)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.car != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.circle != 0)) {
            if let car = firstBody.node as? SKSpriteNode,
                let circle = secondBody.node as? SKSpriteNode {
                carCollisionWithCircle(car: car, circle: circle)
            }
        }
    }
    
}
