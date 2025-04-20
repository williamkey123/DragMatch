//
//  GameStats.swift
//  DragMatch
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

class GameStats: ObservableObject {
    private enum Keys {
        static let highScore = "highScore"
        static let gamesPlayed = "gamesPlayed"
    }

    private let defaults: UserDefaults

    @Published var highScore: Int {
        didSet {
            defaults.set(highScore, forKey: Keys.highScore)
        }
    }

    @Published var gamesPlayed: Int {
        didSet {
            defaults.set(gamesPlayed, forKey: Keys.gamesPlayed)
        }
    }

    @Published var test: Int = 5

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.highScore = defaults.integer(forKey: Keys.highScore)
        self.gamesPlayed = defaults.integer(forKey: Keys.gamesPlayed)
    }

    func reset() {
        highScore = 0
        gamesPlayed = 0
    }

    /// Preconfigured instance for use in SwiftUI previews
    static var preview: GameStats {
        let previewDefaults = UserDefaults(suiteName: "GameStatsPreview")!
        previewDefaults.set(23, forKey: Keys.highScore)
        previewDefaults.set(2, forKey: Keys.gamesPlayed)
        return GameStats(defaults: previewDefaults)
    }
}
