//
//  GameViewController.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 17.1.21..
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    var scene: GameScene!
    var tetrixGame: TetrixGame!
    var panPointReference: CGPoint?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick
        
        tetrixGame = TetrixGame()
        tetrixGame.delegate = self
        tetrixGame.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        tetrixGame.rotateShape()
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        
        let currentPoint = sender.translation(in: view)
        
        if let originalPoint = panPointReference {
            
            if abs(currentPoint.x - originalPoint.x) > (GameScene.blockSize * 0.9) {
                
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    tetrixGame.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    tetrixGame.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        tetrixGame.dropShape()
    }
    
    // MARK: - Private API
    
    private func didTick() {
        
        tetrixGame.letShapeFall()
    }
    
    private func nextShape() {
        
        let newShapes = tetrixGame.newShape()
        
        guard let fallingShape = newShapes.fallingShape else { return }
        
        scene.addPreviewShapeToScene(shape: newShapes.nextShape!, completion: {})
        scene.movePreviewShape(shape: fallingShape) { [weak self] in
            
            self?.view.isUserInteractionEnabled = true
            self?.scene.startTicking()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension GameViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        
        return false
    }
}

// MARK: - TetrixGameDelegate

extension GameViewController: TetrixGameDelegate {
    
    func gameDidBegin(_ tetrixGame: TetrixGame) {
        
        levelLabel.text = "\(tetrixGame.level)"
        scoreLabel.text = "\(tetrixGame.score)"
        
        scene.tickLengthMilliseconds = GameScene.tickLengthLevelOne
        
        // The following is false when restarting a new game
        if tetrixGame.nextShape != nil && tetrixGame.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: tetrixGame.nextShape!) { [weak self] in
                self?.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(_ tetrixGame: TetrixGame) {
        
        view.isUserInteractionEnabled = false
        
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(linesToRemove: tetrixGame.removeAllBlocks(), fallenBlocks: tetrixGame.removeAllBlocks()) { [weak self] in
            self?.tetrixGame.beginGame()
        }
    }
    
    func gameDidLevelUp(_ tetrixGame: TetrixGame) {
        
        levelLabel.text = "\(tetrixGame.level)"
        
        if scene.tickLengthMilliseconds >= 100 {
            scene.tickLengthMilliseconds -= 100
        } else if scene.tickLengthMilliseconds > 50 {
            scene.tickLengthMilliseconds -= 50
        }
        
        scene.playSound("Sounds/levelup.mp3")
    }
    
    func gameShapeDidDrop(_ tetrixGame: TetrixGame) {
        
        scene.stopTicking()
        scene.redrawShape(shape: tetrixGame.fallingShape!) { [weak self] in
            
            self?.tetrixGame.letShapeFall()
        }
        
        scene.playSound("Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(_ tetrixGame: TetrixGame) {
        
        scene.stopTicking()
        
        view.isUserInteractionEnabled = false
        
        let removedLines = tetrixGame.removeCompletedLines()
        
        if removedLines.linesRemoved.count > 0 {
            
            scoreLabel.text = "\(tetrixGame.score)"
            
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) { [weak self] in
                
                guard let self = self else { return }
                
                self.gameShapeDidLand(self.tetrixGame)
            }
            
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(_ tetrixGame: TetrixGame) {
        
        scene.redrawShape(shape: tetrixGame.fallingShape!, completion: {})
    }
}
