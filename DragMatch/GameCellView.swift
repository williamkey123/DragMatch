//
//  GameCellView.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//


import SwiftUI

struct GameCellView: View {
    let row: Int
    let column: Int
    let cellSize: CGFloat
    let item: String
    let isHighlighted: Bool

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: cellSize, height: cellSize)
            .overlay(
                GameCellOverlayView(item, isHighlighted: isHighlighted)
            )
            .background(GeometryReader { geo in
                Color.clear.preference(
                    key: CellFramesPreferenceKey.self,
                    value: [
                        GridCell(
                            row: row,
                            column: column,
                            frame: geo.frame(in: GameView.coordinateSpaceName))
                    ]
                )
            })
    }
}
