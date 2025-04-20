//
//  GameViewModel.swift
//  HerdMentality
//
//  Created by William Key on 4/4/25.
//

import Foundation

final class GameViewModel: ObservableObject {
    static let items: [Character] = ["🐴", "🐷", "🐔", "🐮"]
    static let gridSize = 6

    @Published private(set) var gridItems: [[String]] = Array(
        repeating: Array(repeating: "", count: GameViewModel.gridSize),
        count: GameViewModel.gridSize
    )
    @Published var cellFrames: [GridCell] = []
    @Published private(set) var candidates: (item1: Character, item2: Character, horizontal: Bool)? = (
        item1: GameViewModel.items.randomElement()!,
        item2: GameViewModel.items.randomElement()!,
        horizontal: Bool.random()
    )
    @Published var dragOffset: CGSize = .zero
    @Published private(set) var highlightedCells: [(column: Int, row: Int)] = []
    @Published var firstDragged: Bool? = nil
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var clearedAnimals: Int = 0
    @Published private(set) var displayedClearedAnimals: Int = 0
    @Published private(set) var placedAnimals: Int = 0
    @Published private(set) var clearedItemDetails: ClearedItemDetails? = nil
    @Published var isShowingHighScoreOverlay: Bool = false
    
    private var stats: GameStats? = nil

    func setStats(_ stats: GameStats) {
        self.stats = stats
    }

    func canDropCandidates(at point: CGPoint) -> Bool {
        return canDropCandidatesOnLocations(getGridLocations(at: point))
    }

    private func canDropCandidatesOnLocations(_ locations: [(column: Int, row: Int)]) -> Bool {
        return locations.count == 2 && areEmpty(items: locations) && candidates != nil
    }

