//
//  GameView.swift
//  DragMatch
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    @State var countLocation: CGPoint = .zero
    let gridSize = GameViewModel.gridSize
    static let coordinateSpaceName: NamedCoordinateSpace = .named("gameboard")
    let gameFramePadding: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width, geo.size.height) / CGFloat(gridSize)
            let isPortrait = geo.size.width < geo.size.height
            let gridFrameSize = cellSize * CGFloat(gridSize)
            let extraSpace = ((isPortrait ? geo.size.height : geo.size.width) - gridFrameSize) / 4

            ZStack(alignment: .center) {
                if let itemDetails = viewModel.clearedItemDetails {
                    RemovedItemDetailsView(
                        count: itemDetails.count,
                        location: itemDetails.location,
                        finalTextPosition: self.countLocation,
                        onComplete: viewModel.completedRemovalAnimation
                    )
                }

                GameBoardGridView(cellSize: cellSize, gridSize: gridSize, viewModel: viewModel)

                StatisticsView(
                    placedAnimals: viewModel.placedAnimals,
                    clearedAnimals: viewModel.displayedClearedAnimals,
                    countLocation: $countLocation
                )
                .offset(
                    x: isPortrait ? 0 : -(gridFrameSize/2 + extraSpace),
                    y: isPortrait ? -(gridFrameSize/2 + extraSpace) : 0
                )


                BottomView(viewModel: viewModel, cellSize: cellSize)
                    .offset(
                        x: isPortrait ? 0 : gridFrameSize/2 + extraSpace,
                        y: isPortrait ? (gridFrameSize/2 + extraSpace) : 0
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(Self.coordinateSpaceName)
        }
        .padding(gameFramePadding)
        .ignoresSafeArea()
    }
}

#Preview {
    GameView()
}

struct CountPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct BottomView: View {
    @ObservedObject var viewModel: GameViewModel
    let cellSize: CGFloat

    // Animation used when the candidate view can't be dropped and needs to go back to it's original location
    let bounceBackAnimation: Animation = .spring(duration: 0.2, bounce: 0.3)

    var body: some View {
        if viewModel.isGameOver {
            VStack(spacing: 12) {
                Text("Game Over!")
                    .font(.headline)

                Button("Restart", action: viewModel.restartGame)
                    .fontWeight(.bold)
                    .buttonStyle(.borderedProminent)
            }
            .frame(width: 120, height: 120)
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
        } else {
            Rectangle().fill(Color.clear).frame(height: 120)
        }

    }
}

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

struct StatisticsView: View {
    let placedAnimals: Int
    let clearedAnimals: Int
    @Binding var countLocation: CGPoint

    let numericAnimation: Animation = .easeInOut

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(placedAnimals)")
                    .contentTransition(.numericText())
                    .animation(numericAnimation, value: placedAnimals)
                Text("Animals Placed")
            }
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(clearedAnimals)")
                    .contentTransition(.numericText())
                    .animation(numericAnimation, value: clearedAnimals)
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: CountPositionPreferenceKey.self,
                            value: geo.frame(in: GameView.coordinateSpaceName).center
                        )
                    })
                    .onPreferenceChange(CountPositionPreferenceKey.self) { value in
                        self.countLocation = value
                    }
                Text("Animals Cleared")
            }
        }
        .font(.headline)
    }
}
