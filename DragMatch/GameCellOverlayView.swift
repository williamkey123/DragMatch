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

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isHighlighted ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                .padding(2.5)
            GameCellText(text)
                .font(.system(size: 40))
        }
    }
}
