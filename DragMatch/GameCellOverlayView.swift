//
//  GameCellOverlayView.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//


import SwiftUI

struct GameCellOverlayView: View {
    let text: String
    let isHighlighted: Bool

    init(_ text: String, isHighlighted: Bool) {
        self.text = text
        self.isHighlighted = isHighlighted
    }

    var color: Color {
        if isHighlighted {
            return Color.gridHighlight
        } else if text.isEmpty {
            return Color.gridSquare
        } else {
            return Color.gridSquare
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .padding(2.5)
            GameCellText(text)
        }
    }
}
