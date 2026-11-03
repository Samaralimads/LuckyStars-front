//
//  InfoTags.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 19/02/2026.
//

import SwiftUI

struct InfoTags: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: 10) {
            InfoTag(icon: "clock.fill", text: "\(activity.duration / 60)h", color: .avatarPink)
            InfoTag(icon: "location.fill", text: activity.isIndoor ? "Indoors" : "Outdoors", color: .luckyBlue)
            InfoTag(icon: "wallet.bifold.fill", text: activity.budget, color: .luckyBlueLight)
        }
    }
}

struct InfoTag: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.luckyCaptionStrong)
            Text(text)
                .font(.luckySubheadlineStrong)
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .foregroundStyle(Color.cardFill)
        .clipShape(Capsule())
    }
}

#Preview {
    let activity = Activity(
        id: UUID(),
        title: "Sunset Picnic",
        description: "A lovely picnic.",
        budget: "€",
        duration: 150,
        isIndoor: false,
        categoryId: UUID(),
        categoryName: "Nature"
    )
    InfoTags(activity: activity)
}
