//
//  UpcomingDateCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 09/07/2026.
//

import SwiftUI

struct UpcomingDateCard: View {
    let planned: PlannedActivity

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(planned.activityTitle)
                .font(.luckyHeadline)
                .foregroundStyle(Color.charcoal)
                .multilineTextAlignment(.leading)

            if let date = planned.parsedDate {
                DateAndTimePills(date: date)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

#Preview {
    UpcomingDateCard(
        planned: PlannedActivity(
            id: UUID(),
            activityId: UUID(),
            activityTitle: "Sunset Kayaking",
            coupleId: UUID(),
            plannedByUserId: UUID(),
            proposedDate: "2026-07-10 18:30",
            responseDate: nil,
            bookingStatus: "accepted",
            reminderEnabled: false,
            reminderDaysBefore: nil,
            note: nil,
            createdAt: nil
        )
    )
    .padding()
    .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
