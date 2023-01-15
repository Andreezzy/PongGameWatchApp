//
//  GameScene.swift
//  PongGame Watch App
//
//  Created by Andres Frank on 29/12/22.
//

import Foundation
import SpriteKit

class GameScene: SKScene, ObservableObject, SKPhysicsContactDelegate {
    
    let playerPaddel = SKSpriteNode(imageNamed: "GreenPaddle")
    let paddle = SKSpriteNode(imageNamed: "BluePaddle")
    let ball = SKSpriteNode(imageNamed: "Ball")
    
    var playerPosX: Double = 470
    
    var playerScore = 0
    var enemyScore = 0
    var playerLabel = SKLabelNode()
    var enemyScoreLabel = SKLabelNode()
    
    enum bitMask: UInt32 {
        case ball = 0b1
        case frame = 0b10
        case playerPaddle = 0b100
    }
    
    override func sceneDidLoad() {
        scene?.size = CGSize(width: 170, height: 200)
        scene?.scaleMode = .aspectFill
        scene?.anchorPoint = .zero
        scene?.physicsWorld.speed = 2
        
        backgroundColor = .green
        
        physicsWorld.contactDelegate = self
        
        // Player
        playerPaddel.position = CGPoint(x: size.width / 2, y: 10)
        playerPaddel.setScale(0.4)
        playerPaddel.zPosition = 5
        playerPaddel.physicsBody = SKPhysicsBody(rectangleOf: playerPaddel.size)
        playerPaddel.physicsBody?.friction = 0
        playerPaddel.physicsBody?.restitution = 1
        playerPaddel.physicsBody?.affectedByGravity = false
        playerPaddel.physicsBody?.isDynamic = false
        playerPaddel.physicsBody?.allowsRotation = false
        playerPaddel.physicsBody?.categoryBitMask = bitMask.playerPaddle.rawValue
        playerPaddel.physicsBody?.contactTestBitMask = bitMask.ball.rawValue
        playerPaddel.physicsBody?.collisionBitMask = bitMask.ball.rawValue
        addChild(playerPaddel)
        
        // Computer
        paddle.position = CGPoint(x: size.width / 2, y: 190)
        paddle.setScale(0.4)
        paddle.zPosition = 5
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.allowsRotation = false
        paddle.physicsBody?.categoryBitMask = bitMask.playerPaddle.rawValue
        paddle.physicsBody?.contactTestBitMask = bitMask.ball.rawValue
        paddle.physicsBody?.collisionBitMask = bitMask.ball.rawValue
        addChild(paddle)
        
        // Ball
        makeNewBall()
        
        let frame = SKPhysicsBody(edgeLoopFrom: self.frame)
        frame.friction = 0
        frame.restitution = 0
        
        self.physicsBody = frame
        
        frame.categoryBitMask = bitMask.frame.rawValue
        frame.contactTestBitMask = bitMask.ball.rawValue
        frame.collisionBitMask = bitMask.ball.rawValue
        
        playerLabel.position = CGPoint(x: size.width / 3, y: size.height / 2)
        playerLabel.zPosition = 10
        playerLabel.text = "\(playerScore)"
        playerLabel.fontColor = .blue
        addChild(playerLabel)
        
        enemyScoreLabel.position = CGPoint(x: size.width / 1.5, y: size.height / 2)
        enemyScoreLabel.zPosition = 10
        enemyScoreLabel.text = "\(enemyScore)"
        enemyScoreLabel.fontColor = .blue
        addChild(enemyScoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        playerPaddel.position.x = playerPosX / 5
        
        if playerPaddel.position.x < 25 {
            playerPaddel.position.x = 25
        }
        
        if playerPaddel.position.x > 150 {
            playerPaddel.position.x = 150
        }
        
        if ball.position.y > frame.midY {
            let paddelMove = SKAction.moveTo(x: ball.position.x, duration: 0.8)
            paddle.run(paddelMove)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var ballNode: SKNode!
        var otherNode: SKNode!
        
        let xPos = contact.contactPoint.x
        let yPos = contact.contactPoint.y
        
        if contact.bodyA.node?.physicsBody?.categoryBitMask == bitMask.ball.rawValue {
            ballNode = contact.bodyA.node
            otherNode = contact.bodyB.node
        } else if contact.bodyB.node?.physicsBody?.categoryBitMask == bitMask.ball.rawValue {
            ballNode = contact.bodyB.node
            otherNode = contact.bodyA.node
        }
        
        if otherNode.physicsBody?.categoryBitMask == bitMask.frame.rawValue {
            // Ball hit the frame
            if yPos >= otherNode.frame.maxY - 2 {
                playerScore += 1
                playerLabel.text = "\(playerScore)"

                ballNode.removeFromParent()
                
                if playerScore <= 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.makeNewBall()
                    }
                }
            } else if yPos <= otherNode.frame.minY + 2 {
                enemyScore += 1
                enemyScoreLabel.text = "\(enemyScore)"
                
                ballNode.removeFromParent()
                
                if enemyScore <= 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.makeNewBall()
                    }
                }
            }
            
            if playerScore == 3 {
                let youWinLabel = SKLabelNode()
                youWinLabel.text = "🏆"
                youWinLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
                youWinLabel.zPosition = 20
                addChild(youWinLabel)
                playerScore = 0
                enemyScore = 0
                playerLabel.text = "\(playerScore)"
                enemyScoreLabel.text = "\(enemyScore)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    ballNode.removeFromParent()
                    youWinLabel.removeFromParent()
                    
                    self.makeNewBall()
                }
            }
            
            if enemyScore == 3 {
                let gameOverLogo = SKSpriteNode(imageNamed: "GameOver")
                gameOverLogo.size = CGSize(width: 100, height: 59)
                gameOverLogo.position = CGPoint(x: size.width / 2, y: size.height / 2)
                gameOverLogo.zPosition = 20
                addChild(gameOverLogo)
                
                playerScore = 0
                enemyScore = 0
                playerLabel.text = "\(playerScore)"
                enemyScoreLabel.text = "\(enemyScore)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    ballNode.removeFromParent()
                    gameOverLogo.removeFromParent()
                    
                    self.makeNewBall()
                }
            }
        }
        
        if otherNode.physicsBody?.categoryBitMask == bitMask.playerPaddle.rawValue {
            if xPos >= otherNode.frame.midX - 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0.3, dy: 0))
            } else if xPos <= otherNode.frame.midX + 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: -0.3, dy: 0))
            }
        }
    }
    
    func makeNewBall() {
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.setScale(0.15)
        ball.zPosition = 5
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.height / 2)

        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.categoryBitMask = bitMask.ball.rawValue
        ball.physicsBody?.contactTestBitMask = bitMask.frame.rawValue | bitMask.playerPaddle.rawValue
        ball.physicsBody?.collisionBitMask = bitMask.frame.rawValue | bitMask.playerPaddle.rawValue
        addChild(ball)
        
        ball.physicsBody?.applyImpulse(CGVector(dx: 0.3, dy: 0.3))
    }
}
