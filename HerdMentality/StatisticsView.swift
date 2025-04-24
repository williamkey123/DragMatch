//
//  StatisticsView.swift
//  HerdMentality
//
//  Created by William Key on 4/16/25.
//


import SwiftUI

struct StatisticsView: View {
    let placedAnimals: Int
    let clearedAnimals: Int
    @Binding var countLocation: CGPoint

    let numericAnimation: Animation = .easeInOut

    @ViewBuilder func statsWithFont(size: CGFloat)-> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(placedAnimals)")
                    .contentTransition(.numericText())
                    .animation(numericAnimation, value: placedAnimals)
                Text("Animals Placed")
            }
            .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(clearedAnimals)")
                    .contentTransition(.numericText())
                    .animation(numericAnimation, value: clearedAnimals)
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: ViewPositionPreferenceKey.self,
                            value: geo.frame(in: GameView.coordinateSpaceName).center
                        )
                        .onAppear {
                            // This is a weird hack because some systems aren't catching this on the initial load
                            DispatchQueue.main.async {
                                self.countLocation = geo.frame(in: GameView.coordinateSpaceName).center
                            }
                        }
                    })
                    .onPreferenceChange(ViewPositionPreferenceKey.self) { value in
                        self.countLocation = value
                    }
                Text("Animals Cleared")
            }
            .lineLimit(1)
        }
        .font(.system(size: size, weight: .bold))
        .padding(.horizontal, 12)
        .padding(.vertical, 48)
    }

    var body: some View {
        ViewThatFits {
            statsWithFont(size: 40)
            statsWithFont(size: 30)
            statsWithFont(size: 24)
            statsWithFont(size: 18)
            statsWithFont(size: 16)
        }
    }
}
