//
//  DatePill.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  Blue-tint pill with an icon and a short date or time, e.g. "Tue 10 Nov" or "19:30".
//

import SwiftUI

struct DatePill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.luckySubheadlineStrong)
            .foregroundStyle(Color.charcoal)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.luckyBlueTint, in: Capsule())
    }
}

/// The calendar pill and the clock pill that go together on a date card.
struct DateAndTimePills: View {
    let date: Date
    var includesWeekday = true

    var body: some View {
        HStack(spacing: Spacing.xs) {
            DatePill(
                icon: "calendar",
                text: includesWeekday
                    ? date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    : date.formatted(.dateTime.month(.abbreviated).day())
            )
            DatePill(icon: "clock", text: date.formatted(.dateTime.hour().minute()))
        }
    }
}

#Preview {
    DateAndTimePills(date: .now)
        .padding()
        .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
