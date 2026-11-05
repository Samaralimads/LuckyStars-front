//
//  LuckyGroup.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 27/10/2026.
//
//  A Lucky Stars card holding rows separated by thin dividers, plus the
//  standard settings row (title, subtitle, blue chevron).
//

import SwiftUI

struct LuckyGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(subviews.indices, id: \.self) { index in
                    subviews[index]
                    if index < subviews.count - 1 {
                        // Inset, so the line stays on the white part of the card and never touches the outline.
                        Rectangle()
                            .fill(Color.rowDivider)
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

/// Title + optional subtitle on the left, optional chevron on the right.
struct SettingsRow: View {
    let title: String
    var subtitle: String? = nil
    var showsChevron: Bool = true

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.luckyBodyStrong)
                    .foregroundStyle(Color.charcoal)

                if let subtitle {
                    Text(subtitle)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.inkSecondary)
                }
            }

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.luckyBlue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    LuckyGroup {
        SettingsRow(title: "About you", subtitle: "Your details and account")
        SettingsRow(title: "Your relationship", subtitle: "Partner and anniversary")
    }
    .padding()
    .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
