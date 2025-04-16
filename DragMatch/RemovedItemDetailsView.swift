//
//  RemovedItemDetailsView.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//


import SwiftUI

struct RemovedItemDetailsView: View {
    private let count: Int
    private let location: CGPoint
    private let finalTextPosition: CGPoint?
    @State private var displayedText = ""
    @State private var currentPosition: CGPoint
    @State private var scale: CGFloat = 3
    @State private var opacity: Double = 0
    private var onComplete: () -> Void

    init(
        count: Int,
        location: CGPoint,
        finalTextPosition: CGPoint? = nil,
        onComplete: @escaping () -> Void
    ) {
        self.count = count
        self.location = location
        self.finalTextPosition = finalTextPosition
        self.currentPosition = location
        self.onComplete = onComplete
    }

    var body: some View {
        Text(displayedText)
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(.primary.opacity(0.8))
            .scaleEffect(scale)
            .position(x: currentPosition.x, y: currentPosition.y)
            .opacity(opacity)
            .onAppear {
                // First, fade in the displayed text
                self.displayedText = "+\(count)"
                withAnimation(.linear(duration: 0.2)) {
                    opacity = 1
                    scale = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // After text has faded in, animate the position change
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let finalTextPosition {
                            self.currentPosition = finalTextPosition
                        }
                        self.scale = 0.3
                    }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.22,
                        execute: self.onComplete
                    )
                }
            }
    }
}
