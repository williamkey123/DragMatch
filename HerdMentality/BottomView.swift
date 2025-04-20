//
//  BottomView.swift
//  HerdMentality
//
//  Created by William Key on 4/16/25.
//


import SwiftUI

struct BottomView: View {
    @ObservedObject var viewModel: GameViewModel
    let cellSize: CGFloat

    // Animation used when the candidate view can't be dropped and needs to go back to it's original location
    let bounceBackAnimation: Animation = .spring(duration: 0.2, bounce: 0.3)

    var body: some View {
        if viewModel.isGameOver {
            let isLargeScreen = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) > 1000
            VStack(spacing: 16) {
                Text("Game Over!")
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: isLargeScreen ? 36 : 24, weight: .bold))
                    .padding(.horizontal, 28)

                Button(action: viewModel.restartGame) {
                    Text("Restart")
                        .font(.system(size: isLargeScreen ? 32 : 22, weight: .bold))
                        .padding(isLargeScreen ? 8 : 2)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
        } else if let candidates = viewModel.candidates {
            CandidateView(
                candidates: candidates,
                cellSize: cellSize,
                setFirstDragged: { viewModel.firstDragged = $0 },
                onDragChanged: { value in
                    viewModel.setHighlights(at: value.location)
                    viewModel.dragOffset = value.translation
                },
                onDragEnd: { value in
                    if viewModel.canDropCandidates(at: value.location) {
                        viewModel.dropCandidates(at: value.location)
                        viewModel.dragOffset = .zero
                    } else {
                        // If the drop couldn't be completed, animate the move back to the start position
                        withAnimation(bounceBackAnimation) {
                            viewModel.dragOffset = .zero
                        }
                    }
                    viewModel.firstDragged = nil
                }
            )
            .offset(viewModel.dragOffset)
            .padding()
        } else {
            EmptyView()
        }

    }
}
