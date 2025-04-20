//
//  StackView.swift
//  DragMatch
//
//  Created by William Key on 4/4/25.
//

import SwiftUI

@resultBuilder
struct ViewArrayBuilder {
    static func buildBlock(_ components: AnyView...) -> [AnyView] {
        components
    }

    static func buildExpression<V: View>(_ expression: V) -> AnyView {
        AnyView(expression)
    }
}

struct StackView: View {
    let axis: Axis
    let views: [AnyView]
    @Namespace var stackNamespace
    let hstackAlignment: VerticalAlignment
    let hstackSpacing: CGFloat?
    let vstackAlignment: HorizontalAlignment
    let vstackSpacing: CGFloat?

    init(
        axis: Axis,
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil,
        hstackAlignment: VerticalAlignment = .center,
        hstackSpacing: CGFloat? = nil,
        vstackAlignment: HorizontalAlignment = .center,
        vstackSpacing: CGFloat? = nil,
        @ViewArrayBuilder content: () -> [AnyView]
    ) {
        self.axis = axis
        self.hstackAlignment = alignment?.vertical ?? hstackAlignment
        self.hstackSpacing = spacing ?? hstackSpacing
        self.vstackAlignment = alignment?.horizontal ?? vstackAlignment
        self.vstackSpacing = spacing ?? vstackSpacing
        self.views = content()
    }

    var body: some View {
        let stackContent = ForEach(Array(views.enumerated()), id: \.offset) { index, view in
            view
                .matchedGeometryEffect(id: index, in: stackNamespace)
        }

        switch axis {
        case .horizontal:
            HStack(alignment: hstackAlignment, spacing: hstackSpacing) {
                stackContent
            }
        case .vertical:
            VStack(alignment: vstackAlignment, spacing: vstackSpacing) {
                stackContent
            }
        }
    }
}
