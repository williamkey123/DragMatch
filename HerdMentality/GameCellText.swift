//
//  GameCellText.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//

import SwiftUI

struct GameCellText: View {
    private let content: String

    @State private var isVisible = false
    @State private var scale: CGFloat = 1
    @State private var currentContent: String

    init(_ content: String) {
        self.content = content
        self._currentContent = State(initialValue: content)
    }

    var body: some View {
        Text(currentContent)
            .scaleEffect(scale)
            .opacity(isVisible ? 1 : 0)
            .onChange(of: content) {
                if content.isEmpty && !currentContent.isEmpty {
                    // When content becomes empty, scale to 0 and fade out
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                        scale = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        currentContent = ""
                    }
                } else if !content.isEmpty && currentContent != content {
                    // When new content comes in, reset to normal scale and show immediately
                    currentContent = content
                    scale = 1.0
                    isVisible = true
                }
            }
            .onAppear {
                // Avoid animation on initial appearance
                currentContent = content
                isVisible = !content.isEmpty
                scale = content.isEmpty ? 0.0 : 1.0
            }
    }
}
