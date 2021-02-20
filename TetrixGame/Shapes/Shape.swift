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
        
        return Orientation(rawValue: (0...Orientation.numberOfOrientations).randomElement()!)! // force unwrapping can't fail - all static predefined values
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
    
    let numberOfShapeTypes = 7
    
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
