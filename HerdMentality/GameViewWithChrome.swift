//
//  GameViewWithChrome.swift
//  HerdMentality
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

struct GameViewWithChrome: View {
    @State var displayedScore: Int = 0
    @EnvironmentObject var stats: GameStats
    @State var isShowingInfo = false

    var body: some View {
        GameView()
            .background(Color.gameBackground)
            .safeAreaInset(edge: .top) {
                ZStack(alignment: .center) {
                    HStack {
                        HStack(spacing: 3) {
                            Text("High Score:")
                            Text("\(displayedScore)")
                        }
                        .font(.callout)
                        .foregroundStyle(.primary.opacity(0.8))
                        Spacer()
                    }
                    .padding(.leading)

                    VStack {
                        Text("Herd Mentality").font(.headline)
                    }

                    HStack {
                        Spacer()
                        Button {
                            self.isShowingInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }

                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color.gridSquare)
            }
            .onAppear {
                displayedScore = stats.highScore
            }
            .onReceive(stats.$highScore) { newHighScore in
                displayedScore = newHighScore
            }
            .sheet(isPresented: $isShowingInfo) {
                AboutView()
            }
    }
}

#Preview {
    GameViewWithChrome()
        .environmentObject(GameStats.preview)
}
