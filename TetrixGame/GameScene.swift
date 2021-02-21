//
//  GameScene.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 17.1.21..
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Static properties
    
    static let blockSize: CGFloat = 20.0
    static let tickLengthLevelOne = TimeInterval(600)
    
    // MARK: - Constants
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let layerPosition = CGPoint(x: 6, y: -6)
    
    // MARK: - Variables
    
    var tick: (() -> ())?
    var tickLengthMilliseconds = tickLengthLevelOne
    var lastTick: Date?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        addChild(background)
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: GameScene.blockSize * CGFloat(TetrixGame.numberOfColumns),
                                                                             height: GameScene.blockSize * CGFloat(TetrixGame.numberOfRows)))
        
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        gameBoard.position = layerPosition
        
        shapeLayer.position = layerPosition
        
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
    }
    
    // MARK: - Overrides
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        guard lastTick != nil else { return }
        
        let timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        
        if timePassed > tickLengthMilliseconds {
            lastTick = Date()
            tick?()
        }
    }
    
    // MARK: - Public API
    
    func startTicking() {
        
        lastTick = Date()
    }
    
    func stopTicking() {
        
        lastTick = nil
    }
    
    func playSound(_ sound: String) {
        
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    func addPreviewShapeToScene(shape: Shape, completion: @escaping () -> ()) {
        
        for block in shape.blocks {
            
            var texture = textureCache[block.spriteName]
            
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            
            let sprite = SKSpriteNode(texture: texture)
            
            sprite.position = pointForColumn(column: block.column, row:block.row - 2)
            
            shapeLayer.addChild(sprite)
            
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: 0.2)
            
            moveAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func movePreviewShape(shape: Shape, completion: @escaping () -> ()) {
        
        for block in shape.blocks {
            
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction = SKAction.move(to: moveTo, duration: 0.2)
            
            moveToAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveToAction, fadeInAction]))
        }
        
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape: Shape, completion: @escaping () -> ()) {
        
        for block in shape.blocks {
            
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion: @escaping () -> ()) {
        
        var longestDuration: TimeInterval = 0
        
        for (columnIdx, column) in fallenBlocks.enumerated() {
            
            for (blockIdx, block) in column.enumerated() {
                
                let newPosition = pointForColumn(column: block.column, row: block.row)
                let sprite = block.sprite!
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / GameScene.blockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                
                moveAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([SKAction.wait(forDuration: delay), moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            
            for block in rowToRemove {
                
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(column: block.column, row: block.row)
                point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                var startAngle = CGFloat.pi
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .easeIn
                let sprite = block.sprite!
                sprite.zPosition = 100
                sprite.run(SKAction.sequence([SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                                              SKAction.removeFromParent()]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
    }
    
    // MARK: - Private API
    
    private func pointForColumn(column: Int, row: Int) -> CGPoint {
        
        let x = layerPosition.x + (CGFloat(column) * GameScene.blockSize) + (GameScene.blockSize / 2)
        let y = layerPosition.y - ((CGFloat(row) * GameScene.blockSize) + (GameScene.blockSize / 2))
        
        return CGPoint(x: x, y: y)
    }
}
