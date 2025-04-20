//
//  WanderingAnimalsView.swift
//  DragMatch
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

struct WanderingAnimalsView: View {
    private var positioningCoordinator = AnimalPosotioningCoordinator()

    @State private var animals: [Animal]

    struct Animal: Hashable {
        let id = UUID()
        let text: String
    }

    init(animalCount: Int = 12) {
        animals = (0..<animalCount).map { _ in
            Animal(text: "\(GameViewModel.items.randomElement()!)")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Go through all animals
                ForEach(animals, id: \.self) { animal in
                    GrazingAnimal(
                        emoji: animal.text,
                        containerSize: geometry.size,
                        positioningCoordinator: positioningCoordinator
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct GrazingAnimal: View {
    let emoji: String
    let containerSize: CGSize
    let positioningCoordinator: AnimalPosotioningCoordinator

    @State var id = UUID()

    let minStepLength: CGFloat = 12
    let maxStepLength: CGFloat = 30
    let maxYVariation: CGFloat = 0.5

    let padding: CGFloat = 40

    let grazingProbability: Double = 0.05

    @State private var position: CGPoint = .zero
    @State private var hopOffset: CGSize = .zero
    @State private var rotationAngle: Angle = .zero
    @State private var grazing = false
    @State private var facingLeft = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 45))
            .rotationEffect(rotationAngle)
            .scaleEffect(x: facingLeft ? 1 : -1, y: 1)
            .position(
                x: position.x + hopOffset.width,
                y: position.y + hopOffset.height
            )
            .onAppear {
                position = initialPosition()
                performNextAction()
            }
    }

    private func initialPosition() -> CGPoint {
        var proposal = CGPoint(
            x: CGFloat.random(in: padding...(containerSize.width - padding)),
            y: CGFloat.random(in: padding...(containerSize.height - padding))
        )
        for _ in 0..<100 {
            if positioningCoordinator.isPositionAvailable(
                for: id,
                proposed: proposal,
                minimumDistance: padding + maxStepLength
            ) {
                break
            } else {
                proposal = CGPoint(
                    x: CGFloat.random(in: padding...(containerSize.width - padding)),
                    y: CGFloat.random(in: padding...(containerSize.height - padding))
                )
            }
        }
        positioningCoordinator.updatePosition(id: id, to: proposal)
        return proposal
    }

    private func performNextAction() {
        if grazing {
            performGrazing()
        } else {
            // Direction of movement
            let xDistance = CGFloat.random(in: minStepLength...maxStepLength)
            let yDistance = CGFloat.random(in: minStepLength * maxYVariation...maxStepLength * maxYVariation)
            var dx = Bool.random() ? xDistance : -xDistance
            var dy = Bool.random() ? yDistance : -yDistance

            if position.x + dx < 40 || position.x + dx > containerSize.width - 40 {
                dx = -dx
            }

            if position.y + dy < 40 || position.y + dy > containerSize.height - 40 {
                dy = -dy
            }

            let proposedPosition = CGPoint(
                x: position.x + dx,
                y: position.y + dy
            )
            if positioningCoordinator.isPositionAvailable(
                for: id,
                proposed: proposedPosition,
                minimumDistance: padding + maxStepLength
            ) {
                performHop(to: proposedPosition)
            } else {
                performGrazing()
            }
        }
    }

    private func performHop(to newPosition: CGPoint) {
        let stepDuration = Double.random(in: 0.4...0.6)

        facingLeft = newPosition.x < position.x

        // Create hop arc using sine wave over time
        let frameCount = 30
        let arcHeight: CGFloat = 10
        let xStep = (newPosition.x - position.x) / CGFloat(frameCount)
        let yStep = (newPosition.y - position.y) / CGFloat(frameCount)

        var currentFrame = 0

        Timer.scheduledTimer(withTimeInterval: stepDuration / Double(frameCount), repeats: true) { timer in
            if currentFrame >= frameCount {
                timer.invalidate()
                position = newPosition
                hopOffset = .zero
                rotationAngle = .zero

                grazing = Bool.random(probability: grazingProbability)
                performNextAction()
            } else {
                let progress = Double(currentFrame) / Double(frameCount)
                let arc = -sin(progress * .pi) * arcHeight
                hopOffset = CGSize(
                    width: xStep * CGFloat(currentFrame),
                    height: yStep * CGFloat(currentFrame) + CGFloat(arc)
                )
                rotationAngle = .degrees(progress < 0.5 ? 20 * progress : 20 * (1 - progress))
                currentFrame += 1
            }
        }
    }

    private func performGrazing() {
        let wiggleAmount: Double = Double.random(in: 5...10)
        let singleWiggleDuration = 0.14
        let wiggleCount = 7
        var completedWiggles = 0
        var wiggleDirection: Double = 1

        Timer.scheduledTimer(withTimeInterval: singleWiggleDuration, repeats: true) { timer in
            withAnimation(.spring(duration: singleWiggleDuration)) {
                rotationAngle = .degrees(wiggleAmount * wiggleDirection)
            }
            wiggleDirection *= -1
            completedWiggles += 1

            if completedWiggles >= wiggleCount {
                timer.invalidate()
                withAnimation(.easeOut(duration: 0.3)) {
                    rotationAngle = .zero
                }
                grazing = false
                performNextAction()
            }
        }
    }
}

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}

class AnimalPosotioningCoordinator {
    var positions: [UUID: [CGPoint]] = [:]

    func updatePosition(id: UUID, to newPosition: CGPoint) {
        if var itemPositions = positions[id] {
            itemPositions.append(newPosition)
            if itemPositions.count > 2 {
                itemPositions.removeFirst()
            }
            positions[id] = itemPositions
        } else {
            positions[id] = [newPosition]
        }
    }

    func isPositionAvailable(
        for id: UUID,
        proposed: CGPoint,
        minimumDistance: CGFloat
    ) -> Bool {
        for (otherID, itemPositions) in positions where otherID != id {
            let hasConflictingPosition = itemPositions.contains {
                hypot(proposed.x - $0.x, proposed.y - $0.y) < minimumDistance
            }
            if hasConflictingPosition {
                return false
            }
        }
        return true
    }
}

#Preview {
    WanderingAnimalsView()
}
