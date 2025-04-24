//
//  CandidatePair.swift
//  HerdMentality
//
//  Created by William Key on 4/20/25.
//

import Foundation
import SwiftUICore

struct CandidatePair: Identifiable, Hashable {
    let id = UUID()
    let item1: Animal
    let item2: Animal
    let axis: Axis

    init(item1: Animal? = nil, item2: Animal? = nil, axis: Axis? = nil) {
        self.item1 = item1 ?? Animal.allCases.randomElement()!
        self.item2 = item2 ?? Animal.allCases.randomElement()!
        self.axis = axis ?? (Bool.random() ? .horizontal : .vertical)
    }
}
