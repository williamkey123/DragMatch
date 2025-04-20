//
//  GridCell.swift
//  HerdMentality
//
//  Created by William Key on 4/15/25.
//


import SwiftUI

struct GridCell: Equatable {
    let row: Int
    let column: Int
    let frame: CGRect
}

// MARK: Cell tracking

struct CellFramesPreferenceKey: PreferenceKey {
    static var defaultValue: [GridCell] = []

    static func reduce(value: inout [GridCell], nextValue: () -> [GridCell]) {
        value.append(contentsOf: nextValue())
    }
}
