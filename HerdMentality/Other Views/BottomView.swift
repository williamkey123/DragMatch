//
//  BottomView.swift
//  HerdMentality
//
//  Created by William Key on 4/16/25.
//


import SwiftUI

struct BottomView: View {
    var viewModel: GameViewModel
    let cellSize: CGFloat
    var onRestart: () -> Void

    // Animation used when the candidate view can't be dropped and needs to go back to it's original location
    let bounceBackAnimation: Animation = .spring(duration: 0.2, bounce: 0.3)

    var body: some View {
        if viewModel.game.isGameOver {
            let isLargeScreen = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) > 1000
            VStack(spacing: 16) {
                Text("Game Over!")
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: isLargeScreen ? 36 : 24, weight: .bold))
                    .padding(.horizontal, 28)

                Button(action: onRestart) {
                    Text("Restart")
                        .font(.system(size: isLargeScreen ? 32 : 22, weight: .bold))
                        .padding(isLargeScreen ? 8 : 2)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
        } else if let candidates = viewModel.game.candidates {
            CandidateView(
                candidates: candidates,
                cellSize: cellSize,
                onDragChanged: {
                    viewModel.dragChanged($0)
                },
                onDragEnd: {
                    viewModel.dragEnded($0)
                }
            )
            .animation(viewModel.snapBackAnimation, value: viewModel.dragOffset)
            .offset(viewModel.dragOffset)
            .padding()
        } else {
            EmptyView()
        }

    }
}
