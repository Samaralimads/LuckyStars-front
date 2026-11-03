//
//  EmptyNextDateCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/06/2026.
//

import SwiftUI

struct EmptyNextDateCard: View {
    var body: some View {
        // TODO: Add a cute illustration or animation to this empty state.
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("A little time for two.")
                .font(.luckyTitle)
                .foregroundStyle(Color.luckyBlue)
                .multilineTextAlignment(.leading)

            Text("No date on the calendar yet. Let's change that.")
                .font(.luckyBody)
                .foregroundStyle(Color.charcoal)
                .multilineTextAlignment(.leading)

            NavigationLink(destination: ActivityView()) {
                Text("Find an activity →")
            }
            .buttonStyle(.luckyPrimaryCompact)
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

#Preview {
    EmptyNextDateCard()
}
