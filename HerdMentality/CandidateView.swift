//
//  CandidateView.swift
//  HerdMentality
//
//  Created by William Key on 4/15/25.
//

import SwiftUI

/// Data about the candidate's drag
struct CandidateDragData {
    /// The offset of the drag from it's initial position
    let offset: CGSize
    /// The location of the first candidate in the game view
    let point: CGPoint
}

struct CandidateView: View {
    let candidates: CandidatePair
    let cellSize: CGFloat
    let onDragChanged: (CandidateDragData) -> Void
    let onDragEnd: (CandidateDragData) -> Void

    let frameSizeMultiplier: CGFloat = 1.2
    var frameSize: CGFloat {
        cellSize * 2 * frameSizeMultiplier
    }

    @State var candidateFrame: CGRect? = nil

    @State var isBeingDragged: Bool = false

    var body: some View {
        StackView(axis: candidates.axis, spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .overlay(Text("\(candidates.item1.emoji)"))
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .overlay(Text("\(candidates.item2.emoji)"))
        }
        .frame(width: frameSize, height: frameSize, alignment: .center)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ViewFramePreferenceKey.self,
                    value: geo.frame(in: GameView.coordinateSpaceName)
                ).onAppear {
                    DispatchQueue.main.async {
                        self.candidateFrame = geo.frame(in: GameView.coordinateSpaceName)
                    }
                }
            }
        )
        .onPreferenceChange(ViewFramePreferenceKey.self) { value in
            self.candidateFrame = value
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: GameView.coordinateSpaceName)
                .onChanged { value in
                    onDragChanged(
                        dragData(
                            translation: value.translation,
                            location: value.location,
                            startLocation: value.startLocation
                        )
                    )
                }
                .onEnded { value in
                    onDragEnd(
                        dragData(
                            translation: value.translation,
                            location: value.location,
                            startLocation: value.startLocation
                        )
                    )
                }
        )
        .font(.system(size: cellSize * 0.7))
    }

    private func dragData(
        translation: CGSize,
        location: CGPoint,
        startLocation: CGPoint
    ) -> CandidateDragData {
        let firstItemOffset = self.firstItemOffset(startLocation: startLocation)
        let firstPoint = CGPoint(
            x: location.x + firstItemOffset.width,
            y: location.y + firstItemOffset.height
        )
        return CandidateDragData(offset: translation, point: firstPoint)
    }

//    private func firstItemPoint(startLocation: CGPoint) -> CGPoint {
//        let firstItemOffset = self.firstItemOffset(startLocation: startLocation)
//        print("First item offset: \(firstItemOffset)")
//        return CGPoint(
//            x: startLocation.x - firstItemOffset.width,
//            y: startLocation.y - firstItemOffset.height
//        )
//    }

    private func firstItemOffset(startLocation: CGPoint) -> CGSize {
        guard let candidateFrame else {
            return .zero
        }
        let startLocationInSuperview = CGPoint(
            x: startLocation.x - candidateFrame.minX,
            y: startLocation.y - candidateFrame.minY
        )
        let firstItemPointInSuperview = firstItemPointInSuperview

        return CGSize(
            width: firstItemPointInSuperview.x - startLocationInSuperview.x,
            height: firstItemPointInSuperview.y - startLocationInSuperview.y
        )
    }

    private var firstItemPointInSuperview: CGPoint {
        let center = frameSize / 2
        return CGPoint(
            x: center - (candidates.axis == .horizontal ? cellSize / 2 : 0),
            y: center - (candidates.axis == .vertical ? cellSize / 2 : 0)
        )
    }
}
