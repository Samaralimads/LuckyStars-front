//
//  NotificationsFeedView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 04/11/2026.
//

import SwiftUI

struct NotificationsFeedView: View {
    var body: some View {
        Background {
            // TODO: Replace the placeholder PNG (EmptyNotifications.imageset) with the final illustration.
            VStack(spacing: 12) {
                Image("EmptyNotifications")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .accessibilityHidden(true)

                Text("All caught up")
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)

                Text("Replies from your partner and reminders will show up here.")
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .luckyBackButton(title: "Notifications")
    }
}

#Preview {
    NavigationStack {
        NotificationsFeedView()
    }
}
