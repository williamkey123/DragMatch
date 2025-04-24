//
//  GameViewModel.swift
//  HerdMentality
//
//  Created by William Key on 4/4/25.
//


import SwiftUI
import Combine

typealias GridIndex = (column: Int, row: Int)

@Observable final class GameViewModel {
    // MARK: View related code
    var displayedGridItems: [[Animal?]] = GameModel.emptyGrid
    var cellFrames: [GridCell] = []
    private(set) var dragOffset: CGSize = .zero
    private(set) var highlightedCells: [GridIndex] = []
    private(set) var clearedItemDetails: ClearedItemDetails? = nil
    private(set) var displayedClearedAnimals: Int = 0
    var isShowingHighScoreOverlay: Bool = false
    var snapBackAnimation: Animation? = nil
    private(set) var game: GameModel

    private var stats: GameStats? = nil
    private var cancellables: Set<AnyCancellable> = []

    // MARK: PublicAPI

    init(game: GameModel? = nil) {
        self.game = game ?? .init()
        self.displayedGridItems = self.game.gridItems
    }

    func restartGame() {
        self.game = .init()
        self.displayedGridItems = self.game.gridItems
        self.displayedClearedAnimals = 0
    }

    func setStats(_ stats: GameStats) {
        self.stats = stats
    }

    func dragChanged(_ dragData: CandidateDragData) {
        if let firstIndex = self.getGridLocation(at: dragData.point),
           game.canDropCandidates(at: firstIndex),
           let secondIndex = getSecondGridLocation(after: firstIndex, in: game)
        {
            // they can be dropped here, add them to the array of
            // highlighted cells
            highlightedCells = [firstIndex, secondIndex]
        } else {
            highlightedCells = []
        }
        dragOffset = dragData.offset
    }

    func dragEnded(_ dragData: CandidateDragData) {
        highlightedCells = []
        if let firstIndex = self.getGridLocation(at: dragData.point),
           game.canDropCandidates(at: firstIndex)
        {
            let removed = game.placeCandidates(at: firstIndex)
            if removed.isEmpty {
                self.displayedGridItems = self.game.gridItems
            } else {
                self.handleRemovedItems(removed)
            }
            self.dragOffset = .zero
        } else {
            snapBackAnimation = .easeInOut(duration: 0.3)
            self.dragOffset = .zero
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.snapBackAnimation = nil
            }
        }
    }

    // MARK: Private API

    private func handleRemovedItems(_ removed: [RemovedItemDetail]) {
        // We want to temporarily place the removed items on the
        // grid so we can animate them going away
        var newGridItems = game.gridItems
        removed.forEach {
            newGridItems[$0.index.row][$0.index.column] = $0.item
        }
        self.displayedGridItems = newGridItems

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.displayedGridItems = self.game.gridItems

            let removedCount = removed.count
            if removedCount > 0 {
                let center: CGPoint = removed.map { match in
                    let cell = self.cellFrames.first { cellFrame in
                        cellFrame.row == match.index.row && cellFrame.column == match.index.column
                    }
                    return cell?.frame.center ?? .zero
                }.reduce(.zero) { sum, point in
                    CGPoint(
                        x: sum.x + point.x / CGFloat(removedCount),
                        y: sum.y + point.y / CGFloat(removedCount)
                    )
                }

                let items = Array(Set(removed.map { $0.item }))
                if items.count == 1 {
                    AnimalSoundPlayer.shared.playSound(for: items[0])
                } else if items.count == 2 {
                    AnimalSoundPlayer.shared.playSound(for: items[0], then: items[1])
                }

                self.clearedItemDetails = ClearedItemDetails(
                    count: removedCount,
                    location: center
                )
            }
        }
    }

    func completedRemovalAnimation() {
        self.displayedClearedAnimals = game.clearedAnimals
        self.clearedItemDetails = nil
    }

    private func getGridLocation(at point: CGPoint) -> GridIndex? {
        return cellFrames.filter { $0.frame.contains(point) }.first.map {
            ($0.column, $0.row)
        }
    }

    private func getSecondGridLocation(
        after firstIndex: GridIndex,
        in game: GameModel
    ) -> GridIndex? {
        if let candidates = game.candidates {
            let otherItem: GridIndex
            switch candidates.axis {
            case .horizontal:
                otherItem = (firstIndex.column + 1, firstIndex.row)
                if otherItem.column >= GameModel.gridSize {
                    return nil
                }
            case .vertical:
                otherItem = (firstIndex.column, firstIndex.row + 1)
                if otherItem.row >= GameModel.gridSize {
                    return nil
                }
            }
            return otherItem
        } else {
            return nil
        }
    }
}

struct ClearedItemDetails {
    let count: Int
    let location: CGPoint
}

