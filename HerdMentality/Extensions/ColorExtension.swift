//
//  ColorExtension.swift
//  HerdMentality
//
//  Created by William Key on 4/19/25.
//

import SwiftUI

extension Color {
    // Grid square background
    static var gridSquare: Color {
        Color(
            light: Color(red: 246/255, green: 241/255, blue: 231/255),
            dark: Color(red: 44/255, green: 42/255, blue: 38/255)
        )
    }

    // Grid border
    static var gridBorder: Color {
        Color(
            light: Color(red: 216/255, green: 205/255, blue: 184/255),
            dark: Color(red: 68/255, green: 64/255, blue: 57/255)
        )
    }

    // Highlight color while dragging
    static var gridHighlight: Color {
        Color(
            light: Color(red: 255/255, green: 217/255, blue: 142/255),
            dark: Color(red: 179/255, green: 125/255, blue: 44/255) // deeper amber
        )
    }

    // Game background
    static var gameBackground: Color {
        Color(
            light: Color(red: 255/255, green: 253/255, blue: 248/255),
            dark: Color(red: 30/255, green: 28/255, blue: 25/255)
        )
    }

    // Adaptive animal colors
    static var horse: Color {
        Color(
            light: Color(red: 170/255, green: 132/255, blue: 87/255),    // rich brown
            dark: Color(red: 140/255, green: 105/255, blue: 70/255)
        )
    }

    static var pig: Color {
        Color(
            light: Color(red: 252/255, green: 192/255, blue: 203/255),   // light pink
            dark: Color(red: 201/255, green: 142/255, blue: 152/255)
        )
    }

    static var chicken: Color {
        Color(
            light: Color(red: 255/255, green: 237/255, blue: 180/255),   // creamy egg white
            dark: Color(red: 210/255, green: 192/255, blue: 130/255)
        )
    }

    static var cow: Color {
        Color(
            light: Color(red: 235/255, green: 235/255, blue: 235/255),   // soft white with grey tint
            dark: Color(red: 160/255, green: 160/255, blue: 160/255)
        )
    }

    static func color(for item: String) -> Color {
        switch item {
        case "🐴":
            return horse
        case "🐷":
            return pig
        case "🐔":
            return chicken
        case "🐮":
            return cow
        default:
            return gridSquare
        }
    }

    static var filledTile: Color {
        Color(
            light: Color(red: 230/255, green: 222/255, blue: 200/255),  // warm beige
            dark: Color(red: 76/255, green: 72/255, blue: 64/255)       // muted warm gray
        )
    }
}

// Helper initializer for adaptive colors
private extension Color {
    init(light: Color, dark: Color) {
        self = Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(dark)
            : UIColor(light)
        })
    }
}
