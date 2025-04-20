//
//  GameBoardGridView.swift
//  HerdMentality
//
//  Created by William Key on 4/16/25.
//


import SwiftUI

struct GameBoardGridView: View {
    let cellSize: CGFloat
    let gridSize: Int
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { column in
                        let isHighlighted = viewModel.highlightedCells.contains {
                            $0.row == row && $0.column == column
                        }
                        GameCellView(
                            row: row,
                            column: column,
                            cellSize: cellSize,
                            item: viewModel.gridItems[row][column],
                            isHighlighted: isHighlighted
                        )
                    }
                }
            }
        }
        .onPreferenceChange(CellFramesPreferenceKey.self) { cells in
            viewModel.cellFrames = cells
        }
    }
}