    func dropCandidates(at location: CGPoint) {
        // determine if the candidates can be placed at the coordinate, and if so, add them
        let locations = getGridLocations(at: location)
        if canDropCandidatesOnLocations(locations), let candidates {
            if firstDragged == true {
                gridItems[locations[0].row][locations[0].column] = String(candidates.item1)
                gridItems[locations[1].row][locations[1].column] = String(candidates.item2)
            } else {
                gridItems[locations[0].row][locations[0].column] = String(candidates.item2)
                gridItems[locations[1].row][locations[1].column] = String(candidates.item1)
            }
            self.candidates = nil
            self.placedAnimals += 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performRemovals()
                self.endOfTurnCleanUp()
            }
        }
        highlightedCells = []
    }

    func restartGame() {
        gridItems = Array(
            repeating: Array(repeating: "", count: GameViewModel.gridSize),
            count: GameViewModel.gridSize
        )
        regenerateCandidatePairs()
        placedAnimals = 0
        clearedAnimals = 0
        displayedClearedAnimals = 0
        isGameOver = false
    }

    func regenerateCandidatePairs(horizontal: Bool? = nil) {
        candidates = (
            item1: GameViewModel.items.randomElement()!,
            item2: GameViewModel.items.randomElement()!,
            horizontal: horizontal ?? Bool.random()
        )
    }

    func findMatches() -> [(Int, Int)] {
        let numRows = Self.gridSize
        guard numRows > 0 else { return [] }
        let numCols = Self.gridSize
        var matches = [(Int, Int)]()

        // Horizontal check
        for row in 0..<numRows {
            var col = 0
            while col < numCols {
                let current = gridItems[row][col]
                if current.isEmpty {
                    col += 1
                    continue
                }
                let startCol = col
                while col < numCols && gridItems[row][col] == current {
                    col += 1
                }
                if col - startCol >= 3 {
                    for c in startCol..<col {
                        matches.append((row, c))
                    }
                }
            }
        }

        // Vertical check
        for col in 0..<numCols {
            var row = 0
            while row < numRows {
                let current = gridItems[row][col]
                if current.isEmpty {
                    row += 1
                    continue
                }
                let startRow = row
                while row < numRows && gridItems[row][col] == current {
                    row += 1
                }
                if row - startRow >= 3 {
                    for r in startRow..<row {
                        matches.append((r, col))
                    }
                }
            }
        }

        return matches
    }

    private func performRemovals() {
        let matches = findMatches()
        var uniqueMatches: [(Int, Int)] = []

        for match in matches {
            if !uniqueMatches.contains(where: { $0 == match }) {
                uniqueMatches.append(match)
            }
        }
        uniqueMatches.forEach {
            gridItems[$0.0][$0.1] = ""
        }

        let count = uniqueMatches.count
        if count > 0 {
            let center: CGPoint = uniqueMatches.map { match in
                let cell = cellFrames.first { cellFrame in
                    cellFrame.row == match.0 && cellFrame.column == match.1
                }
                return cell?.frame.center ?? .zero
            }.reduce(.zero) { sum, point in
                CGPoint(x: sum.x + point.x / CGFloat(count), y: sum.y + point.y / CGFloat(count))
            }
            
            self.clearedItemDetails = ClearedItemDetails(
                count: count,
                location: center
            )
        }
        self.clearedAnimals += count
    }

    private var hasHorizontalSpace: Bool {
        // check to make sure there are at least two empty horizontal squares in gridItems
        for row in 0..<gridItems.count {
            for column in 0..<gridItems[row].count - 1 {
                if gridItems[row][column].isEmpty && gridItems[row][column + 1].isEmpty {
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
                if gridItems[row][column].isEmpty && gridItems[row + 1][column].isEmpty {
                    return true
                }
            }
        }
        return false
    }

    private func endOfTurnCleanUp() {
        switch (hasHorizontalSpace, hasVerticalSpace) {
        case (true, true):
            // Regenerate candidates in any orientation
            regenerateCandidatePairs()
        case (false, true):
            // Only horizontal space, so only generate a candidate that fits that criteria
            regenerateCandidatePairs(horizontal: false)
        case (true, false):
            // Only vertical space, so only generate a candidate that fits that criteria
            regenerateCandidatePairs(horizontal: true)
        case (false, false):
            isGameOver = true
            if let stats, placedAnimals > stats.highScore {
                isShowingHighScoreOverlay = true
                stats.highScore = placedAnimals
            }
            stats?.gamesPlayed += 1
        }
    }

    func setHighlights(at point: CGPoint) {
        // determine if the candidates can be placed at the coordinate, and if so, highlight them
        let items = getGridLocations(at: point)
        if items.count == 2 {
            if areEmpty(items: items) {
                highlightedCells = items
            } else {
                highlightedCells = []
            }
        } else {
            highlightedCells = []
        }
    }

    func completedRemovalAnimation() {
        self.displayedClearedAnimals = clearedAnimals
        self.clearedItemDetails = nil
    }

    private func areEmpty(items: [(column: Int, row: Int)]) -> Bool {
        return items.allSatisfy { gridItems[$0.row][$0.column].isEmpty }
    }

    private func getGridLocations(at point: CGPoint) -> [(column: Int, row: Int)] {
        let item: (column: Int, row: Int)? = cellFrames.filter { $0.frame.contains(point) }.first.map {
            ($0.column, $0.row)
        }

        if let item, let firstDragged, let candidates {
            let otherItem: (column: Int, row: Int)
            switch (candidates.horizontal, firstDragged) {
            case (true, true): // it's horizontal, the first is being dragged
                otherItem = (item.column + 1, item.row)
                if otherItem.column >= GameViewModel.gridSize {
                    return []
                }
            case (true, false): // it's horizontal, the second item is being dragged
                otherItem = (item.column - 1, item.row)
                if otherItem.column < 0 {
                    return []
                }
            case (false, true): // it's vertical, the first item is being dragged
                otherItem = (item.column, item.row + 1)
                if otherItem.row >= GameViewModel.gridSize {
                    return []
                }
            case (false, false): // it's vertical and second item is being dragged
                otherItem = (item.column, item.row - 1)
                if otherItem.row < 0 {
                    return []
                }
            }
            return [item, otherItem]
        } else {
            return []
        }
    }
}

struct ClearedItemDetails {
    let count: Int
    let location: CGPoint
}

