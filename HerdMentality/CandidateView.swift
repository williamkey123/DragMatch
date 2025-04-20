//
//  CandidateView.swift
//  HerdMentality
//
//  Created by William Key on 4/15/25.
//

import SwiftUI

struct CandidateView: View {
    let candidates: (item1: Character, item2: Character, horizontal: Bool)
    let cellSize: CGFloat
    let setFirstDragged: (Bool) -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnd: (DragGesture.Value) -> Void

    @State var isBeingDragged: Bool = false

    var body: some View {
        StackView(axis: candidates.horizontal ? .horizontal : .vertical, spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .overlay(Text("\(candidates.item1)"))
                .gesture(makeDragGesture(firstDragged: true))
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .overlay(Text("\(candidates.item2)"))
                .gesture(makeDragGesture(firstDragged: false))
        }
        .frame(width: cellSize * 2, height: cellSize * 2, alignment: .center)
        .font(.system(size: cellSize * 0.7))
    }

    private func makeDragGesture(firstDragged: Bool) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: GameView.coordinateSpaceName)
            .onChanged { value in
                if !isBeingDragged {
                    isBeingDragged = true
                    setFirstDragged(firstDragged)
                }
                onDragChanged(value)
            }
            .onEnded { value in
                onDragEnd(value)
                isBeingDragged = false
            }
    }
}
