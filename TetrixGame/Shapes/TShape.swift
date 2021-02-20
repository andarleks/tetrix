//
//  TShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class TShape: Shape {
    
    /*
     
     Orientation 0
     
     •   | 0 |
     | 1 | 2 | 3 |
     
     Orientation 90
     
     • | 1 |
       | 2 | 0 |
       | 3 |
     
     Orientation 180
     
     •                 or       •
     | 3 | 2 | 1 |              | 1 | 2 | 3 |
         | 0 |                      | 0 |
     
     Orientation 270
     
     •     | 1 |       or       •     | 3 |
       | 0 | 2 |                  | 0 | 2 |
           | 3 |                      | 1 |
     
     • marks the row/column indicator for the shape
     
     */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(1, 0), (0, 1), (1, 1), (2, 1)],
                .ninety:     [(2, 1), (1, 0), (1, 1), (1, 2)],
                .oneEighty:  [(1, 2), (0, 1), (1, 1), (2, 1)],
                .twoSeventy: [(0, 1), (1, 0), (1, 1), (1, 2)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[secondBlockIndex], blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[firstBlockIndex], blocks[fourthBlockIndex]],
                .oneEighty:  [blocks[firstBlockIndex], blocks[secondBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[firstBlockIndex], blocks[fourthBlockIndex]]]
    }
}
