//
//  NextDateCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/06/2026.
//

import SwiftUI

struct NextDateCard: View {
    let planned: PlannedActivity
    let onDetails: () -> Void
    let onAddToCalendar: () -> Void

    var body: some View {
        let date = planned.parsedDate ?? Date.now
        let calendar = Calendar.current
        // Whole calendar days from today to the date, so a date 3 days away says 3.
        let days = max(calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: date)).day ?? 0, 0)

        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .top) {
                Text(planned.activityTitle)
                    .font(.luckyTitle)
                    .foregroundStyle(Color.luckyBlue)
                    .multilineTextAlignment(.leading)

                Spacer()

                VStack(spacing: 0) {
                    Text("\(days)")
                        .font(.luckyHeroTitle)
                        .foregroundStyle(Color.charcoal)
                    Text("DAYS TO GO")
                        .font(.luckyCaptionStrong)
                        .foregroundStyle(Color.inkSecondary)
                }
            }

            HStack(spacing: Spacing.m) {
                Label(date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)), systemImage: "calendar")
                Label(date.formatted(.dateTime.hour().minute()), systemImage: "clock")
            }
            .font(.luckySubheadline)
            .foregroundStyle(Color.charcoal)

            HStack(spacing: Spacing.s) {
                Button("Add to calendar", action: onAddToCalendar)
                    .buttonStyle(.luckySecondaryCompact)

                Button("Details →", action: onDetails)
                    .buttonStyle(.luckyPrimaryCompact)
            }
        }
        .background(alignment: .topTrailing) {
            StarAccent()
                .offset(x: -Spacing.s, y: -Spacing.s)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}
