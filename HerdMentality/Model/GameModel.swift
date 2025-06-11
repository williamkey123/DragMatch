//
//  GameModel.swift
//  HerdMentality
//
//  Created by William Key on 4/20/25.
//


import SwiftUI
import Combine

struct RemovedItemDetail {
    let item: Animal
    let index: GridIndex
}

enum Animal: CaseIterable {
    case horse, pig, chicken, cow

    var emoji: Character {
        switch self {
        case .horse: return "🐴"
        case .pig: return "🐷"
        case .chicken: return "🐔"
        case .cow: return "🐮"
        }
    }

    var audioFile: String {
        switch self {
        case .horse: return "horse"
        case .pig: return "pig"
        case .chicken: return "chicken"
        case .cow: return "cow"
        }
    }
}

struct GameModel {
    static let gridSize = 6

    private(set) var gridItems: [[Animal?]] = GameModel.emptyGrid
    private(set) var candidates: CandidatePair? = .init()
    private(set) var clearedAnimals: Int = 0
    private(set) var placedAnimals: Int = 0
    private(set) var isGameOver: Bool = false

    static var emptyGrid: [[Animal?]] {
        Array(
            repeating: Array(repeating: nil, count: GameModel.gridSize),
            count: GameModel.gridSize
        )
    }

    var stats: GameStats? = nil
    
    /// This places the current candidates at the specified GridIndex, if possible.
    /// - Parameter index: The index at which to place the current candidates.
    /// - Returns: Any items that have been removed.
    mutating func placeCandidates(at index: GridIndex) -> [RemovedItemDetail] {
        // Make sure there is space
        let locations = getItemPlacements(startingAt: index)

        if areValidPlacements(locations) {
            if locations.count != 2 {
                preconditionFailure()
            }
            gridItems[locations[0].row][locations[0].column] = candidates!.item1
            gridItems[locations[1].row][locations[1].column] = candidates!.item2
            candidates = nil
            placedAnimals += 2
            let removals = performRemovals()
            endOfTurnCleanUp()
            return removals
        } else {
            return []
        }
    }

    func canDropCandidates(at index: GridIndex) -> Bool {
        let locations = getItemPlacements(startingAt: index)
        return locations.count == 2 && areValidPlacements(locations)
    }

    // MARK: Private API

    // This will get the two locations that candidates should be dropped, based on where
    // the first candidate was dropped. It should always return the passed in location,
    // plus the one below or to the right of it, if there is one. It does not check for
    // if those spaces are available on the grid.
    private func getItemPlacements(
        startingAt startIndex: GridIndex
    ) -> [GridIndex] {
        guard let candidates else {
            return []
        }
        var toReturn: [GridIndex] = [startIndex]
        if candidates.axis == .horizontal, startIndex.column + 1 < Self.gridSize {
            toReturn.append((column: startIndex.column + 1, row: startIndex.row))
        } else if candidates.axis == .vertical, startIndex.row + 1 < Self.gridSize {
            toReturn.append((column: startIndex.column, row: startIndex.row + 1))
        }
        return toReturn
    }

    private func areValidPlacements(_ locations: [GridIndex]) -> Bool {
        if locations.count == 2 {
            return locations.allSatisfy {
                self.gridItems[$0.row][$0.column] == nil
            }
        } else {
            return false
        }
    }

    private mutating func regenerateCandidatePairs(axis: Axis? = nil) {
        candidates = CandidatePair(
            item1: Animal.allCases.randomElement()!,
            item2: Animal.allCases.randomElement()!,
            axis: axis ?? (Bool.random() ? .horizontal : .vertical)
        )
    }

    private mutating func performRemovals() -> [RemovedItemDetail] {
        let matches = findMatches()
        var uniqueMatches: [GridIndex] = []
        var removedItems: [RemovedItemDetail] = []

        for match in matches {
            if !uniqueMatches.contains(where: { $0 == match }) {
                uniqueMatches.append(match)
            }
        }
        uniqueMatches.forEach {
            if let item = gridItems[$0.row][$0.column] {
                removedItems.append(
                    RemovedItemDetail(item: item, index: $0)
                )
            }
            gridItems[$0.row][$0.column] = nil
        }

        self.clearedAnimals += uniqueMatches.count
        return removedItems
    }

    private mutating func endOfTurnCleanUp() {
        switch (hasHorizontalSpace, hasVerticalSpace) {
        case (true, true):
            // Regenerate candidates in any orientation
            regenerateCandidatePairs()
        case (false, true):
            // Only vertical space, so only generate a candidate that fits that criteria
            regenerateCandidatePairs(axis: .vertical)
        case (true, false):
            // Only horizontal space, so only generate a candidate that fits that criteria
            regenerateCandidatePairs(axis: .horizontal)
        case (false, false):
            isGameOver = true
            if let stats, placedAnimals > stats.highScore {
                stats.highScore = placedAnimals
            }
            stats?.gamesPlayed += 1
        }
    }

    private var hasHorizontalSpace: Bool {
        // check to make sure there are at least two empty horizontal squares in gridItems
        for row in 0..<gridItems.count {
            for column in 0..<gridItems[row].count - 1 {
                if gridItems[row][column] == nil && gridItems[row][column + 1] == nil {
                    // we found two squares, return
                    return true
                }
            }
        }
        return false
    }

    private var hasVerticalSpace: Bool {
        // check to make sure there are at least two empty vertical squares in gridItems
        for row in 0..<gridItems.count - 1 {
            for column in 0..<gridItems[row].count {
                if gridItems[row][column] == nil && gridItems[row + 1][column] == nil {
                    return true
                }
            }
        }
        return false
    }

    func findMatches() -> [GridIndex] {
        let numRows = GameModel.gridSize
        guard numRows > 0 else { return [] }
        let numCols = GameModel.gridSize
        var matches = [GridIndex]()

        // Horizontal check
        for row in 0..<numRows {
            var col = 0
            while col < numCols {
                guard let current = gridItems[row][col] else {
                    col += 1
                    continue
                }
                let startCol = col
                while col < numCols && gridItems[row][col] == current {
                    col += 1
                }
                if col - startCol >= 3 {
                    for c in startCol..<col {
                        matches.append((column: c, row: row))
                    }
                }
            }
        }

        // Vertical check
        for col in 0..<numCols {
            var row = 0
            while row < numRows {
                guard let current = gridItems[row][col] else {
                    row += 1
                    continue
                }
                let startRow = row
                while row < numRows && gridItems[row][col] == current {
                    row += 1
                }
                if row - startRow >= 3 {
                    for r in startRow..<row {
                        matches.append((column: col, row: r))
                    }
                }
            }
        }

        return matches
    }
}
