//
//  SShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class SShape: Shape {
    
    /*
    
    Orientation 0
    
    | 0•|
    | 1 | 2 |
        | 3 |
    
    Orientation 90
    
      • | 1 | 0 |
    | 3 | 2 |
    
    Orientation 180
    
    | 0•|
    | 1 | 2 |
        | 3 |
    
    Orientation 270
    
      • | 1 | 0 |
    | 3 | 2 |
    
    • marks the row/column indicator for the shape
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(0, 0), (0, 1), (1, 1), (1, 2)],
                .ninety:     [(2, 0), (1, 0), (1, 1), (0, 1)],
                .oneEighty:  [(0, 0), (0, 1), (1, 1), (1, 2)],
                .twoSeventy: [(2, 0), (1, 0), (1, 1), (0, 1)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[firstBlockIndex], blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .oneEighty:  [blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[firstBlockIndex], blocks[thirdBlockIndex], blocks[fourthBlockIndex]]]
    }
}
