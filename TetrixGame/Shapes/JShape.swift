//
//  JShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class JShape: Shape {
    
    /*
    
    Orientation 0
    
      • | 0 |
        | 1 |
    | 3 | 2 |
    
    Orientation 90
    
    | 3•|
    | 2 | 1 | 0 |
    
    Orientation 180
    
    | 2•| 3 |
    | 1 |
    | 0 |
    
    Orientation 270
    
    | 0•| 1 | 2 |
            | 3 |
    
    • marks the row/column indicator for the shape
    
    Pivots about `1`
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(1, 0), (1, 1), (1, 2), (0, 2)],
                .ninety:     [(2, 1), (1, 1), (0, 1), (0, 0)],
                .oneEighty:  [(0, 2), (0, 1), (0, 0), (1, 0)],
                .twoSeventy: [(0, 0), (1, 0), (2, 0), (2, 1)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[firstBlockIndex], blocks[secondBlockIndex], blocks[thirdBlockIndex]],
                .oneEighty:  [blocks[firstBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[firstBlockIndex], blocks[secondBlockIndex], blocks[fourthBlockIndex]]]
    }
}
