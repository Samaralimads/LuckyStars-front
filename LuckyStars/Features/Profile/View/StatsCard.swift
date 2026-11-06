//
//  StatsCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//
import SwiftUI

struct StatsCard: View {
    @State private var viewModel: StatsViewModel
    @Environment(\.switchTab) private var switchTab

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
                    Picker("Range", selection: $viewModel.range) {
                        ForEach(StatsRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.range.rawValue)
                            .font(.luckySubheadlineStrong)

                        Image(systemName: "chevron.down")
                            .font(.luckyCaptionStrong)
                    }
                    .foregroundStyle(Color.luckyBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.luckyBlueTint))
                }
                .disabled(!viewModel.isPaired)
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: Spacing.m) {
                    Text(errorMessage)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)

                    Button("Try again") {
                        Task { await viewModel.load() }
                    }
                    .font(.luckySubheadlineStrong)
                    .foregroundStyle(Color.luckyBlue)
                    .underline()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if !viewModel.isPaired {
                lockedStats
            } else {
                DatesCompletedRow(totalDates: viewModel.totalCompleted)

                Rectangle()
                    .fill(Color.rowDivider)
                    .frame(height: 1)

                if viewModel.totalCompleted == 0 {
                    firstDateCallToAction
                } else {
                    plannedBySection
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

private extension StatsCard {
    /// The real stats need two people, so without a partner we show a blurred example with a prompt.
    var lockedStats: some View {
        ZStack {
            VStack(alignment: .leading, spacing: Spacing.m) {
                DatesCompletedRow(totalDates: 12)

                Rectangle()
                    .fill(Color.rowDivider)
                    .frame(height: 1)

                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Planned with love by")
                        .font(.luckyBodySemibold)
                        .foregroundStyle(Color.charcoal)

                    PlannedByRow(name: "You", color: .luckyBlue, completed: 7, total: 12)
                    PlannedByRow(name: "Your partner", color: .avatarPink, completed: 5, total: 12)
                }
            }
            .blur(radius: 7)
            .accessibilityHidden(true)

            VStack(spacing: Spacing.s) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.charcoal)

                Text("Connect with your partner to unlock your stats")
                    .font(.luckyBodyStrong)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.center)

                NavigationLink("Invite my partner") {
                    ShareCodePairingView(showsNext: false)
                }
                .buttonStyle(.luckyPrimaryCompact)
            }
            .padding(.horizontal, Spacing.m)
        }
    }

    /// Paired, but nothing completed yet: invite them to plan the first date instead of showing zeros.
    var firstDateCallToAction: some View {
        VStack(spacing: Spacing.m) {
            Text("Plan your first date together to unlock your stats.")
                .font(.luckyBody)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)

            Button("Plan our first date") { switchTab(.discover) }
                .buttonStyle(.luckyPrimaryCompact)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s)
    }

    var plannedBySection: some View {
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

            PlannedByRow(
                name: viewModel.partnerName,
                color: .avatarPink,
                completed: viewModel.plannedByPartner,
                total: viewModel.totalCompleted
            )
        }
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
