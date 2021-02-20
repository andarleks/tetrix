//
//  Shape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

import SpriteKit

enum Orientation: Int, CustomStringConvertible {
    
    case zero = 0
    case ninety
    case oneEighty
    case twoSeventy
    
    static let numberOfOrientations = 4
    
    static func random() -> Orientation {
        
        return Orientation(rawValue: (0..<Orientation.numberOfOrientations).randomElement()!)! // force unwrapping can't fail - all static predefined values
    }
    
    static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation {
        
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        
        if rotated > Orientation.twoSeventy.rawValue {
            rotated = Orientation.zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.twoSeventy.rawValue
        }
        
        return Orientation(rawValue: rotated)! // force unwrapping can't fail - one of four orientation values must be picked
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        
        switch self {
        case .zero:
            return "0"
        case .ninety:
            return "90"
        case .oneEighty:
            return "180"
        case .twoSeventy:
            return "270"
        }
    }
}

class Shape: Hashable, CustomStringConvertible {
    
    static let numberOfShapeTypes = 7
    
    let firstBlockIndex = 0
    let secondBlockIndex = 1
    let thirdBlockIndex = 2
    let fourthBlockIndex = 3
    
    let color: BlockColor
    
    var blocks = Array<Block>()
    var orientation: Orientation
    var column: Int
    var row: Int
    
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [:]
    }
    
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [:]
    }
    
    var bottomBlocks: Array<Block> {
        
        if let bottomBlocks = bottomBlocksForOrientations[orientation] {
            return bottomBlocks
        }
        
        return []
    }
    
    // MARK: - Init
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation) {
        
        self.column = column
        self.row = row
        self.color = color
        self.orientation = orientation
        
        initializeBlocks()
    }
    
    convenience init(column: Int, row: Int) {
        
        self.init(column: column, row: row, color: BlockColor.random(), orientation: Orientation.random())
    }
    
    final func initializeBlocks() {
        
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else { return }
        
        for index in 0..<blockRowColumnTranslations.count {
            
            let blockRow = row + blockRowColumnTranslations[index].rowDiff
            let blockColumn = column + blockRowColumnTranslations[index].columnDiff
            
            let newBlock = Block(column: blockColumn, row: blockRow, color: color)
            
            blocks.append(newBlock)
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        
        guard let blockRowColumnTranslations: Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else { return }
        
        blockRowColumnTranslations.enumerated().forEach { (index, columnRowDiff) in
            
            let (columnDiff, rowDiff) = columnRowDiff
            
            blocks[index].column = column + columnDiff
            blocks[index].row = row + rowDiff
        }
    }
    
    final func rotateClockwise() {
        
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        
        rotateBlocks(orientation: newOrientation)
        
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        
        rotateBlocks(orientation: newOrientation)
        
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        
        shiftBy(columns: 0, rows: 1)
    }
    
    final func raiseShapeByOneRow() {
        
        shiftBy(columns: 0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        
        shiftBy(columns: 1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        
        shiftBy(columns: -1, rows: 0)
    }

    final func shiftBy(columns: Int, rows: Int) {
        
        self.column += columns
        self.row += rows
        
        rotateBlocks(orientation: orientation)
    }
    
    final func moveTo(column: Int, row: Int) {
        
        self.column = column
        self.row = row
        
        rotateBlocks(orientation: orientation)
    }

    final class func random(startingColumn: Int, startingRow: Int) -> Shape {
        
        switch (0...numberOfShapeTypes).randomElement() {
        case 0:
            return SquareShape(column: startingColumn, row: startingRow)
        case 1:
            return LineShape(column: startingColumn, row: startingRow)
        case 2:
            return TShape(column: startingColumn, row: startingRow)
        case 3:
            return SShape(column: startingColumn, row: startingRow)
        case 4:
            return ZShape(column: startingColumn, row: startingRow)
        case 5:
            return LShape(column: startingColumn, row: startingRow)
        default:
            return JShape(column: startingColumn, row: startingRow)
        }
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(blocks.reduce(0) { $0.hashValue ^ $1.hashValue })
    }
    
    static func == (lhs: Shape, rhs: Shape) -> Bool {
        
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        
        return "\(color) block facing \(orientation): \(blocks[firstBlockIndex]), \(blocks[secondBlockIndex]), \(blocks[thirdBlockIndex]), \(blocks[fourthBlockIndex])"
    }
}
