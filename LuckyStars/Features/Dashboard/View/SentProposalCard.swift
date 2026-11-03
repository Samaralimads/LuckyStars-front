//
//  SentProposalCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 28/09/2026.
//

import SwiftUI

struct SentProposalCard: View {
    let title: String
    let date: Date
    let partnerName: String

    var body: some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                EyebrowLabel(icon: "paperplane.fill", text: "Waiting for \(partnerName)")

                Text(title)
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.leading)

                DateAndTimePills(date: date, includesWeekday: false)
            }

            Spacer()

            Image(systemName: "clock")
                .font(.title3)
                .foregroundStyle(Color.inkSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }
}

#Preview {
    Background {
        SentProposalCard(
            title: "Pottery Workshop",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!,
            partnerName: "Alex"
        )
        .padding()
    }
}
