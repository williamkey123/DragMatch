//
//  FramedView.swift
//  HerdMentality
//
//  Created by William Key on 4/16/25.
//

import SwiftUI

struct FramedView<Center: View, AboveOrLeading: View, BelowOrTrailing: View>: View {
    let axis: Axis
    let centerContent: Center
    let topOrLeadingContent: AboveOrLeading?
    let bottomOrTrailingContent: BelowOrTrailing?

    let topAlignment: Alignment
    let leadingAlignment: Alignment
    let bottomAlignment: Alignment
    let trailingAlignment: Alignment

    let animation: Animation?

    init(
        axis: Axis,
        topAlignment: Alignment = .bottom,
        leadingAlignment: Alignment = .trailing,
        bottomAlignment: Alignment = .top,
        trailingAlignment: Alignment = .leading,
        animation: Animation? = nil,
        @ViewBuilder centerContent: () -> Center,
        @ViewBuilder topOrLeadingContent: () -> AboveOrLeading = { EmptyView() },
        @ViewBuilder bottomOrTrailingContent: () -> BelowOrTrailing = { EmptyView() }
    ) {
        self.axis = axis
        self.topAlignment = topAlignment
        self.leadingAlignment = leadingAlignment
        self.bottomAlignment = bottomAlignment
        self.trailingAlignment = trailingAlignment
        self.animation = animation
        self.centerContent = centerContent()
        self.topOrLeadingContent = topOrLeadingContent()
        self.bottomOrTrailingContent = bottomOrTrailingContent()
        self.displayedAxis = axis
    }

    @State private var centerSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero

    @State private var beforeFrame: CGSize = .zero
    @State private var afterFrame: CGSize = .zero
    @State private var beforeOffset: CGSize = .zero
    @State private var afterOffset: CGSize = .zero
    @State private var displayedAxis: Axis

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                centerContent
                    .background(
                        GeometryReader { centerGeo in
                            Color.clear
                                .onAppear {
                                    updateLayout(containerSize: geo.size, centerSize: centerGeo.size)
                                }
                                .onChange(of: centerGeo.size) {
                                    updateLayout(containerSize: geo.size, centerSize: centerGeo.size)
                                }
                        }
                    )

                topOrLeadingContent
                    .frame(
                        width: beforeFrame.width,
                        height: beforeFrame.height,
                        alignment: displayedAxis == .horizontal ? leadingAlignment : topAlignment
                    )
                    .offset(beforeOffset)

                bottomOrTrailingContent
                    .frame(
                        width: afterFrame.width,
                        height: afterFrame.height,
                        alignment: displayedAxis == .horizontal ? trailingAlignment : bottomAlignment
                    )
                    .offset(afterOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: geo.size) {
                updateLayout(containerSize: geo.size)
            }
            .onChange(of: axis) {
                updateLayout(axis: axis)
            }
        }

    }

    private func updateLayout(
        containerSize: CGSize? = nil,
        centerSize: CGSize? = nil,
        axis: Axis? = nil
    ) {
        let newContainerSize = containerSize ?? self.containerSize
        let newCenterSize = centerSize ?? self.centerSize
        let newAxis = axis ?? self.axis

        withAnimation(animation) {
            self.containerSize = newContainerSize
            self.centerSize = newCenterSize
            self.displayedAxis = newAxis

            switch displayedAxis {
            case .vertical:
                let availableHeight = newContainerSize.height - newCenterSize.height
                let halfHeight = availableHeight / 2
                let offset = (halfHeight + newCenterSize.height) / 2
                beforeFrame = CGSize(width: newContainerSize.width, height: halfHeight)
                afterFrame = CGSize(width: newContainerSize.width, height: halfHeight)
                beforeOffset = CGSize(width: 0, height: -offset)
                afterOffset = CGSize(width: 0, height: offset)

            case .horizontal:
                let availableWidth = newContainerSize.width - newCenterSize.width
                let halfWidth = availableWidth / 2
                let offset = (halfWidth + newCenterSize.width) / 2
                beforeFrame = CGSize(width: halfWidth, height: newContainerSize.height)
                afterFrame = CGSize(width: halfWidth, height: newContainerSize.height)
                beforeOffset = CGSize(width: -offset, height: 0)
                afterOffset = CGSize(width: offset, height: 0)
            }
        }
    }
}
