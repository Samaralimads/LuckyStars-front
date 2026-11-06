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
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .center, spacing: Spacing.m) {
                textBlock
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(activity.category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.imageSize, height: Self.imageSize)
                    .accessibilityHidden(true)
            }

            // On its own row, so the illustration never touches the tags.
            InfoTags(activity: activity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

private extension ActivityCard {
    /// Title and description. The space is always that of a two-line title plus a two-line description,
    /// so every card has the same height. Inside it, a one-line title leaves room for a longer
    /// (three-line) description; a two-line title keeps the two-line one.
    var textBlock: some View {
        column(descriptionLines: 2, reservesSpace: true)
            .hidden()
            .accessibilityHidden(true)
            .overlay(alignment: .topLeading) {
                // Tries the taller version first: it only fits when the title takes a single line.
                ViewThatFits(in: .vertical) {
                    column(descriptionLines: 3, reservesSpace: false)
                    column(descriptionLines: 2, reservesSpace: false)
                }
            }
    }

    func column(descriptionLines: Int, reservesSpace: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(activity.title)
                .font(.luckyHeadline)
                .foregroundStyle(Color.charcoal)
                .lineLimit(2, reservesSpace: reservesSpace)
                .multilineTextAlignment(.leading)

            Text(activity.description)
                .font(.luckySubheadline)
                .foregroundStyle(Color.inkSecondary)
                .lineLimit(descriptionLines, reservesSpace: reservesSpace)
                .multilineTextAlignment(.leading)
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
