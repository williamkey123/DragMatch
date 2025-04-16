//
//  GameView.swift
//  DragMatch
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    let cellSpacing: CGFloat = 0
    let numericAnimation: Animation = .easeInOut
    @State var countLocation: CGPoint = .zero
    let gridSize = GameViewModel.gridSize
    static let coordinateSpaceName: NamedCoordinateSpace = .named("gameboard")

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width, geo.size.height) / CGFloat(gridSize)
            ZStack(alignment: .center) {
                VStack(spacing: 20) {
                    Spacer()
                    VStack(spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(viewModel.placedAnimals)")
                                .contentTransition(.numericText())
                                .animation(numericAnimation, value: viewModel.placedAnimals)
                            Text("Animals Placed")
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(viewModel.displayedClearedAnimals)")
                                .contentTransition(.numericText())
                                .animation(numericAnimation, value: viewModel.displayedClearedAnimals)
                                .background(GeometryReader { geo in
                                    Color.clear.preference(
                                        key: CountPositionPreferenceKey.self,
                                        value: geo.frame(in: Self.coordinateSpaceName).center
                                    )
                                })
                                .onPreferenceChange(CountPositionPreferenceKey.self) { value in
                                    self.countLocation = value
                                }
                            Text("Animals Cleared")
                        }
                    }
                    .font(.headline)
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<gridSize, id: \.self) { row in
                            HStack(spacing: cellSpacing) {
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
                    
                    if viewModel.isGameOver {
                        VStack(spacing: 12) {
                            Text("Game Over!")
                                .font(.headline)
                            
                            Button("Restart") {
                                viewModel.restartGame()
                            }
                            .fontWeight(.bold)
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(width: 120, height: 120)
                    } else if let candidates = viewModel.candidates {
                        CandidateView(candidates: candidates, cellSize: cellSize, viewModel: viewModel)
                            .offset(viewModel.dragOffset)
                            .onTapGesture(count: 2) {
                                viewModel.regenerateCandidatePairs()
                            }
                    } else {
                        Rectangle().fill(Color.clear).frame(height: 120)
                    }

                    Spacer()
                }
                if let itemDetails = viewModel.clearedItemDetails {
                    RemovedItemDetailsView(
                        count: itemDetails.count,
                        location: itemDetails.location,
                        finalTextPosition: self.countLocation
                    ) {
                        viewModel.completedRemovalAnimation()
                    }
                }
            }
            .coordinateSpace(Self.coordinateSpaceName)
        }
        .padding(.horizontal, 20)
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
