//
//  ProposalSentView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 05/11/2026.
//

import SwiftUI

struct ProposalSentView: View {
    let partnerName: String
    let onBackToActivities: () -> Void
    let onGoToDashboard: () -> Void

    var body: some View {
        Background {
            VStack {
                Spacer()

                VStack(spacing: Spacing.xs) {
                    Text("Your proposal is")
                        .font(.luckyHandwritten)
                        .kerning(2)
                        .foregroundStyle(Color.charcoal)

                    Text("on its way")
                        .font(.luckyHeroTitle)
                        .foregroundStyle(Color.luckyBlue)
                }

                Spacer()

                Image("ProposalSent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260)
                    .accessibilityHidden(true)

                Spacer()

                Text("We've let \(partnerName) know. Once they reply, you'll see it on your dashboard.")
                    .font(.luckyHandwritten)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.center)

                VStack(spacing: Spacing.m) {
                    Button("Back to activities", action: onBackToActivities)
                        .buttonStyle(.luckyPrimary)

                    Button("Go to dashboard", action: onGoToDashboard)
                        .buttonStyle(.luckySecondary)
                }
                .padding(.top, Spacing.xl)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    ProposalSentView(partnerName: "Alex", onBackToActivities: {}, onGoToDashboard: {})
}
