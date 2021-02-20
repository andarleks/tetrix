//
//  LineShape.swift
//  TetrixGame
//
//  Created by Aleksandar Voštić on 20.2.21..
//

class LineShape: Shape {
    
    /*
     
     Orientations 0 and 180:
     
        | 0•|
        | 1 |
        | 2 |
        | 3 |
     
     Orientations 90 and 270:
     
     | 0 | 1•| 2 | 3 |
     
     • marks the row/column indicator for the shape
     
     Hinges about the second block
     
     */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [.zero:       [(0, 0), (0, 1), (0, 2), (0, 3)],
                .ninety:     [(-1,0), (0, 0), (1, 0), (2, 0)],
                .oneEighty:  [(0, 0), (0, 1), (0, 2), (0, 3)],
                .twoSeventy: [(-1,0), (0, 0), (1, 0), (2, 0)]]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [.zero:       [blocks[fourthBlockIndex]],
                .ninety:     blocks,
                .oneEighty:  [blocks[fourthBlockIndex]],
                .twoSeventy: blocks]
    }
}
