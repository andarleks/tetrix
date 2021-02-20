//
//  LShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class LShape: Shape {
    
    /*
    
    Orientation 0
    
        | 0•|
        | 1 |
        | 2 | 3 |
    
    Orientation 90

          •
    | 2 | 1 | 0 |
    | 3 |
    
    Orientation 180
    
    | 3 | 2•|
        | 1 |
        | 0 |
    
    Orientation 270
    
          • | 3 |
    | 0 | 1 | 2 |
    
    • marks the row/column indicator for the shape
    
    Pivots about `1`
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [ (0, 0), (0, 1), (0, 2), (1, 2)],
                .ninety:     [ (1, 1), (0, 1), (-1, 1), (-1, 2)],
                .oneEighty:  [ (0, 2), (0, 1), (0, 0), (-1, 0)],
                .twoSeventy: [ (-1, 1), (0, 1), (1, 1), (1, 0)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[firstBlockIndex], blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .oneEighty:  [blocks[firstBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[firstBlockIndex], blocks[secondBlockIndex], blocks[thirdBlockIndex]]]
    }
}
