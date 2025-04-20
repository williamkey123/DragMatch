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

    // MARK: animation timing constants
    private let fadeInTime: TimeInterval = 0.2
    private let animatedMovementDelay: TimeInterval = 0.5
    private let movementToFinalPositionTime: TimeInterval = 0.2

    // MARK: view and scale constants
    private let outroScale: CGFloat = 0.3
    private let font: Font = .system(size: 34, weight: .bold)
    private let fontStyle: any ShapeStyle = .primary.opacity(0.8)

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
            .font(font)
            .foregroundStyle(fontStyle)
            .scaleEffect(scale)
            .position(x: currentPosition.x, y: currentPosition.y)
            .opacity(opacity)
            .onAppear {
                // Set the text
                self.displayedText = "+\(count)"

                // First, fade in the displayed text
                withAnimation(.linear(duration: fadeInTime)) {
                    opacity = 1
                    scale = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animatedMovementDelay) {
                    // After text has faded in, animate the position change
                    withAnimation(.easeInOut(duration: movementToFinalPositionTime)) {
                        if let finalTextPosition {
                            self.currentPosition = finalTextPosition
                        }
                        self.scale = outroScale
                    }
                    // Give it a moment to complete, then call the completion handler
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + movementToFinalPositionTime + 0.1,
                        execute: self.onComplete
                    )
                }
            }
    }
}
