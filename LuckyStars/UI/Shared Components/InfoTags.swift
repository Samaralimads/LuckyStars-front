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
            InfoTag(icon: "clock.fill", text: Self.durationText(minutes: activity.duration), color: .avatarPink)
            InfoTag(icon: "location.fill", text: activity.isIndoor ? "Indoors" : "Outdoors", color: .luckyBlue)
            InfoTag(icon: "wallet.bifold.fill", text: activity.budget, color: .luckyBlueLight)
        }
    }
}

extension InfoTags {
    /// 90 -> "1h 30m", 120 -> "2h", 30 -> "30 min".
    static func durationText(minutes: Int) -> String {
        let hours = minutes / 60
        let rest = minutes % 60
        if hours == 0 { return "\(rest) min" }
        return rest == 0 ? "\(hours)h" : "\(hours)h \(rest)m"
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
