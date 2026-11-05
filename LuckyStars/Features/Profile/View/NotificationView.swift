//
//  NotificationView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct NotificationView: View {
    @State private var partnerResponse = true
    @State private var upcomingActivities = true
    @State private var specialDates = true

    var body: some View {

        Background{
            ScrollView {
                LuckyGroup {
                    NotificationRow(
                        title: "Partner response",
                        subtitle: "Get notified about your partner's reply to an activity",
                        isOn: $partnerResponse
                    )

                    NotificationRow(
                        title: "Upcoming activities",
                        subtitle: "Get reminded of your upcoming booked activity",
                        isOn: $upcomingActivities
                    )

                    NotificationRow(
                        title: "Special dates",
                        subtitle: "We'll notify you before your anniversary or any special date",
                        isOn: $specialDates
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .luckyBackButton(title: "Notifications")
    }
}

private struct NotificationRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.luckyBodyStrong)
                    .foregroundStyle(Color.charcoal)

                Text(subtitle)
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.inkSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.luckyBlue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    NotificationView()
}
