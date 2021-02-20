//
//  GameViewController.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 17.1.21..
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var tetrixGame: TetrixGame!
    
    var panPointReference: CGPoint?
    
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
    
    func didTick() {
        
        tetrixGame.letShapeFall()
    }
    
    func nextShape() {
        
        let newShapes = tetrixGame.newShape()
        
        guard let fallingShape = newShapes.fallingShape else { return }
        
        scene.addPreviewShapeToScene(shape: newShapes.nextShape!, completion: {})
        scene.movePreviewShape(shape: fallingShape) { [weak self] in
            
            self?.view.isUserInteractionEnabled = true
            self?.scene.startTicking()
        }
    }
}

extension GameViewController: TetrixGameDelegate {
    
    func gameDidBegin(tetrixGame: TetrixGame) {
        
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
    
    func gameDidEnd(tetrixGame: TetrixGame) {
        
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        scene.animateCollapsingLines(linesToRemove: tetrixGame.removeAllBlocks(), fallenBlocks: tetrixGame.removeAllBlocks()) { [weak self] in
            self?.tetrixGame.beginGame()
        }
    }
    
    func gameDidLevelUp(tetrixGame: TetrixGame) {
        
        if scene.tickLengthMilliseconds >= 100 {
            scene.tickLengthMilliseconds -= 100
        } else if scene.tickLengthMilliseconds > 50 {
            scene.tickLengthMilliseconds -= 50
        }
    }
    
    func gameShapeDidDrop(tetrixGame: TetrixGame) {
        
        scene.stopTicking()
        scene.redrawShape(shape: tetrixGame.fallingShape!) { [weak self] in
            
            self?.tetrixGame.letShapeFall()
        }
    }
    
    func gameShapeDidLand(tetrixGame: TetrixGame) {
        
        scene.stopTicking()
        
        view.isUserInteractionEnabled = false
        
        let removedLines = tetrixGame.removeCompletedLines()
        
        if removedLines.linesRemoved.count > 0 {
            
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) { [weak self] in
                
                guard let self = self else { return }
                
                self.gameShapeDidLand(tetrixGame: self.tetrixGame)
            }
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(tetrixGame: TetrixGame) {
        
        scene.redrawShape(shape: tetrixGame.fallingShape!, completion: {})
    }
}
