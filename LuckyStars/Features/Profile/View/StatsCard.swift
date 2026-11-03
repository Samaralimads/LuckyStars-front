//
//  StatsCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//
import SwiftUI

struct StatsCard: View {
    @State private var viewModel: StatsViewModel

    init(viewModel: StatsViewModel = StatsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR ADVENTURES")
                        .font(.luckyCaptionStrong)
                        .foregroundStyle(Color.luckyBlue)

                    Text("Stats")
                        .font(.luckyHeadline)
                        .foregroundStyle(Color.charcoal)
                }

                Spacer()

                Menu {
                    Button("This year") { }
                    Button("This month") { }
                    Button("All time") { }
                } label: {
                    HStack(spacing: 4) {
                        Text("This year")
                            .font(.luckySubheadlineStrong)

                        Image(systemName: "chevron.down")
                            .font(.luckyCaptionStrong)
                    }
                    .foregroundStyle(Color.luckyBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.luckyBlueTint))
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                DatesCompletedRow(totalDates: viewModel.totalCompleted)

                Rectangle()
                    .fill(Color.rowDivider)
                    .frame(height: 1)

                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Planned with love by")
                        .font(.luckyBodySemibold)
                        .foregroundStyle(Color.charcoal)

                    PlannedByRow(
                        name: viewModel.myName,
                        color: .luckyBlue,
                        completed: viewModel.plannedByMe,
                        total: viewModel.totalCompleted
                    )

                    if viewModel.isPaired {
                        PlannedByRow(
                            name: viewModel.partnerName,
                            color: .avatarPink,
                            completed: viewModel.plannedByPartner,
                            total: viewModel.totalCompleted
                        )
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
        .task { await viewModel.load() }
    }
}

struct DatesCompletedRow: View {
    let totalDates: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(totalDates)")
                .font(.luckyHeroTitle)
                .foregroundStyle(Color.luckyBlue)

            Text("Dates completed")
                .font(.luckyHeadline)
                .foregroundStyle(Color.charcoal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s)
        .accessibilityElement(children: .combine)
    }
}

/// An outlined bar filled up to this person's share of the completed dates, with "Name 65%" inside.
struct PlannedByRow: View {
    let name: String
    let color: Color
    let completed: Int
    let total: Int

    private var fraction: Double {
        total > 0 ? min(Double(completed) / Double(total), 1) : 0
    }

    private var percent: Int { Int((fraction * 100).rounded()) }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Color.cardFill)

            GeometryReader { geometry in
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * fraction)
            }

            Text("\(name) \(percent)%")
                .font(.luckySubheadlineStrong)
                .foregroundStyle(Color.cardFill)
                .padding(.leading, 12)
        }
        .frame(height: 26)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.charcoal, lineWidth: Outline.thick))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \(percent) percent of dates planned")
    }
}

#Preview {
    Background {
        StatsCard()
            .padding(20)
    }
}
