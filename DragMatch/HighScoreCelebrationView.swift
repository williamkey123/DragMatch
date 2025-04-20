//
//  HighScoreCelebrationView.swift
//  DragMatch
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

struct HighScoreCelebrationView: View {
    let highScore: Int
    @Binding var isPresented: Bool

    let animalEmojis = ["🐴", "🐷", "🐔", "🐮"]

    @State private var showOverlay = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red)
                .symbolEffect(.wiggle)
            Text("New High Score!")
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .foregroundColor(.white)
                .shadow(radius: 10)
                .opacity(showOverlay ? 1 : 0)
                .scaleEffect(showOverlay ? 1 : 0.8)
                .animation(.easeOut(duration: 0.5), value: showOverlay)

            Text("\(highScore)")
                .font(.system(size: 40, weight: .semibold))
                .shadow(radius: 5)
                .opacity(showOverlay ? 1 : 0)
                .animation(.easeOut.delay(0.2), value: showOverlay)

            WanderingAnimalsView()

            Button(action: {
                isPresented = false
            }) {
                Text("Dismiss")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
            .opacity(showOverlay ? 1 : 0)
            .animation(.easeOut.delay(0.5), value: showOverlay)
        }
        .padding(.top, 40)
        .onAppear {
            showOverlay = true
        }
        .onTapGesture {
            isPresented = false
        }
        .background (
            Color.black.opacity(showOverlay ? 0.1 : 0)
                .animation(.easeOut(duration: 0.5), value: showOverlay)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    HighScoreCelebrationView(highScore: 200, isPresented: .constant(true))
}
