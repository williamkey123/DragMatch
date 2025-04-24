//
//  ViewFramePreferenceKey.swift
//  HerdMentality
//
//  Created by William Key on 4/20/25.
//


import SwiftUI

struct ViewFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}