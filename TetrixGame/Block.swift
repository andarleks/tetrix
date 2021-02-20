//
//  Block.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

import SpriteKit

enum BlockColor: Int, CustomStringConvertible {
    
    case blue = 0
    case orange
    case purple
    case red
    case teal
    case yellow
    
    var spriteName: String {
        
        switch self {
        case .blue:
            return "blue"
        case .orange:
            return "orange"
        case .purple:
            return "purple"
        case .red:
            return "red"
        case .teal:
            return "teal"
        case .yellow:
            return "yellow"
        }
    }
    
    static let numberOfColors = 6
    
    static func random() -> BlockColor {
        
        return BlockColor(rawValue: (0..<BlockColor.numberOfColors).randomElement()!)! // force unwrapping can't fail - all static predefined values
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        
        return spriteName
    }
}

class Block: Hashable, CustomStringConvertible {
    
    let color: BlockColor
    
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    var spriteName: String {
        
        return color.spriteName
    }
    
    // MARK: - Init
    
    init(column: Int, row: Int, color: BlockColor) {
        
        self.column = column
        self.row = row
        self.color = color
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(column ^ row)
    }
    
    static func == (lhs: Block, rhs: Block) -> Bool {
        
        return lhs.column == rhs.column &&
            lhs.row == rhs.row &&
            lhs.color.rawValue == rhs.color.rawValue // will work without rawValue?
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        
        return "\(color): [\(column), \(row)]"
    }
}
