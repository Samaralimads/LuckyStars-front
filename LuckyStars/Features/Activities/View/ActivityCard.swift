//
//  ActivityCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/02/2026.
//

import SwiftUI

struct ActivityCard: View {
    let activity: Activity

    private static let imageSize: CGFloat = 80

    var body: some View {
        textBlock(reservesSpace: true)
            .hidden()
            .accessibilityHidden(true)
            .overlay(alignment: .leading) {
                textBlock(reservesSpace: false)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Centered on the whole card, not just the text block.
            .overlay(alignment: .trailing) {
                Image(activity.category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.imageSize, height: Self.imageSize)
                    .padding(.trailing, 20)
                    .accessibilityHidden(true)
            }
            .luckyCard()
            .padding(.trailing, Outline.shadowOffset)
    }

    private func textBlock(reservesSpace: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(activity.title)
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)
                    .lineLimit(2, reservesSpace: reservesSpace)
                    .multilineTextAlignment(.leading)

                Text(activity.description)
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .lineLimit(2, reservesSpace: reservesSpace)
                    .multilineTextAlignment(.leading)
            }
            // Keeps the text clear of the illustration, which is overlaid on the card.
            .padding(.trailing, Self.imageSize + Spacing.m)

            InfoTags(activity: activity)
        }
    }
}

#Preview {
    let activity = Activity(
        id: UUID(),
        title: "Brunch at a Local Cofee Shop",
        description: "Enjoy a slow Sunday morning with pastries and coffee.",
        budget: "€€",
        duration: 120,
        isIndoor: true,
        categoryId: UUID(),
        categoryName: "Food & Drinks"
    )
    Background {
        ActivityCard(activity: activity)
            .padding(20)
    }
}
