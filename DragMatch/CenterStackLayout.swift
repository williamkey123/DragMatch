//
//  CenterStackLayout.swift
//  DragMatch
//
//  Created by William Key on 4/16/25.
//

import SwiftUI

struct CenterStackLayout: Layout {
    var axis: Axis
    var aboveOrLeadingAlignment: Alignment
    var belowOrTrailingAlignment: Alignment

    init(
        axis: Axis = .vertical,
        aboveOrLeadingAlignment: Alignment = .center,
        belowOrTrailingAlignment: Alignment = .center
    ) {
        self.axis = axis
        self.aboveOrLeadingAlignment = aboveOrLeadingAlignment
        self.belowOrTrailingAlignment = belowOrTrailingAlignment
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count == 3 else { return .zero }

        let first = subviews[0].sizeThatFits(proposal)
        let center = subviews[1].sizeThatFits(proposal)
        let third = subviews[2].sizeThatFits(proposal)

        switch axis {
        case .vertical:
            let width = max(first.width, center.width, third.width)
            let height = first.height + center.height + third.height
            return CGSize(width: width, height: height)
        case .horizontal:
            let width = first.width + center.width + third.width
            let height = max(first.height, center.height, third.height)
            return CGSize(width: width, height: height)
        }
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }

        let first = subviews[0].sizeThatFits(proposal)
        let center = subviews[1].sizeThatFits(proposal)
        let third = subviews[2].sizeThatFits(proposal)

        switch axis {
        case .vertical:
            let centerY = bounds.midY - center.height / 2
            let topRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: centerY - bounds.minY)
            let bottomRect = CGRect(x: bounds.minX, y: centerY + center.height, width: bounds.width, height: bounds.maxY - (centerY + center.height))

            let topPoint = alignmentOffset(in: topRect, size: first, alignment: aboveOrLeadingAlignment)
            let centerPoint = CGPoint(x: bounds.midX - center.width / 2, y: centerY)
            let bottomPoint = alignmentOffset(in: bottomRect, size: third, alignment: belowOrTrailingAlignment)

            subviews[0].place(at: topPoint, proposal: ProposedViewSize(first))
            subviews[1].place(at: centerPoint, proposal: ProposedViewSize(center))
            subviews[2].place(at: bottomPoint, proposal: ProposedViewSize(third))

        case .horizontal:
            let centerX = bounds.midX - center.width / 2
            let leadingRect = CGRect(x: bounds.minX, y: bounds.minY, width: centerX - bounds.minX, height: bounds.height)
            let trailingRect = CGRect(x: centerX + center.width, y: bounds.minY, width: bounds.maxX - (centerX + center.width), height: bounds.height)

            let leadingPoint = alignmentOffset(in: leadingRect, size: first, alignment: aboveOrLeadingAlignment)
            let centerPoint = CGPoint(x: centerX, y: bounds.midY - center.height / 2)
            let trailingPoint = alignmentOffset(in: trailingRect, size: third, alignment: belowOrTrailingAlignment)

            subviews[0].place(at: leadingPoint, proposal: ProposedViewSize(first))
            subviews[1].place(at: centerPoint, proposal: ProposedViewSize(center))
            subviews[2].place(at: trailingPoint, proposal: ProposedViewSize(third))
        }
    }

    private func alignmentOffset(in container: CGRect, size: CGSize, alignment: Alignment) -> CGPoint {
        let x: CGFloat
        switch alignment.horizontal {
        case .leading: x = container.minX
        case .trailing: x = container.maxX - size.width
        default: x = container.midX - size.width / 2
        }

        let y: CGFloat
        switch alignment.vertical {
        case .top: y = container.minY
        case .bottom: y = container.maxY - size.height
        default: y = container.midY - size.height / 2
        }

        return CGPoint(x: x, y: y)
    }
}
