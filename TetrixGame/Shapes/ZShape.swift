//
//  ZShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class ZShape: Shape {
    
    /*
    
    Orientation 0
    
      • | 0 |
    | 2 | 1 |
    | 3 |
    
    Orientation 90
    
    | 0 | 1•|
        | 2 | 3 |
    
    Orientation 180
    
      • | 0 |
    | 2 | 1 |
    | 3 |
    
    Orientation 270
    
    | 0 | 1•|
        | 2 | 3 |
    
    • marks the row/column indicator for the shape
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(1, 0), (1, 1), (0, 1), (0, 2)],
                .ninety:     [(-1,0), (0, 0), (0, 1), (1, 1)],
                .oneEighty:  [(1, 0), (1, 1), (0, 1), (0, 2)],
                .twoSeventy: [(-1,0), (0, 0), (0, 1), (1, 1)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[firstBlockIndex], blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .oneEighty:  [blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[firstBlockIndex], blocks[thirdBlockIndex], blocks[fourthBlockIndex]]]
    }
}
