//
//  HerdMentalityApp.swift
//  HerdMentality
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

@main
struct HerdMentalityApp: App {
    @StateObject private var stats = GameStats()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stats)
        }
    }
}
