//
//  AboutView.swift
//  DragMatch
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var stats: GameStats

    @State var showingResetConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Game Description
                    Section {
                        Text("🐮 Here comes the herd!")
                            .font(.title2)
                            .bold()

                        Text("""
                            In Herd Mentality, animals arrive two by two, and it’s your \
                            job to place them on the farm.

                            Line up three or more of the same animal in a row \
                            or column and they’ll happily trot away, making \
                            space for more arrivals.

                            But be careful—once the farm fills up and there’s \
                            no room left, it’s game over! So think ahead and \
                            keep the herd moving!
                            """
                        )
                    }

                    // Developer Info
                    Section {
                        Text("👋 About the Developer")
                            .font(.title2)
                            .bold()

                        Text(
                            """
                            Herd Mentality was created by William Key, an iOS engineer \
                            who loves playful design, puzzly mechanics, and \
                            joyful little animations.
                            """
                        )
                    }

                    // Links
                    Section {
                        Link(
                            "🌐 Visit Website",
                            destination: URL(
                                string: "https://www.williamkey.net"
                            )!
                        )
                        Link(
                            "🔗 LinkedIn",
                            destination: URL(
                                string: "https://www.linkedin.com/in/willclarkedotnet/"
                            )!
                        )
                    }

                    if stats.highScore > 0 || stats.gamesPlayed > 0 {
                        // Reset Stats Button
                        Section {
                            Button(role: .destructive) {
                                showingResetConfirmation = true
                            } label: {
                                Text("Reset Stats")
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .alert(
                                "Reset Stats?",
                                isPresented: $showingResetConfirmation
                            ) {
                                Button("Reset", role: .destructive) {
                                    resetStats()
                                }
                                Button("Cancel", role: .cancel) { }
                            } message: {
                                Text(
                                    """
                                    This will erase your high score and any \
                                    saved progress.
                                    """
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("About Herd Mentality")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetStats() {
        stats.reset()
    }
}

#Preview {
    AboutView()
        .environmentObject(GameStats.preview)
}
