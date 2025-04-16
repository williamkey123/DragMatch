//
//  CandidateView.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//

import SwiftUI

struct CandidateView: View {
    var candidates: (item1: Character, item2: Character, horizontal: Bool)
    var cellSize: CGFloat
    @ObservedObject var viewModel: GameViewModel

    // Animation used when the candidate view can't be dropped and needs to go back to it's original location
    let bounceBackAnimation: Animation = .spring(duration: 0.2, bounce: 0.3)

    var body: some View {
        ZStack(alignment: .center) {
            AnyStack(direction: candidates.horizontal ? .horizontal : .vertical, spacing: 5) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: cellSize, height: cellSize)
                    .overlay(Text("\(candidates.item1)"))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: GameView.coordinateSpaceName)
                            .onChanged { value in
                                viewModel.setHighlights(at: value.location)
                                viewModel.dragOffset = value.translation
                                viewModel.firstDragged = true
                            }
                            .onEnded { value in
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
                Rectangle()
                    .fill(Color.clear)
                    .overlay(Text("\(candidates.item2)"))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: GameView.coordinateSpaceName)
                            .onChanged { value in
                                viewModel.setHighlights(at: value.location)
                                viewModel.dragOffset = value.translation
                                viewModel.firstDragged = false
                            }
                            .onEnded { value in
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

            }
            .font(.system(size: 40))
        }
        .frame(width: 120, height: 120)
    }
}
