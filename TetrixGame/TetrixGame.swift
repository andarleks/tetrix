//
//  TetrixGame.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

protocol TetrixGameDelegate {
    
    func gameDidEnd(tetrixGame: TetrixGame)
    func gameDidBegin(tetrixGame: TetrixGame)
    func gameShapeDidLand(tetrixGame: TetrixGame)
    func gameShapeDidMove(tetrixGame: TetrixGame)
    func gameShapeDidDrop(tetrixGame: TetrixGame)
    func gameDidLevelUp(tetrixGame: TetrixGame)
}

class TetrixGame {
    
    static let numberOfColumns = 10
    static let numberOfRows = 20
    
    static let startingColumn = 4
    static let startingRow = 0
    
    let pointsPerLine = 10
    let levelThreshold = 500
    
    let previewColumn = 12
    let previewRow = 1
    
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: TetrixGameDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        
        score = 0
        level = 1
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: TetrixGame.numberOfColumns, rows: TetrixGame.numberOfRows)
    }
    
    func beginGame() {
        
        if nextShape == nil {
            
            nextShape = Shape.random(startingColumn: previewColumn, startingRow: previewRow)
        }
        
        delegate?.gameDidBegin(tetrixGame: self)
    }
    
    func endGame() {
        
        score = 0
        level = 1
        
        delegate?.gameDidEnd(tetrixGame: self)
    }
    
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: previewColumn, startingRow: previewRow)
        fallingShape?.moveTo(column: TetrixGame.startingColumn, row: TetrixGame.startingRow)
        
        if detectIllegalPlacement() {
            
            nextShape = fallingShape
            nextShape?.moveTo(column: previewColumn, row: previewRow)
            endGame()
            
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        
        guard let shape = fallingShape else { return false }
        
        for block in shape.blocks {
            
            if block.column < 0 || block.column >= TetrixGame.numberOfColumns || block.row < 0 || block.row >= TetrixGame.numberOfRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        
        return false
    }
    
    func settleShape() {
        
        guard let shape = fallingShape else { return }
        
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        
        fallingShape = nil
        
        delegate?.gameShapeDidLand(tetrixGame: self)
    }
    
    
    func detectTouch() -> Bool {
        
        guard let shape = fallingShape else { return false }
        
        for bottomBlock in shape.bottomBlocks {
            
            if bottomBlock.row == TetrixGame.numberOfRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        
        return false
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<TetrixGame.numberOfRows {
            
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<TetrixGame.numberOfColumns {
                
                guard let block = blockArray[column, row] else { continue }
                
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            
            allBlocks.append(rowOfBlocks)
        }
        
        return allBlocks
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        
        var removedLines = Array<Array<Block>>()
        
        for row in (1..<TetrixGame.numberOfRows).reversed() {
            
            var rowOfBlocks = Array<Block>()
            for column in 0..<TetrixGame.numberOfColumns {
                
                guard let block = blockArray[column, row] else { continue }
                
                rowOfBlocks.append(block)
            }
            
            if rowOfBlocks.count == TetrixGame.numberOfColumns {
                
                removedLines.append(rowOfBlocks)
                
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        if removedLines.count == 0 {
            return ([], [])
        }
        
        let pointsEarned = removedLines.count * pointsPerLine * level
        
        score += pointsEarned
        
        if score >= level * levelThreshold {
            level += 1
            delegate?.gameDidLevelUp(tetrixGame: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        
        for column in 0..<TetrixGame.numberOfColumns {
            
            var fallenBlocksArray = Array<Block>()
            
            for row in (1..<removedLines[0][0].row).reversed() {
                
                guard let block = blockArray[column, row] else { continue }
                
                var newRow = row
                
                while (newRow < TetrixGame.numberOfRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                
                fallenBlocksArray.append(block)
            }
            
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        
        return (removedLines, fallenBlocks)
    }
    
    func dropShape() {
        
        guard let shape = fallingShape else { return }
        
        while !detectIllegalPlacement() {
            shape.lowerShapeByOneRow()
        }
        
        shape.raiseShapeByOneRow()
        
        delegate?.gameShapeDidDrop(tetrixGame: self)
    }
    
    func letShapeFall() {
        
        guard let shape = fallingShape else { return }
        
        shape.lowerShapeByOneRow()
        
        if detectIllegalPlacement() {
            
            shape.raiseShapeByOneRow()
            
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            
            delegate?.gameShapeDidMove(tetrixGame: self)
            
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    func rotateShape() {
        
        guard let shape = fallingShape else { return }
        
        shape.rotateClockwise()
        
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        
        delegate?.gameShapeDidMove(tetrixGame: self)
    }
    
    func moveShapeLeft() {
        
        guard let shape = fallingShape else { return }
        
        shape.shiftLeftByOneColumn()
        
        guard !detectIllegalPlacement() else {
            shape.shiftRightByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(tetrixGame: self)
    }
    
    func moveShapeRight() {
        
        guard let shape = fallingShape else { return }
        
        shape.shiftRightByOneColumn()
        
        guard !detectIllegalPlacement() else {
            shape.shiftLeftByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(tetrixGame: self)
    }
}
