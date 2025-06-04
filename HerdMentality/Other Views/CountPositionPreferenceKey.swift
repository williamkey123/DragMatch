//
//  CountPositionPreferenceKey.swift
//  HerdMentality
//
//  Created by William Key on 4/20/25.
//


import SwiftUI

struct ViewPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}


