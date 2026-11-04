//
//  FiltersView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 17/02/2026.
//

import SwiftUI

// MARK: - Filter Model

struct FilterState {
    var priceRange: String? = nil
    var duration: String? = nil
    var location: String? = nil

    var totalSelected: Int {
        [priceRange, duration, location].compactMap { $0 }.count
    }
}

// MARK: - FiltersView

struct FiltersView: View {
    @Binding var filterState: FilterState
    @Environment(\.dismiss) private var dismiss

    private let priceOptions = ["LOW", "MEDIUM", "HIGH"]
    private let durationOptions = ["< 2 HOURS", "< 5 HOURS", "< 8 HOURS"]
    private let locationOptions = ["INDOORS", "OUTDOORS"]

    var body: some View {
        ZStack {
            Color.cardFill
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Rectangle()
                    .fill(Color.rowDivider)
                    .frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        FilterSection(
                            title: "Price",
                            options: priceOptions,
                            selected: filterState.priceRange
                        ) { option in
                            select(&filterState.priceRange, option)
                        }

                        divider

                        FilterSection(
                            title: "Duration",
                            options: durationOptions,
                            selected: filterState.duration
                        ) { option in
                            select(&filterState.duration, option)
                        }

                        divider

                        FilterSection(
                            title: "Setting",
                            options: locationOptions,
                            selected: filterState.location
                        ) { option in
                            select(&filterState.location, option)
                        }

                        divider
                    }
                }

                Spacer()

                HStack(spacing: Spacing.m) {
                    Button("Clear all") {
                        filterState = FilterState()
                    }
                    .buttonStyle(.luckySecondary)
                    .containerRelativeFrame(.horizontal) { width, _ in width * 0.34 }

                    Button("Apply filters") {
                        dismiss()
                    }
                    .buttonStyle(.luckyPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private var header: some View {
        LuckySheetHeader(title: "Filters") { dismiss() }
    }

    private var divider: some View {
        Rectangle().fill(Color.rowDivider).frame(height: 1).padding(.horizontal, 20)
    }

    // Each section only supports a single active value server-side, so
    // tapping a chip either selects it or, if already selected, clears it.
    // "ANY" passes nil, which clears the section.
    private func select(_ current: inout String?, _ value: String?) {
        current = (current == value) ? nil : value
    }
}

// MARK: - FilterSection

struct FilterSection: View {
    let title: String
    let options: [String]
    let selected: String?
    let onTap: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.luckyHeadline)
                .foregroundStyle(Color.charcoal)

            FlowLayout(spacing: 10, lineSpacing: 12) {
                FilterChip(title: "ANY", isSelected: selected == nil) { onTap(nil) }

                ForEach(options, id: \.self) { option in
                    FilterChip(title: option, isSelected: selected == option) { onTap(option) }
                }
            }
        }
        .padding(20)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.luckyCaptionStrong)
                .foregroundStyle(isSelected ? Color.cardFill : Color.charcoal)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .luckyOutline(
                    Capsule(),
                    fill: isSelected ? Color.luckyBlueLight : Color.cardFill,
                    lineWidth: Outline.field,
                    shadowOffset: isSelected ? nil : 0
                )
        }
        .buttonStyle(.plain)
    }
}

/// Wraps its children onto new lines, each chip keeping its natural width.
private struct FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let layout = arrange(in: proposal.width ?? .infinity, subviews: subviews)
        return CGSize(width: proposal.width ?? layout.width, height: layout.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = arrange(in: bounds.width, subviews: subviews)
        for (index, origin) in layout.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> (origins: [CGPoint], width: CGFloat, height: CGFloat) {
        var origins: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, width: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            width = max(width, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return (origins, width, y + rowHeight)
    }
}

#Preview {
    @Previewable @State var filterState = FilterState()
    return FiltersView(filterState: $filterState)
}
