//
//  PendingProposalCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/04/2026.
//

import SwiftUI

struct PendingProposalCard: View {
    let title: String
    let date: Date
    let partnerName: String
    let note: String?

    var onAccept: () -> Void
    var onRefuse: () -> Void
    var onReschedule: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            EyebrowLabel(icon: "sparkle", text: "New proposal from \(partnerName)")

            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(title)
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.leading)

                DateAndTimePills(date: date, includesWeekday: false)

                if let note {
                    Text(note)
                        .font(.luckySubheadline)
                        .italic()
                        .foregroundStyle(Color.inkSecondary)
                }
            }

            VStack(spacing: Spacing.s) {
                Button("Accept", action: onAccept)
                    .buttonStyle(.luckyPrimary)

                HStack(spacing: Spacing.s) {
                    Button("Decline", action: onRefuse)
                        .buttonStyle(.luckySecondary)

                    Button("Reschedule", action: onReschedule)
                        .buttonStyle(.luckySecondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

#Preview {
    Background {
        PendingProposalCard(
            title: "Pottery Workshop",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!,
            partnerName: "John",
            note: "How about this instead?",
            onAccept: {},
            onRefuse: {},
            onReschedule: {}
        )
        .padding()
    }
}
