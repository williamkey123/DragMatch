//
//  AnimalSoundPlayer.swift
//  HerdMentality
//
//  Created by William Key on 4/23/25.
//

import AVFoundation

final class AnimalSoundPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = AnimalSoundPlayer()

    private var players: [Animal: AVAudioPlayer] = [:]
    private var currentPlayer: AVAudioPlayer?
    private var queuedAnimal: Animal?

    private override init() {
        super.init()
        loadSounds()
    }

    private func loadSounds() {
        for animal in [Animal.cow, .chicken, .horse, .pig] {
            if let url = Bundle.main.url(
                forResource: animal.audioFile,
                withExtension: "mp3"
            ) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.delegate = self
                    player.prepareToPlay()
                    players[animal] = player
                } catch {
                    print("Error loading sound for \(animal): \(error)")
                }
            } else {
                print("Sound file not found for \(animal)")
            }
        }
    }

    func playSound(for first: Animal, then second: Animal? = nil) {
        // Stop current sound and clear queued
        currentPlayer?.stop()
        queuedAnimal = nil

        guard let firstPlayer = players[first] else { return }

        queuedAnimal = second
        currentPlayer = firstPlayer
        currentPlayer?.delegate = self
        currentPlayer?.currentTime = 0
        currentPlayer?.play()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let next = queuedAnimal, let nextPlayer = players[next] {
            queuedAnimal = nil
            currentPlayer = nextPlayer
            currentPlayer?.delegate = self
            currentPlayer?.currentTime = 0
            currentPlayer?.play()
        } else {
            currentPlayer = nil
        }
    }

    static func playSound(for first: Animal, then second: Animal? = nil) {
        shared.playSound(for: first, then: second)
    }
}
