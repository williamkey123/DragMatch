//
//  GameView.swift
//  HerdMentality
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

struct GameView: View {
    @State var viewModel: GameViewModel = .init()

    @EnvironmentObject var stats: GameStats
    @State var countLocation: CGPoint = .zero
    let gridSize = GameModel.gridSize
    static let coordinateSpaceName: NamedCoordinateSpace = .named("gameboard")
    let gameFramePadding: CGFloat = 20

    func cellSize(for size: CGSize) -> CGFloat {
        let longer = max(size.width, size.height)
        let shorter = min(size.width, size.height)
        let squareSize = min(shorter, longer / 2)
        return squareSize / CGFloat(gridSize)
    }

    func restartGame() {
        self.viewModel.restartGame()
    }

    var body: some View {
        GeometryReader { geo in
            let cellSize = cellSize(for: geo.size)
            let isPortrait = geo.size.width < geo.size.height

            ZStack(alignment: .center) {
                if let itemDetails = viewModel.clearedItemDetails {
                    RemovedItemDetailsView(
                        count: itemDetails.count,
                        location: itemDetails.location,
                        finalTextPosition: self.countLocation,
                        onComplete: viewModel.completedRemovalAnimation
                    )
                    .zIndex(10)
                }

                FramedView(
                    axis: isPortrait ? .vertical : .horizontal,
                    topAlignment: .center,
                    leadingAlignment: .center,
                    bottomAlignment: viewModel.game.isGameOver ? .center : .top,
                    trailingAlignment: .center,
                    animation: .linear
                ) {
                    GameBoardGridView(
                        cellSize: cellSize,
                        gridSize: gridSize,
                        viewModel: viewModel
                    )
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .scale(1.02)
                                .fill(Color.gridBorder)
                        )
                } topOrLeadingContent: {
                    StatisticsView(
                        placedAnimals: viewModel.game.placedAnimals,
                        clearedAnimals: viewModel.displayedClearedAnimals,
                        countLocation: $countLocation
                    )
                } bottomOrTrailingContent: {
                    BottomView(
                        viewModel: viewModel,
                        cellSize: cellSize,
                        onRestart: restartGame
                    )
                }
            }
            .coordinateSpace(Self.coordinateSpaceName)
        }
        .padding(gameFramePadding)
        .onAppear {
            viewModel.setStats(stats)
        }
        .blur(radius: viewModel.isShowingHighScoreOverlay ? 20 : 0)
        .overlay {
            if viewModel.isShowingHighScoreOverlay {
                HighScoreCelebrationView(
                    highScore: stats.highScore,
                    isPresented: $viewModel.isShowingHighScoreOverlay
                )
            } else {
                EmptyView()
            }
        }
        .animation(.default, value: viewModel.isShowingHighScoreOverlay)
    }
}

#Preview {
    GameView()
        .environmentObject(GameStats.preview)
}








