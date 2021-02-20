//
//  SquareShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class SquareShape: Shape {
    
    /*
     
     | 0•| 1 |
     | 2 | 3 |
     
     • marks the row/column indicator for the shape
     
     The square shape will not rotate
     
     */
    
    override var blockRowColumnPositions: [Orientation : Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(0, 0), (1, 0), (0, 1), (1, 1)],
                .ninety:     [(0, 0), (1, 0), (0, 1), (1, 1)],
                .oneEighty:  [(0, 0), (1, 0), (0, 1), (1, 1)],
                .twoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation : Array<Block>] {
        
        return [.zero:       [blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .ninety:     [blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .oneEighty:  [blocks[thirdBlockIndex], blocks[fourthBlockIndex]],
                .twoSeventy: [blocks[thirdBlockIndex], blocks[fourthBlockIndex]]]
    }
}
