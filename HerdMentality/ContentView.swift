//
//  ContentView.swift
//  DragMatch
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameViewWithChrome()
    }
}

#Preview {
    ContentView()
        .environmentObject(GameStats.preview)
}
