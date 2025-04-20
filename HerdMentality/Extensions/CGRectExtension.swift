//
//  CGRectExtension.swift
//  DragMatch
//
//  Created by William Key on 4/15/25.
//


import SwiftUI

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}